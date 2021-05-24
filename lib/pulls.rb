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

PrStat = Struct.new(:repo, :pr, :url, :creator, :created_at) do
  def to_csv
    [repo, pr, url, creator, created_at].join(",")
  end
end

puts "repo, pr, url, creator, created at"
repos = gh.repos(org_name).select { |repo| !repo.archived }
pulls = repos.each_with_index.map { |repo, index| 
  $stderr.puts "Fetching pulls for repo #{index + 1}/#{repos.length}"
  gh.pulls(repo[:id], query: { state: 'all' }) 
}.flatten.sort_by(&:created_at)
stats = pulls.map do |pr|
  PrStat.new(pr.base.repo.name, pr.number, pr.html_url, pr.user.login, pr.created_at)
end
stats.compact.each { |stat| puts stat.to_csv }
