require 'openactive'
require 'json'
require 'redis'

class DatasetsCache

  def self.update
    begin
      datasets = OpenActive::Datasets.list
      result = Redis.current.set("datasets", datasets.to_json).eql?("OK")
      Redis.current.set("last_updated", Time.now.to_i) if result
      return result
    rescue
      return false
    end
  end

  def self.all
    datasets = Redis.current.get("datasets")
    if datasets.nil?
      {}
    else
      JSON.parse(datasets)
    end
  end

  def self.last_updated
    last_updated = Redis.current.get("last_updated")
    return nil if last_updated.nil?
    return Time.at(last_updated.to_i)
  end

  def self.needs_update?
    last_updated = self.last_updated
    return true if last_updated.nil?
    thirty_minutes_ago = Time.now - 30*60
    thirty_minutes_ago >= last_updated
  end

end