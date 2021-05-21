TODAY=$(shell date +'%Y-%m-%d')

data/pulls.${TODAY}.csv:
	ruby pulls.rb > data/pulls.${TODAY}.csv

data/pulls.latest.csv: data/pulls.${TODAY}.csv
	cp data/pulls.${TODAY}.csv data/pulls.latest.csv