TODAY=$(shell date +'%Y-%m-%d')

all: reports/pulls.latest.csv reports/first-pr.latest.csv reports/active-contributors.latest.csv

reports/pulls.${TODAY}.csv:
	ruby lib/pulls.rb > $@

reports/first-pr.${TODAY}.csv: reports/pulls.${TODAY}.csv
	cat $< | ruby lib/first-pr.rb > $@

reports/active-contributors.${TODAY}.csv: reports/pulls.${TODAY}.csv
	cat $< | ruby lib/active-contributors.rb > $@

reports/pulls.latest.csv: reports/pulls.${TODAY}.csv
	ln -s $(realpath $<) $@

reports/first-pr.latest.csv: reports/first-pr.${TODAY}.csv
	ln -s $(realpath $<) $@

reports/active-contributors.latest.csv: reports/active-contributors.${TODAY}.csv
	ln -s $(realpath $<) $@

clean:
	rm -rf reports/*.latest.csv
