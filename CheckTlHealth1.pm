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
  #$self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::ComponentSubsystem');
  $self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::RasSubsystem');
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

package Classes::Adic::Components::RasSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  use Data::Dumper;
  $self->get_snmp_tables('ADIC-MANAGEMENT-MIB', [
    ['rassystems', 'rasSystemStatusTable', 'Classes::Adic::Components::RasSubsystem::RasSystem'],
  ]);
}

package Classes::Adic::Components::RasSubsystem::RasSystem;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info('checking ras subsystems');
  $self->add_info(sprintf '%s has status %s',
      $self->{rasStatusGroupIndex}, $self->{rasStatusGroupStatus});
  if ($self->{rasStatusGroupStatus} ne 'good' ||
      $self->{rasStatusGroupStatus} ne 'informational') {
    if ($self->{rasStatusGroupStatus} eq 'failed') {
      $self->add_critical();
    } elsif ($self->{rasStatusGroupStatus} eq 'degraded') {
      $self->add_warning();
    } elsif ($self->{rasStatusGroupStatus} eq 'warning') {
      $self->add_warning();
    } elsif ($self->{rasStatusGroupStatus} eq 'unknown') {
      $self->add_unknown();
    } elsif ($self->{rasStatusGroupStatus} eq 'invalid') {
      $self->add_unknown();
    } # else ok oder unused
  }
}


package Classes::Adic::Components::ComponentSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('ADIC-INTELLIGENT-STORAGE-MIB', [
    ['components', 'componentTable', 'Classes::Adic::Components::ComponentSubsystem::Component'],
    #['powersupplies', 'powerSupplyTable', 'GLPlugin::TableItem'],
    #['voltages', 'voltageSensorTable', 'GLPlugin::TableItem'],
    #['temperatures', 'temperatureSensorTable', 'GLPlugin::TableItem'],
    #['fans', 'coolingFanTable', 'GLPlugin::TableItem'],
  ]);
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


