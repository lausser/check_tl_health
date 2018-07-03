package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::DriveSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', [
      ['phycsical_drives', 'physicalDriveTable', 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::PhysicalDrive'],
  ]);
  $self->get_snmp_objects('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', (qw(
      libraryPhDriveCount driveRASStatus mediaRASStatus
      aggregatedMagazineStatus
  )));
}

sub check {
  my $self = shift;
  $self->add_info('checking physical drives');
  $self->add_info(sprintf 'overall drive status %s',
      $self->{driveRASStatus});
  if ($self->{driveRASStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{driveRASStatus} eq "redFailure") {
    $self->add_critical();
  } elsif ($self->{driveRASStatus} eq "orangeDegraded") {
    $self->add_warning();
  } elsif ($self->{driveRASStatus} eq "yellowWarning") {
    $self->add_warning();
  } elsif ($self->{driveRASStatus} eq "blueAttention") {
    $self->add_warning();
  } elsif ($self->{driveRASStatus} eq "greenInformation") {
    $self->add_ok();
  } elsif ($self->{driveRASStatus} eq "greenGood") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->add_info('checking magazin status');
  $self->add_info(sprintf 'overall magazine status %s',
      $self->{aggregatedMagazineStatus});
  if ($self->{aggregatedMagazineStatus} eq "notAllPresent") {
    if (defined $self->opts->mitigation()) {
      $self->add_message($self->opts->mitigation());
    } else {
      $self->add_warning();
    }
  }
  $self->SUPER::check();
}


package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::PhysicalDrive;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{phDriveIndex} ||= $self->{flat_indices};
  $self->add_info(sprintf 'drive %d is %s, states: ras=%s cleaning=%s',
      $self->{phDriveIndex}, $self->{phDriveMode},
      $self->{phDriveRasStatus}, $self->{phDriveCleaningStatus});
  $self->set_level_ok();
  if ($self->{phDriveState} eq 'unknown') {
    $self->set_level_unknown();
  } elsif ($self->{phDriveMode} eq 'offline') {
    $self->set_level_critical();
  }
  if ($self->{phDriveRasStatus} !~ /^green/) {
    $self->set_level_warning();
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


