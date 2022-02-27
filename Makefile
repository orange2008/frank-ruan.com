INFILES = $(shell find . -name '*.mdwn' -type f)
OUTPUT = /tmp/www/blogdeployment
OUTFILES = $(INFILES:.mdwn=/index.html)
LIST=$(addprefix $(OUTPUT)/, $(OUTFILES))

all: godeps $(LIST) $(OUTPUT)/index.html $(OUTPUT)/index.rss $(OUTPUT)/index.atom $(OUTPUT)/sitemap.txt $(OUTPUT)/404.html $(OUTPUT)/stats.js

godeps:
	go install github.com/orange2008/blog/...@latest

$(OUTPUT)/404.html: 404.html
	cat $< > $@

$(OUTPUT)/oh-no.html: oh-no.html
	cat $< > $@

$(OUTPUT)/thank-you.html: thank-you.html
	cat $< > $@

$(OUTPUT)/%/index.html: %.mdwn
	@mkdir -p $(@D)
	@header $< > $@
	@sed '/^\[\[/ d' $< | cmark --unsafe >> $@
	@footer $< >> $@
	@echo $< '→' $@

$(OUTPUT)/index.atom: $(LIST)
	feeds
	cat index.atom > $@

$(OUTPUT)/stats.js: stats.js
	cat $< > $@

$(OUTPUT)/sitemap.txt: $(LIST)
	sitemap > $@

$(OUTPUT)/index.rss: $(LIST)
	feeds
	cat index.rss > $@

$(OUTPUT)/index.html: $(LIST)
	@index > $@

upload: $(OUTPUT)/index.html
	@./deploy

clean: godeps
	@rm -rf $(OUTPUT) index.rss index.atom

.PHONY: setupredirects upload clean watch godeps
