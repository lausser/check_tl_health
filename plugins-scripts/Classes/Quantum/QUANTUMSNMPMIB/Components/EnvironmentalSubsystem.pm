package Classes::Quantum::QUANTUMSNMPMIB::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->get_snmp_objects('QUANTUM-SNMP-MIB', (qw(qDeviceName
      qAssignedName qLocation qVendorId qProductId qProductRev qState
      qTrapDescription qSenseKey qAsc qSerialNumber)));
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "Overall state is %s",
      $self->{qState});
  if ($self->{qState} eq "online") {
    $self->add_ok();
  } elsif ($self->{qState} eq "statenotavailable") {
    $self->add_unknown();
  } elsif ($self->{qState} eq "goingonline" ||
      $self->{qState} eq "available") {
    $self->add_warning();
  } else {
    # offline, unavailable
    $self->add_critical();
  }
}

