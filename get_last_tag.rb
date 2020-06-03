#! /usr/bin/env ruby

# Get the last release

require_relative './lib/github'

release_tag = get_last_release()

if release_tag.empty?
  puts "Could not determine the last release"
  exit 1
end

puts release_tag
