# Personal access token with `read:org` and `repo` access
# Created via https://github.com/settings/tokens/new
access_token = ENV['GITHUB_TOKEN']

# Name of organization you'd like to generate the report for
org_name = "cucumber"

# Init an authenticated client
# See http://octokit.github.io/ for .net and other languages
require 'octokit'
gh = Octokit::Client.new :access_token => access_token
gh.auto_paginate = true

repos = gh.repos(org_name).select { |repo| !repo.archived }
repos.each do |repo|
  next if repo.default_branch == "main"
  next if repo.description and repo.description.include? "[READ-ONLY]"
  next if repo.description and repo.description.include? "[READ ONLY]"
  next if repo.description and repo.description.include? "[READONLY]"
  puts repo.html_url
end
