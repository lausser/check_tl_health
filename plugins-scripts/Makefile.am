## Process this file with automake to produce Makefile.in

SED=/bin/sed
GREP=/bin/grep
CAT=/bin/cat
ECHO=/bin/echo
if DISABLE_STANDALONE
STANDALONE = no
else
STANDALONE = yes
endif

SUFFIXES = .pl .pm .sh

VPATH=$(top_srcdir) $(top_srcdir)/plugins-scripts $(top_srcdir)/plugins-scripts/t

libexec_SCRIPTS=check_tl_health
GL_MODULES=\
  ../lib/Monitoring/GLPlugin.pm \
  ../lib/Monitoring/GLPlugin/SNMP.pm \
  ../lib/Monitoring/GLPlugin/UPNP.pm
EXTRA_MODULES=\
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
  Classes/UCDMIB/Components/MemSubsystem.pm \
  Classes/UCDMIB/Components/CpuSubsystem.pm \
  Classes/UCDMIB.pm \
  Classes/Adic/Components/ComponentSubsystem.pm \
  Classes/Adic/Components/EnvironmentalSubsystem.pm \
  Classes/Adic/Components/RasSubsystem.pm \
  Classes/Adic.pm \
  Classes/BDT/FlexStorII/Components/EnvironmentalSubsystem.pm \
  Classes/BDT/FlexStorII.pm \
  Classes/BDT.pm \
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
	$(ECHO) "# nagios: -epn" >> $@
	$(ECHO) >> $@
	if [ "${STANDALONE}" == "yes" ]; then \
		$(ECHO) i am standalone; \
		for m in ${GL_MODULES}; do \
			$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst >> $@; \
		done \
	fi
	for m in ${EXTRA_MODULES}; do \
		$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst | $(GREP) -v "use Nagios::Plugin" >> $@; \
	done
	$(ECHO) "package main;" >> $@
	$(CAT) $(libexec_SCRIPTS).pl | $(AWK) -f ./subst >> $@
	chmod +x $@

