package Classes::Quantum::I40I80::Components::DriveSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('QUANTUM-SMALL-TAPE-LIBRARY-MIB', [
      ['phycsical_drives', 'physicalDriveTable', 'Classes::Quantum::I40I80::Components::PhysicalDrive'],
  ]);
  $self->get_snmp_objects('QUANTUM-SMALL-TAPE-LIBRARY-MIB', (qw(
      numPhDrives overallPhDriveOnlineStatus overallPhDriveReadinessStatus)));
}

sub check {
  my $self = shift;
  $self->add_info('checking physical drives');
  $self->add_info(sprintf 'overall drive status online=%s readyness=%s',
      $self->{overallPhDriveOnlineStatus},
      $self->{overallPhDriveReadinessStatus});
  if ($self->{overallPhDriveOnlineStatus} =~ /pending/i) {
    $self->add_warning();
  } elsif ($self->{overallPhDriveOnlineStatus} eq 'offline') {
    $self->add_critical();
  }
  foreach (@{$self->{phycsical_drives}}) {
    $_->check();
  }
  
}


package Classes::Quantum::I40I80::Components::PhysicalDrive;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{phDriveIndex} ||= $self->{flat_indices};
  $self->add_info(sprintf 'drive %d states: online=%s readyness=%s ras=%s cleaning=%s',
      $self->{phDriveIndex}, $self->{phDriveOnlineState},
      $self->{phDriveReadinessState}, $self->{phDriveRasStatus}, $self->{phDriveCleaningStatus});
  if ($self->{phDriveOnlineState} =~ /pending/i) {
    $self->set_level_warning();
  } elsif ($self->{phDriveOnlineState} eq 'offline') {
    $self->set_level_critical();
  }
  if ($self->{phDriveReadinessState} eq 'notReady') {
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
  if ($self->{phDriveCleaningStatus} eq 'recommended') {
    $self->set_level_warning();
  } elsif ($self->{phDriveCleaningStatus} eq 'required') {
    $self->set_level_critical();
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level());
  }
}


