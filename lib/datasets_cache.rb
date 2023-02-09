class Datasets

  DIRECTORY="http://dataset-directory.herokuapp.com/datasets"

  #Returns a hash of datasets keyed on a unique id.
  def self.list
    results = JSON.parse(RestClient.get(DIRECTORY))
    datasets = {}
    results.each do |result|
      begin
        next unless result["publish"] && result["publish"] == true
        dataset_key = result["dataurl"]
        dataset_key.chomp!("/")
        datasets.merge!({ dataset_key => result })
      rescue => e
        #ignore errors
      end
    end
    datasets
  end
end

class DatasetsCache

  def self.update
    begin
      datasets = Datasets.list
      datasets = update_conformance(datasets)
      datasets = update_github_issues(datasets)
      datasets = update_has_coordinates(datasets)
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

  def self.update_conformance(datasets)
    for dataset_key in datasets.keys
      dataset = datasets[dataset_key]
      begin
        feed = OpenActive::Feed.new(dataset["dataurl"])
        page = feed.fetch
        datasets[dataset_key].merge!({
          "uses-opportunity-model" => page.declares_oa_context?.eql?(true),
          "uses-paging-spec" => page.valid_rpde?
        })
      rescue
        #do nothing
      end
    end
    datasets
  end

  def self.update_has_coordinates(datasets)
    for dataset_key in datasets.keys
      dataset = datasets[dataset_key]
      begin
        summary = DatasetSummary.new(dataset_key)
        datasets[dataset_key].merge!({
          "has-coordinates" => summary.ranked_boundaries.size > 0
        })
      rescue
        #do nothing
      end
    end
    datasets
  end

  def self.update_github_issues(datasets)
    for dataset_key in datasets.keys
      dataset = datasets[dataset_key]
      begin
        git_resp = RestClient.get(dataset["discussionurl"].gsub('https://github.com/','https://api.github.com/repos/'))
        issues = JSON.parse(git_resp.body)
        datasets[dataset_key].merge!({ "github-issues" => issues.size })
      rescue
        #do nothing
      end
    end
    datasets
  end

end