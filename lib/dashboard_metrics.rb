class DashboardMetrics

  CONX = Bothan::Connection.new(ENV['BOTHANUSER'], ENV['BOTHANPASS'], ENV['BOTHANURL'])

  def self.all
    CONX.metrics.all
  end

end