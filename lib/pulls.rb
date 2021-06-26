require 'octokit'
gh = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']
gh.auto_paginate = true

PrStat = Struct.new(:repo, :pr, :url, :creator, :created_at) do
  def to_csv
    [repo, pr, url, creator, created_at].join(",")
  end
end

repos = gh.repos("cucumber").select { |repo| !repo.archived }
pulls = repos.each_with_index.map { |repo, index| 
  $stderr.puts "Fetching pulls for repo #{index + 1}/#{repos.length}"
  gh.pulls(repo[:id], query: { state: 'all' }) 
}.flatten.sort_by(&:created_at)
stats = pulls.map { |pr|
  PrStat.new(pr.base.repo.name, pr.number, pr.html_url, pr.user.login, pr.created_at)
}

puts "repo,pr,url,creator,created at"
stats.compact.each { |stat| puts stat.to_csv }
