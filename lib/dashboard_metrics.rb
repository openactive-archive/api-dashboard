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

end