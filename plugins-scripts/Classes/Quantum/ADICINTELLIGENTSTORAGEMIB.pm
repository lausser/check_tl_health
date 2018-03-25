package Classes::Quantum::ADICINTELLIGENTSTORAGEMIB;
our @ISA = qw(Classes::Quantum);
use strict;

sub init {
  my $self = shift;
  #      ADIC-INTELLIGENT-STORAGE-MIB     ADIC-MANAGEMENT-MIB
  # alt  1.31 1.32 1.33                   1.92 1.93
  # neu  1.18 1.19 1.20 1.21 1.22 1.23    1.38 1.41 1.42 1.43 1.44 1.45
  $self->get_snmp_objects('ADIC-INTELLIGENT-STORAGE-MIB', (qw(productMibVersion)));
  # steckt in intell-stor-mib, meint aber version von mgmgt-mib
  $self->require_mib('ADIC-INTELLIGENT-STORAGE-MIB');
  $self->require_mib('ADIC-MANAGEMENT-MIB');
  if (grep { $self->{productMibVersion} eq $_ } qw(1.18 1.19 1.20 1.21 1.22 1.23)) {
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB::1.33'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-MANAGEMENT-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-MANAGEMENT-MIB::1.93'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB::1.33'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-MANAGEMENT-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-MANAGEMENT-MIB::1.93'};
  } else {
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-INTELLIGENT-STORAGE-MIB::1.23'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-MANAGEMENT-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ADIC-MANAGEMENT-MIB::1.45'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-INTELLIGENT-STORAGE-MIB::1.23'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-MANAGEMENT-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ADIC-MANAGEMENT-MIB::1.45'};
  }
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Quantum::ADICINTELLIGENTSTORAGEMIB::Components::EnvironmentalSubsystem');
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

