require 'openactive'
require 'json'
require 'redis'

class DatasetSummary
  attr_reader :feed, :dataset_key, :dataset_uri

  def initialize(dataset_key, dataset_uri)
    @dataset_key = dataset_key
    @dataset_uri = dataset_uri
    @feed = OpenActive::Feed.new(@dataset_uri)
  end

  def harvest_activities(sample_limit=500)
    sampled_items = 0
    feed.harvest(0.5) do |page|
      next unless is_page_recent?(page)
      page.items.each do |item|
        break if (sampled_items += 1) > sample_limit
        next if item["state"].eql?("deleted")
        zincr_activities(item)
      end
    end
  end

  def zincr_activities(item)
    activities = extract_activities(item)
    activities.each {|a| Redis.current.zincrby(dataset_key, 1, a) }
  end

  def is_page_recent?(page)
    one_year_ago = (Time.now.to_i - 31622400) * 1000
    page.items.any? do |i| 
      next if i["state"].eql?("deleted")
      i["modified"].to_i >= one_year_ago
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

end