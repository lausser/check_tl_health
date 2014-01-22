PLUGIN=check_tl_health

all: dedoc endoc
	$(RM) $(PLUGIN).html
	cat $(PLUGIN).de.html >> $(PLUGIN).html
	sed -ri '/col width/d' $(PLUGIN).html
	unix2dos $(PLUGIN).html

dedoc:
	asciidoc --unsafe --no-header-footer -a max-width=800 $(PLUGIN).de.txt

endoc:
	asciidoc --unsafe --no-header-footer -a max-width=800 $(PLUGIN).en.txt

clean:
	rm $(PLUGIN).de.html
