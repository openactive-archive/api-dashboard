require 'openactive'
require 'json'
require 'redis'

class DatasetSummary
  attr_reader :feed

  def initialize(feed = nil)
    @feed = feed
  end

  def is_page_recent?(page)
    one_year_ago = (Time.now.to_i - 31622400) * 1000
    page.items.any? {|i| i["modified"].to_i >= one_year_ago }
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