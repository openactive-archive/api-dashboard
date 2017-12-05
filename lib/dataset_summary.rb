require_relative 'datasets_cache'
require 'time'

class DatasetSummary
  attr_reader :feed, :dataset_key, :dataset_uri

  def initialize(dataset_key)
    @dataset_key = dataset_key
    dataset = DatasetsCache.all[@dataset_key]
    if last_page.nil?
      @dataset_uri = dataset['data-url']
    else
      @dataset_uri = last_page
    end
    @feed = OpenActive::Feed.new(@dataset_uri)
  end

  def ranked_activities(limit=10)
    Redis.current.zrevrange(dataset_key+'/activities', 0, -1).take(limit)
  end

  def harvest
    begin
      page, items_sampled = harvest_activities
      Redis.current.hincrby(dataset_key, "activity_samples", items_sampled)
      Redis.current.hset(dataset_key, "last_page", page.uri)
    rescue => e
      #do nada
    end
  end

  def last_page
    Redis.current.hget(dataset_key, "last_page")
  end

  def activity_samples
    Redis.current.hget(dataset_key, "activity_samples").to_i
  end

  def harvest_activities(sample_limit=500)
    items_sampled = 0
    feed.harvest(0.5) do |page|
      return [page, items_sampled] if page.last_page?
      next unless is_page_recent?(page)
      page.items.each do |item|
        return [page, items_sampled] if items_sampled >= sample_limit
        next if item["state"].eql?("deleted")
        zincr_activities(item)
        items_sampled += 1
      end
    end
  end

  def parse_modified(modified)
    begin
      parsed = Time.parse(modified)
    rescue
      parsed = modified.to_i
      parsed = parsed / 1000 if parsed.to_s.length > 10
    end
    parsed.to_i
  end

  def zincr_activities(item)
    activities = extract_activities(item).map { |a| normalise_activity(a) }
    activities.each {|a| Redis.current.zincrby(dataset_key+"/activities", 1, a) }
  end

  def is_page_recent?(page)
    one_year_ago = (Time.now.to_i - 31622400)
    page.items.any? do |i|
      next if i["state"].eql?("deleted")
      modified = parse_modified(i["modified"])
      modified >= one_year_ago
    end
  end

  def extract_activities(item)
    activity = item["data"]["activity"]
    case activity
    when String
      return [activity]
    when Array
      return activity.map { |a| a.class == Hash ? a["prefLabel"] : a }
    when Hash
      return [activity["prefLabel"]]
    else
      return []
    end
  end

  def normalise_activity(activity)
    activity.downcase.strip
  end

end