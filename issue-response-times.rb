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

IssueStat = Struct.new(:repo, :issue, :url, :days_since_last_update) do
  def to_csv
    [repo, issue, url, days_since_last_update].join(",")
  end
end

puts "repo, issue, url, days since last activity"
repos = gh.repos(org_name).select { |repo| !repo.archived }
repos.each do |repo|
  issues = gh.issues(repo[:id], query: { state: 'open' })
  stats = issues.map do |issue|
    days_since_last_activity = (Date.parse(Time.now.to_s) - Date.parse(issue[:updated_at].to_s)).to_i
    puts IssueStat.new(repo[:name], issue[:number], issue[:html_url], days_since_last_activity).to_csv
  end
end
