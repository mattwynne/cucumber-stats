#!/usr/bin/env ruby
require 'date'
creators = []
Creator = Struct.new(:email)

require 'octokit'
gh = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']

ARGF.each_with_index do |line, index|
  next if index < 1
  fields = line.split(",")
  username = fields[3]
  email = gh.user(username).email
  creators << Creator.new(email) if email
end
puts "email"
puts creators.map { |creator| creator.email }.join("\n")