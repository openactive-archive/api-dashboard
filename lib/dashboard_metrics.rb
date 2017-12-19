class DashboardMetrics

  CONX = Bothan::Connection.new(ENV['BOTHANUSER'], ENV['BOTHANPASS'], ENV['BOTHANURL'])

  def self.all
    CONX.metrics.all
  end

  def self.dataset_count
    DatasetsCache.all.keys.size
  end

  def self.report_dataset_count
    CONX.metrics.create('dataset-count', self.dataset_count)
  end

  def self.standard_datasets
    count = 0
    datasets = DatasetsCache.all
    datasets.keys.each do |k|
      count +=1 if datasets[k]["uses-opportunity-model"] and datasets[k]["uses-paging-spec"] 
    end
    count
  end

  def self.report_standard_datasets
    CONX.metrics.create('standard-datasets', self.standard_datasets)
  end

  def self.local_authorities_sample
    max_local_authorities = 418
    dataset_keys = DatasetsCache.all.keys
    result = dataset_keys.map do |k|
      summary = DatasetSummary.new(k)
      boundaries = summary.ranked_boundaries(max_local_authorities)
    end
    result.flatten.uniq.size
  end

  def self.report_local_authorities_sample
    CONX.metrics.create('local-authorities-sample', self.local_authorities_sample)
  end

end