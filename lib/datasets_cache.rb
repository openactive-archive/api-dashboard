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
    datasets = Redis.current.get("datasets")
    if datasets.nil?
      []
    else
      JSON.parse(datasets)
    end
  end

end