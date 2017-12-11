require_relative 'datasets_cache'
require_relative 'dataset_parser'
require_relative 'local_geocoder/local_authority_geocoder'
require 'time'

class DatasetSummary

  include DatasetParser

  attr_reader :feed, :dataset_key, :dataset_uri, :geocoder

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
    result = Redis.current.hget(dataset_key, "summary_last_updated")
    return nil if result.nil?
    Time.at(result.to_i)
  end

  def update(sample_limit=500)
    if last_page.nil?
      dataset = DatasetsCache.all[@dataset_key]
      @dataset_uri = dataset['data-url']
    else
      @dataset_uri = last_page
    end

    @feed = OpenActive::Feed.new(@dataset_uri)

    begin
      page, items_sampled = harvest(sample_limit)
      Redis.current.hincrby(dataset_key, "samples", items_sampled)
      Redis.current.hset(dataset_key, "last_page", page.uri)
      Redis.current.hset(dataset_key, "summary_last_updated", Time.now.to_i)
      return true
    rescue => e
      #do nada
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
    Redis.current.zincrby(dataset_key+"/boundary", 1, result.short_name)
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