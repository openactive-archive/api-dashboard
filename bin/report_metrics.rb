#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

require 'environment'

puts "Connecting to Bothan (#{DashboardMetrics::CONX.inspect})"

puts "Reporting count of all datasets"
response = DashboardMetrics.report_dataset_count
begin
  puts "Response: #{response.inspect}"
rescue => e
  puts "Couldn't report standard datasets:\n#{e}"
end

puts "\nReporting count of standard datasets"
response = DashboardMetrics.report_standard_datasets
begin
  puts "Response: #{response.inspect}"
rescue => e
  puts "Couldn't report standard datasets:\n#{e}"
end