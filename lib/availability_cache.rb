require_relative 'datasets_cache'

class AvailabilityCache

  def self.update
    datasets = DatasetsCache.all
    results = {}

    datasets.each do |key, dataset|
      begin
        results[dataset['dataurl']] = fetch(dataset['dataurl']).eql?("200")
      rescue
        next
      end
    end

    begin
      return Redis.current.set("availability", results.to_json).eql?("OK")
    rescue
      return false
    end
  end

  def self.all
    availability = Redis.current.get("availability")
    if availability.nil?
      {}
    else
      JSON.parse(availability)
    end
  end

  def self.fetch(uri_str, limit = 5)
    raise StandardError, 'too many HTTP redirects' if limit == 0
    response = Net::HTTP.get_response(URI(uri_str))
    
    case response
    when Net::HTTPSuccess then
      response.code
    when Net::HTTPRedirection then
      location = response['location']
      warn "redirected to #{location}"
      fetch(location, limit - 1)
    else
      response.code
    end
  end

end