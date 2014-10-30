#!/usr/bin/env ruby

# 
# This is a sample handler from http://sensuapp.org/docs/latest/handlers.
# Likely only useful for testing/debugging, included in the formula for just
# that purpose.
#

require 'rubygems'
require 'json'

# Read event data
event = JSON.parse(STDIN.read, :symbolize_names => true)

# Write the event data to a file
file_name = "/tmp/sensu_#{event[:client][:name]}_#{event[:check][:name]}"
File.open(file_name, 'w') do |file|
  file.write(JSON.pretty_generate(event))
end
