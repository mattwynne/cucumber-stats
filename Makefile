TODAY=$(shell date +'%Y-%m-%d')

all: reports/pulls.latest.csv reports/first-pr.latest.csv reports/contributor-flow.latest.csv reports/open-issues.latest.csv reports/responsiveness.latest.csv reports/contributor-emails.latest.csv

reports/pulls.${TODAY}.csv: lib/pulls.rb
	ruby lib/pulls.rb > $@

reports/%.${TODAY}.csv: reports/pulls.${TODAY}.csv lib/%.rb
	cat $< | ruby lib/$*.rb > $@
.PRECIOUS: reports/%.${TODAY}.csv

reports/contributor-emails.${TODAY}.csv: reports/first-pr.${TODAY}.csv lib/contributor-emails.rb
	cat $< | ruby lib/contributor-emails.rb > $@
.PRECIOUS: reports/%.${TODAY}.csv

reports/%.latest.csv: reports/%.${TODAY}.csv
	cp $(realpath $<) $@

clean:
	rm -rf reports/*.latest.csv
	rm -rf reports/*.${TODAY}.csv
