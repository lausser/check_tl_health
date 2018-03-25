package Classes::Quantum::ADICTAPELIBRARYMIB::Components::DriveSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('ADIC-TAPE-LIBRARY-MIB', [
      ['physicalDrive', 'physicalDriveTable', 'Classes::Quantum::ADICTAPELIBRARYMIB::Components::PhysicalDrive'],
  ]);
  $self->get_snmp_objects('ADIC-TAPE-LIBRARY-MIB', (qw(
      numPhDrives driveStatus overallPhDriveReadinessStatus)));
}

sub check {
  my $self = shift;
  $self->add_info('checking physical drives');
  $self->add_info(sprintf 'overall drive status online=%s readyness=%s',
      $self->{driveStatus},
      $self->{overallPhDriveReadinessStatus});
  if ($self->{driveStatus} =~ /pending/i) {
    $self->add_warning();
  } elsif ($self->{driveStatus} eq 'offline') {
    $self->add_critical();
  }
  foreach (@{$self->{physicalDrive}}) {
    $_->check();
  }
  
}


package Classes::Quantum::ADICTAPELIBRARYMIB::Components::PhysicalDrive;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{phDriveIndex} ||= $self->{flat_indices};
  $self->add_info(sprintf 'drive %d states: online=%s ras=%s cleaning=%s',
      $self->{phDriveIndex}, $self->{phDriveState},
      $self->{phDriveRasStatus}, $self->{phDriveNeedsCleaning});
  if ($self->{phDriveState} =~ /pending/i) {
    $self->set_level_warning();
  } elsif ($self->{phDriveState} eq 'offline') {
    $self->set_level_critical();
  }
  if ($self->{phDriveRasStatus} eq 'degraded' or $self->{phDriveRasStatus} eq 'warning') {
    $self->set_level_warning();
  } elsif ($self->{phDriveRasStatus} eq 'unknown') {
    $self->set_level_unknown();
  } elsif ($self->{phDriveRasStatus} eq 'good' or $self->{phDriveRasStatus} eq 'informational') {
  } else {
    $self->set_level_critical();
  }
  if ($self->{phDriveNeedsCleaning} eq 'recommended') {
    $self->set_level_warning();
  } elsif ($self->{phDriveNeedsCleaning} eq 'required') {
    $self->set_level_critical();
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level());
  }
}


