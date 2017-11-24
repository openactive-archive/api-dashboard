#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

require 'environment'

puts "Updating datasets cache"

result = DatasetsCache.update

if result
  puts "Datasets cache updated"
else
  puts "Datsets cache update failed"
end

puts "Updating endpoint availabilities"

result = AvailabilityCache.update

if result
  puts "Availabilities updated"
else
  puts "Availabilities update failed"
end
