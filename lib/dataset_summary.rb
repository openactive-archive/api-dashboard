require_relative 'dataset_parser'

class DatasetSummary

  include DatasetParser

  attr_reader :feed, :dataset_key, :geocoder

  def initialize(dataset_key)
    @dataset_key = dataset_key
    @geocoder = LocalGeocoder::LocalAuthorityGeocoder.new()
  end

  def restart
    clear_samples
    clear_last_page
    clear_boundaries
    clear_activities
  end

  def restart_from_last_page
    clear_samples
    clear_boundaries
    clear_activities
  end

  def clear_boundaries
    Redis.current.zremrangebyrank(dataset_key+"/boundary", 0, -1)
  end

  def clear_activities
    Redis.current.zremrangebyrank(dataset_key+"/activities", 0, -1)
  end

  def clear_samples
    Redis.current.hdel(dataset_key, "samples")
  end

  def clear_last_page
    Redis.current.hdel(dataset_key, "last_page")
  end

  def ranked_activities(limit=10)
    Redis.current.zrevrange(dataset_key+'/activities', 0, -1).take(limit)
  end

  def activities(limit=10)
    scores = {}
    ranked = ranked_activities(limit)
    ranked.each {|a| scores.merge!({ a => Redis.current.zscore(dataset_key+'/activities', a) }) }
    scores
  end

  def ranked_boundaries(limit=10)
    Redis.current.zrevrange(dataset_key+'/boundary', 0, -1).take(limit)
  end

  def boundaries(limit=10)
    scores = {}
    ranked = ranked_boundaries(limit)
    ranked.each {|b| scores.merge!({ b => Redis.current.zscore(dataset_key+'/boundary', b) }) }
    scores
  end

  def last_updated
    result = Redis.current.hget(dataset_key, "summary_last_updated").to_i
    return nil if result.eql?(0)
    Time.at(result)
  end

  def last_attempt
    lu = Redis.current.hget(dataset_key, "summary_last_updated").to_i
    la = Redis.current.hget(dataset_key, "summary_last_attempt").to_i
    timestamp = lu > la ? lu : la
    return nil if timestamp.eql?(0)
    Time.at(timestamp)
  end

  def error_code
    Redis.current.hget(dataset_key, "summary_error_code")
  end

  def update
    sample_limit = ENV["SUMMARY_SAMPLE_LIMIT"].to_i

    if last_page.nil?
      dataset = DatasetsCache.all[@dataset_key]
      dataset_uri = dataset['dataurl']
    else
      dataset_uri = last_page
    end

    @feed = OpenActive::Feed.new(dataset_uri)

    begin
      page, items_sampled = harvest(sample_limit)
      Redis.current.hincrby(dataset_key, "samples", items_sampled)
      Redis.current.hset(dataset_key, "last_page", page.uri)
      Redis.current.hset(dataset_key, "summary_last_updated", Time.now.to_i)
      return true
    rescue RestClient::Exception => e
      Redis.current.hset(dataset_key, "summary_last_attempt", Time.now.to_i)
      Redis.current.hset(dataset_key, "summary_error_code", e.http_code)
      return false
    rescue => e
      Redis.current.hset(dataset_key, "summary_last_attempt", Time.now.to_i)
      Redis.current.hset(dataset_key, "summary_error_code", "?")
      return false
    end
  end

  def last_page
    Redis.current.hget(dataset_key, "last_page")
  end

  def samples
    Redis.current.hget(dataset_key, "samples").to_i
  end

  def zincr_activities(item)
    activities = extract_activities(item).map { |a| normalise_activity(a) }
    activities.each {|a| Redis.current.zincrby(dataset_key+"/activities", 1, a) }
  end

  def zincr_boundary(item)
    coordinates = extract_coordinates(item)
    return false unless coordinates
    result = geocoder.reverse_geocode(coordinates[0], coordinates[1])
    return false if result.nil?
    Redis.current.zincrby(dataset_key+"/boundary", 1, result.name)
  end

  def normalise_activity(activity)
    activity.downcase.strip
  end

  private

  def harvest(sample_limit)
    items_sampled = 0
    @feed.harvest(0.5) do |page|
      return [page, items_sampled] if page.last_page?
      next unless is_page_recent?(page)
      page.items.each do |item|
        return [page, items_sampled] if items_sampled >= sample_limit
        next if item["state"].eql?("deleted")
        zincr_activities(item)
        zincr_boundary(item)
        items_sampled += 1
      end
    end
  end

end