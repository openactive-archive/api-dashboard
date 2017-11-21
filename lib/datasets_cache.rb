require 'openactive'
require 'json'
require 'redis'

class DatasetsCache

  def self.update
    begin
      datasets = OpenActive::Datasets.list
      Redis.current.set("datasets", datasets.to_json)
      return true
    rescue
      return false
    end
  end

  def self.all
    datasets = Redis.current.get("datasets")
    if datasets.nil?
      []
    else
      JSON.parse(datasets)
    end
  end

end