TODAY=$(shell date +'%Y-%m-%d')

all: reports/pulls.latest.csv reports/first-pr.latest.csv reports/contributor-flow.latest.csv

reports/pulls.${TODAY}.csv: lib/pulls.rb
	ruby lib/pulls.rb > $@

reports/%.${TODAY}.csv: reports/pulls.${TODAY}.csv lib/%.rb
	cat $< | ruby lib/$*.rb > $@

reports/%.latest.csv: reports/%.${TODAY}.csv
	ln -sf $(realpath $<) $@
