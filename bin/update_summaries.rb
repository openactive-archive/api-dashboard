#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

require 'environment'

restart = ARGV.size > 0 and ARGV[0].eql?('--restart')
restart_from_last_page = ARGV.size > 0 and ARGV[0].eql?('--last-page-restart')
datasets = DatasetsCache.all

for key in datasets.keys
  dataset = datasets[key]
  next unless dataset["uses-paging-spec"] and dataset["uses-opportunity-model"]

  summary = DatasetSummary.new(key)
  summary.restart if restart
  summary.restart_from_last_page if restart_from_last_page

  puts "\nUpdating summary for #{key}, starting from #{summary.last_page}"
  summary.update
  puts "Finished on #{summary.last_page}, #{summary.samples} samples taken"
  puts "Top activities are:\n#{summary.ranked_activities.join(', ')}"
  puts "Top boundaries are:\n#{summary.ranked_boundaries.join(', ')}"
end