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

end