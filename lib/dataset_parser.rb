require 'time'

module DatasetParser

  def parse_modified(modified)
    begin
      parsed = Time.parse(modified)
    rescue
      parsed = modified.to_i
      parsed = parsed / 1000 if parsed.to_s.length > 10
    end
    parsed.to_i
  end

  def extract_timestamp(item, date_key="startDate")
    data = item["data"]
    result = nil

    if data.has_key? date_key
      result = data[date_key]
    elsif data.has_key? "subEvent" and data["subEvent"].class == Array
      result = data["subEvent"].first[date_key] if data["subEvent"].first.class == Hash
    elsif data.has_key? "subEvent" and data["subEvent"].class == Hash
      result = data["subEvent"][date_key]
    elsif data.has_key? "eventSchedule"
      result = data["eventSchedule"][date_key]
    end

    return nil unless result    
    parse_modified(result)
  end

  def is_page_recent?(page)
    one_year_ago = (Time.now.to_i - 31622400)
    page.items.any? do |i|
      next if i["state"].eql?("deleted")
      modified = parse_modified(i["modified"])
      return (modified >= one_year_ago)
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

  def extract_coordinates(item)
    if item["data"]["location"] and item["data"]["location"]["geo"]
      geo = item["data"]["location"]["geo"] 
    elsif item["data"]["location"] and item["data"]["location"]["containedInPlace"] and item["data"]["location"]["containedInPlace"]["geo"]
      geo = item["data"]["location"]["containedInPlace"]["geo"]
    else
      return false
    end
    coordinates = [geo["longitude"].to_f, geo["latitude"].to_f]
    return false if coordinates.eql?([0.0, 0.0])
    coordinates
  end

end