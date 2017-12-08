#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

require 'environment'

restart = ARGV.size > 0 and ARGV[0].eql?('--restart') 
datasets = DatasetsCache.all

for key in datasets.keys
  dataset = datasets[key]
  next unless dataset["uses-paging-spec"] and dataset["uses-opportunity-model"]

  summary = DatasetSummary.new(key)
  summary.restart if restart

  puts "\nHarvesting summary for #{key}, starting from #{summary.dataset_uri}"
  summary.update
  puts "Finished on #{summary.last_page}, #{summary.samples} samples taken, top activities are:\n#{summary.ranked_activities.join(', ')}"
end