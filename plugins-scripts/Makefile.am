libexec_SCRIPTS=check_tl_health
GL_MODULES=\
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Extraopts.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Getopt.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/TableItem.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/SysDescPrettify.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/MIB2MIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SNMPFRAMEWORKMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/BDTMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/ADICINTELLIGENTSTORAGEMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/ADICMANAGEMENTMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/QUANTUMSMALLTAPELIBRARYMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/QUANTUMSNMPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SEMIMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SLHWLIBT950MIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SPECTRALOGICGLOBALREG.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SPECTRALOGICGLOBALREGSLHARDWARESLLIBRARIESSLTSERIES.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/UCDSNMPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/HOSTRESOURCESMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/CSF.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/TableItem.pm
EXTRA_MODULES=\
  Classes/Quantum/QUANTUMSNMPMIB/Components/EnvironmentalSubsystem.pm \
  Classes/Quantum/QUANTUMSNMPMIB.pm \
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
  Classes/HOSTRESOURCESMIB/Component/CpuSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/DeviceSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/DiskSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/EnvironmentalSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/MemSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/UptimeSubsystem.pm \
  Classes/HOSTRESOURCESMIB.pm \
  Classes/Device.pm

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

EXTRA_DIST=$(libexec_SCRIPTS).pl $(EXTRA_MODULES) $(GL_MODULES)

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
		$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst >> $@; \
	done
	$(ECHO) "package main;" >> $@
	$(CAT) $(libexec_SCRIPTS).pl | $(AWK) -f ./subst >> $@
	chmod +x $@

