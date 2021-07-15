require 'date'
require 'csv'

pattern = File.dirname(__FILE__) + '/../reports/open-issues.[0-9]*.csv'
files = Dir.glob(pattern)

Result = Struct.new(:date, :total_ok, :total, :percent_ok) do
  def total_not_ok
    total - total_ok
  end

  def to_s
    [date, total_ok, total_not_ok, total, percent_ok].join(",")
  end
end

results = files.map do |filename|
	date = Date.parse(filename)
  data = CSV.parse(File.read(filename), headers: true, converters: :numeric)
  total_ok = data.reduce(0) do |count, row|
    if row["days since last activity"] > 90
      count
    else
      count + 1
    end
  end
  percent_ok = (Float(total_ok) / Float(data.count) * 100.0).round(1)
  Result.new(date, total_ok, data.count, percent_ok)
end
puts "date,number of issues active in past 90 days,number of issues not active in past 90 days,total number of issues,percentage of issues active in past 90 days"
results.each do |result|
  puts result
end