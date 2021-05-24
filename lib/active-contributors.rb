#!/usr/bin/env ruby
require 'date'
pulls = {}
Pull = Struct.new(:repo, :pr, :url, :creator, :created_at)

ARGF.each_with_index do |line, index|
  next if index < 1
  fields = line.split(",")
  date = fields[4] = Date.parse(fields[4])
  pulls[date] ||= []
  pulls[date] << Pull.new(*fields)
end

window_days = 90
min_pulls = 3

((pulls.keys.min + window_days)..pulls.keys.max).each { |day|
  contributors = {}
  ((day - window_days)..day).each do |window_day|
    window_day_pulls = (pulls[window_day] || [])
    creators = window_day_pulls.map(&:creator)
    creators.each { |name|
      contributors[name] ||= 0
      contributors[name] += 1
    }
  end
  active_contributors = contributors.to_a.filter do |name, pulls|
    pulls >= min_pulls
  end
  puts "#{day},#{active_contributors.count}"
}
