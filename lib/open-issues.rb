require 'octokit'
gh = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']
gh.auto_paginate = true

IssueStat = Struct.new(:repo, :issue, :url, :days_since_last_activity) do
  def to_csv
    [repo, issue, url, days_since_last_activity].join(",")
  end
end

repos = gh.repos("cucumber").select { |repo| !repo.archived }
stats = repos.each_with_index.map { |repo, index|
  $stderr.puts "Fetching issues for repo #{index + 1}/#{repos.length}"
  gh.issues(repo[:id], query: { state: 'open' }).map { |issue|
    days_since_last_activity = (Date.parse(Time.now.to_s) - Date.parse(issue[:updated_at].to_s)).to_i
    IssueStat.new(repo[:name], issue[:number], issue[:html_url], days_since_last_activity)
  }
}.flatten.sort_by(&:days_since_last_activity).reverse

puts "repo, issue, url, days since last activity"
stats.each do |stat|
  puts stat.to_csv 
end