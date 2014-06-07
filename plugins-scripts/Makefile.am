## Process this file with automake to produce Makefile.in

SED=/bin/sed
GREP=/bin/grep
CAT=/bin/cat
ECHO=/bin/echo

SUFFIXES = .pl .pm .sh

VPATH=$(top_srcdir) $(top_srcdir)/plugins-scripts $(top_srcdir)/plugins-scripts/t

libexec_SCRIPTS=check_tl_health
MY_MODULES=
EXTRA_MODULES=\
  GLPlugin.pm \
  GLPluginSNMP.pm \
  Classes/Quantum/I40I80/Components/EnvironmentalSubsystem.pm \
  Classes/Quantum/I40I80/Components/LogicalLibrarySubsystem.pm \
  Classes/Quantum/I40I80/Components/DriveSubsystem.pm \
  Classes/Quantum/I40I80.pm \
  Classes/Quantum.pm \
  Classes/HP/SEMIMIB/Components/EnvironmentalSubsystem.pm \
  Classes/HP/SEMIMIB.pm \
  Classes/HP.pm \
  Classes/Spectralogic/TSeries/T950/Components/EnvironmentalSubsystem.pm \
  Classes/Spectralogic/TSeries/T950.pm \
  Classes/Spectralogic/TSeries.pm \
  Classes/Spectralogic.pm \
  Classes/MibsAndOids.pm \
  Classes/Device.pm
EXTRA_DIST=check_tl_health.pl $(EXTRA_MODULES)

CLEANFILES=$(libexec_SCRIPTS)

AM_INSTALL_PROGRAM_FLAGS=@INSTALL_OPTS@

.pm :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.pl :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.sh :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

$(libexec_SCRIPTS) : $(EXTRA_DIST)
	$(ECHO) "#! #PERL# -w" | $(AWK) -f ./subst > $@
	$(ECHO) "# nagios: +epn" >> $@
	$(ECHO) >> $@
	for m in ${EXTRA_MODULES}; do \
		$(SED) -e 's/^1;//g' < $$m | $(AWK) -f ./subst | $(GREP) -v "use Nagios::Plugin" >> $@; \
	done
	$(ECHO) "package main;" >> $@
	$(CAT) check_tl_health.pl | $(AWK) -f ./subst >> $@
	chmod +x $@
#| $(GREP) -v "use Nagios" >> $@;

