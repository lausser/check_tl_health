package Classes::Storagetek::SL4000::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('STREAMLINE-TAPE-LIBRARY4J-MIB', (qw(
      ksComplexReadyStatus ksComplexName ksComplexControlState
      ksComplexOperationalState ksComplexLibraryCount
      ksComplexPartitionCount ksComplexDeviceCount ksComplexDriveCount
      ksComplexCellCount
  )));
  $self->get_snmp_tables('STREAMLINE-TAPE-LIBRARY4J-MIB', [
    ['lsmconfigs', 'ksLibDTOTable', 'Classes::Storagetek::SL4000::Components::EnvironmentalSubsystem::LibDTO'],
    #['kscells', 'ksCellsDTOTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "complex ready status is %s, operational state is %s",
      $self->{ksComplexReadyStatus},
      $self->{ksComplexOperationalState});
  if ($self->{ksComplexReadyStatus} eq "false") {
    $self->add_critical();
  } elsif ($self->{ksComplexOperationalState} =~ /^(initializing|operative|startup)/) {
    $self->add_ok();
  } elsif ($self->{ksComplexOperationalState} eq "unknown") {
    $self->add_unknown();
  } else {
    $self->add_critical();
  }
  $self->SUPER::check();
}


package Classes::Storagetek::SL4000::Components::EnvironmentalSubsystem::LibDTO;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "Library %s has OperationalState %s",
      $self->{ksLibDTOName},
      $self->{ksLibDTOOperationalState});
  if ($self->{ksLibDTOOperationalState} =~ /^(initializing|operative)/) {
    $self->add_ok();
  } elsif ($self->{ksLibDTOOperationalState} eq "degraded") {
    $self->add_warning();
  } elsif ($self->{ksLibDTOOperationalState} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{ksLibDTOOperationalState} eq "powered-off") {
    $self->add_critical_mitigation();
  } else {
    $self->add_critical();
  }
}


