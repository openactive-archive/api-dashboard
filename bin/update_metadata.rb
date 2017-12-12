#!/usr/bin/env ruby
$:.unshift File.join( File.dirname(__FILE__), "..", "config")

puts require_relative '../config/environment'

force = ARGV.size > 0 and ARGV[0].eql?('-f') 

if force or DatasetsCache.needs_update?

  puts "Update required, fetching datasets metadata"

  result = DatasetsCache.update

  if result
    puts "Datasets meta updated"
  else
    puts "Datasets meta update failed"
  end

  puts "Updating endpoint availabilities"

  result = AvailabilityCache.update

  if result
    puts "Availabilities updated"
  else
    puts "Availabilities update failed"
  end

else

  puts "No update required, last update was #{DatasetsCache.last_updated.httpdate}"

end