require 'openactive'
require 'json'
require 'redis'

class DatasetsCache

  def self.update
    # TODO: Error check & validation
    datasets = OpenActive::Datasets.list
    Redis.current.set("datasets", datasets.to_json)
  end

  def self.all
    JSON.parse(Redis.current.get("datasets"))
  end

end