#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

require 'environment'

restart = ARGV.size > 0 and ARGV[0].eql?('--restart') 
datasets = DatasetsCache.all

for key in datasets.keys
  dataset = datasets[key]
  next unless dataset["uses-paging-spec"] and dataset["uses-opportunity-model"]

  if restart
    Redis.current.hdel(key, "activity_samples")
    Redis.current.hdel(key, "last_page")
  end

  summary = DatasetSummary.new(key)
  puts "\nHarvesting summary for #{key}, starting from #{summary.dataset_uri}"
  summary.harvest
  puts "Finished on #{summary.last_page}, #{summary.activity_samples} samples taken, top activities are:\n#{summary.ranked_activities.join(', ')}"
end