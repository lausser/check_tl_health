## Process this file with automake to produce Makefile.in

SUBDIRS = plugins-scripts

dist-hook:
	rm -f t/var/tmp/*
	rm -f t/var/adm/*
	find $(distdir) -type f -exec fromdos -v {} \;
	make

