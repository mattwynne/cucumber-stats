#!/usr/bin/env ruby
require 'date'
pulls = []
Pull = Struct.new(:repo, :pr, :url, :creator, :created_at)

ARGF.each_with_index do |line, index|
  next if index < 1
  fields = line.split(",")
  fields[4] = Date.parse(fields[4])
  pulls << Pull.new(*fields)
end
puts "repo,pr,url,username,date,total"
puts pulls.uniq { |pull| pull.creator }.each_with_index.map { |p, i| [p.repo, p.pr, p.url, p.creator, p.created_at, i+1].join(", ") }.join("\n")
