package MyAdic;
our @ISA = qw(GLPlugin::SNMP);

sub init {
  my $self = shift;
  #      ADIC-INTELLIGENT-STORAGE-MIB     ADIC-MANAGEMENT-MIB
  # alt  1.31 1.32 1.33                   1.92 1.93
  # neu  1.18 1.19 1.20 1.21 1.22 1.23    1.38 1.41 1.42 1.43 1.44 1.45
  $self->get_snmp_objects('ADIC-INTELLIGENT-STORAGE-MIB', (qw(productMibVersion)));
  # steckt in intell-stor-mib, meint aber version von mgmgt-mib
  if (grep { $self->{productMibVersion} eq $_ } qw(1.18 1.19 1.20 1.21 1.22 1.23)) {
    $GLPlugin::SNMP::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $GLPlugin::SNMP::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB::1.33'};
    $GLPlugin::SNMP::mibs_and_oids->{'ADIC-MANAGEMENT-MIB'} =
        $GLPlugin::SNMP::mibs_and_oids->{'ADIC-MANAGEMENT-MIB::1.93'};
    $GLPlugin::SNMP::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $GLPlugin::SNMP::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB::1.33'};
    $GLPlugin::SNMP::definitions->{'ADIC-MANAGEMENT-MIB'} =
        $GLPlugin::SNMP::definitions->{'ADIC-MANAGEMENT-MIB::1.93'};
  } else {
    $GLPlugin::SNMP::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $GLPlugin::SNMP::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB::1.23'};
    $GLPlugin::SNMP::mibs_and_oids->{'ADIC-MANAGEMENT-MIB'} =
        $GLPlugin::SNMP::mibs_and_oids->{'ADIC-MANAGEMENT-MIB::1.45'};
    $GLPlugin::SNMP::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $GLPlugin::SNMP::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB::1.23'};
    $GLPlugin::SNMP::definitions->{'ADIC-MANAGEMENT-MIB'} =
        $GLPlugin::SNMP::definitions->{'ADIC-MANAGEMENT-MIB::1.45'};
  }
  #if ($self->mode =~ /device::hardware::health/) {
  if ($self->mode =~ /my::adic::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::EnvironmentalSubsystem');
    if (! $self->check_messages()) {
      $self->add_ok('hardware working fine');
    }
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } else {
    $self->no_such_mode();
  }
}
# 

package Classes::Adic::Components::EnvironmentalSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('ADIC-INTELLIGENT-STORAGE-MIB', (qw(
      productName productDisplayName productDescription
      productVendor productVersion productDisplayVersion
      productLibraryClass productSerialNumber
      agentGlobalStatus agentLastGlobalStatus agentTimeStamp 
  )));
  $self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::ComponentSubsystem');
# componentStatus: ok
}

sub dump {
  my $self = shift;
  printf "[ENVIRONMENTALSUBSYSTEM]\n";
  foreach (qw(
      productName productDisplayName productDescription
      productVendor productVersion productDisplayVersion
      productLibraryClass productSerialNumber
      agentGlobalStatus agentLastGlobalStatus agentTimeStamp)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
}

package Classes::Adic::Components::ComponentSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  use Data::Dumper;
  $self->get_snmp_tables('ADIC-INTELLIGENT-STORAGE-MIB', [
    ['components', 'componentTable', 'GLPlugin::TableItem'],
    ['powersupplies', 'powerSupplyTable', 'GLPlugin::TableItem'],
    ['voltages', 'voltageSensorTable', 'GLPlugin::TableItem'],
    ['temperatures', 'temperatureSensorTable', 'GLPlugin::TableItem'],
    ['fans', 'coolingFanTable', 'GLPlugin::TableItem'],

    ['fans', 'coolingFanTable', 'GLPlugin::TableItem'],
  ]);
my @tables = ();
# logicalLibraryTable
# persistentDataTable
# phDriveTable phDriveWriteErrors, phDriveReadErrors, phDriveRasStatus, phDriveOnlineStatus, phDrivePowerStatus
# phGeneralInfoTable onlineStatus readiness totalFreeCapacity totalRawCapacity totalUsedCapacity physLibraryDoorStatus
# rasFruStatTable
# rasReportTable
# rasSystemStatusTable

foreach (qw(logicalLibraryTable persistentDataTable phDriveTable phGeneralInfoTable rasFruStatTable rasReportTable rasSystemStatusTable)) {

#foreach  (qw(trapPayloadTable globalStatusTable rasSystemStatusTable rasTicketTable rasReportTable rasFruStatTable rasTicketFilterTable globalEthernetTable systemManagerTable softwareInstallationTable persistentDataTable userTable licenseKeyTable licenseFeatureTable licensableFeatureTable registrationTable logTable logSnapshotTable phGeneralInfoTable phIeSlotTable phDriveTable phDriveStatHistoryTable fcDrivePortTable phMediaTable phTransportTable phTransportDomainTable phCleaningMediaTable mediaDomainTable mediaTypeTable phFrameTable phSegmentTable phStorageSegTable phIeSegTable phIeStationTable phDriveSegTable phCleaningSegTable phStorageSlotTable loGeneralInfoTable autoPartitionTable vendorIdTable productIdTable logicalLibraryTable loSegmentTable loSegmentBelongsToTable loStorageSegTable loIeSegTable loDriveSegTable loStorageSlotTable loIeSlotTable loDriveTable loStatisticsTable)) {
eval sprintf "package Classes::Adic::Components::ComponentSubsystem::%s;\nour \@ISA = qw(GLPlugin::SNMP::TableItem);\n", $_;
 push(@tables, [$_, $_, 'Classes::Adic::Components::ComponentSubsystem::'.$_]);
}
  $self->get_snmp_tables('ADIC-MANAGEMENT-MIB', \@tables);
}

sub check {
  my $self = shift;
  foreach (@{$self->{components}}) {
    $_->check();
  }
}


package Classes::Adic::Components::ComponentSubsystem::Component;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'component %s is %s and %s',
      $self->{componentDisplayName}, $self->{componentControl},
      $self->{componentStatus});
  if ($self->{componentControl} eq 'online') {
    if ($self->{componentStatus} eq 'failed') {
      $self->add_critical();
    } elsif ($self->{componentStatus} eq 'warning') {
      $self->add_warning();
    } elsif ($self->{componentStatus} eq 'unknown') {
      $self->add_unknown();
    } # else ok oder unused
  }
if (ref($self) =~ /rasSystemStatusTable/) {
 $self->{rasStatusGroupLastChange};
}
}


