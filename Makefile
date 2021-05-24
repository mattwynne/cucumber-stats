TODAY=$(shell date +'%Y-%m-%d')

all: reports/pulls.latest.csv reports/first-pr.latest.csv

reports/pulls.${TODAY}.csv:
	ruby pulls.rb > $@

reports/pulls.latest.csv: reports/pulls.${TODAY}.csv
	ln -s $(realpath $<) $@

reports/first-pr.${TODAY}.csv: reports/pulls.${TODAY}.csv
	cat $< | ruby first-pr.rb > $@

reports/first-pr.latest.csv: reports/first-pr.${TODAY}.csv
	ln -s $(realpath $<) $@

clean:
	rm -rf reports/*.latest.csv
