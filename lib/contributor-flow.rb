#!/usr/bin/env ruby
require 'date'

pulls_on = {}
Pull = Struct.new(:repo, :pr, :url, :creator, :created_at)

require 'yaml'

DAYS_TO_INACTIVE = 90
PULLS_TO_ACTIVE = 1

class Contributor
  attr_reader :name

  def initialize(name, pulls = [])
    @name, @pulls = name, pulls
  end

  def with_pull(pull)
    Contributor.new(name, @pulls << pull)
  end

  def status_on(day)
    Contributions.new(pulls_up_to(day), day).status
  end

  def pulls_up_to(day)
    @pulls.reverse.select { |pull| pull.created_at <= day }.reverse
  end
end

class Contributions
  attr_reader :pulls
  
  def initialize(pulls, day)
    @pulls = pulls
    @day = day
  end

  def status
    return :none if pulls.empty?
    return :inactive if days_since_last_pull >= DAYS_TO_INACTIVE
    return :new if pulls.length <= PULLS_TO_ACTIVE
    :active
  end

  def days_since_last_pull 
    (@day - pulls.last.created_at).to_i
  end
end

contributors = {}
STDIN.read.lines.each_with_index do |line, index|
  next if index < 1
  fields = line.split(",")
  date = fields[4] = Date.parse(fields[4])
  pull = Pull.new(*fields)
  pulls_on[date] = pulls_on.fetch(date) { [] } << pull
  contributors[pull.creator] ||= contributors.fetch(pull.creator) { Contributor.new(pull.creator) }
  contributors[pull.creator] = contributors[pull.creator].with_pull(pull)
end

from = pulls_on.keys.min
to = pulls_on.keys.max

contributors_on = (from..to).map { |day|
  status = { new: [], active: [], inactive: [] }
  [
    day,
    contributors.values.reduce(status) { |statuses, contributor| 
      status = contributor.status_on(day)
      statuses[status] << contributor.name if status != :none
      statuses
    }
  ]
}.to_h

if ARGV[0] == "--show-current-new"
  (contributors_on[to][:new]).sort.map do |login|
    pull = pulls_on.values.flatten.find { |p| p.creator == login }
    puts "https://github.com/#{login} #{pull.url}"
  end
  exit 0
end

if ARGV[0] == "--show-current-active"
  (contributors_on[to][:active]).sort.map do |login|
    puts "https://github.com/#{login}"
  end
  exit 0
end

puts "date,new,active,inactive"
contributors_on.each do |day, statuses|
  puts [day, statuses[:new].length, statuses[:active].length, statuses[:inactive].length].join(",")
end
