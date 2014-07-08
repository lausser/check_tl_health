package Classes::Quantum::I40I80::Components::EnvironmentalSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->get_snmp_objects('QUANTUM-SMALL-TAPE-LIBRARY-MIB', (qw(powerStatus
      coolingStatus controlStatus connectivityStatus
      roboticsStatus mediaStatus driveStatus operatorActionRequest
      aggregatedMainDoorStatus aggregatedIEDoorStatus
      libraryControl numStorageSlots numCleanSlots numIESlots
      numLogicalLibraries
      librarySNMPAgentDescription libraryName libraryVendor
      librarySerialNumber libraryDescription libraryModel
      libraryGlobalStatus libraryURL)));
}

sub check {
  my $self = shift;
  $self->add_info('checking overall system');
  my $states = {
    OK => [],
    WARNING => [],
    CRITICAL => [],
    UNKNOWN => [],
  };
  foreach (qw(powerStatus coolingStatus controlStatus connectivityStatus
      roboticsStatus mediaStatus driveStatus)) {
    if ($self->{$_} eq 'degraded' or $self->{$_} eq 'warning') {
      $self->set_level(WARNING);
      push(@{$states->{WARNING}}, [$_, $self->{$_}]);
    } elsif ($self->{$_} eq 'unknown') {
      $self->set_level(UNKNOWN);
      push(@{$states->{UNKNOWN}}, [$_, $self->{$_}]);
    } elsif ($self->{$_} eq 'good' or $self->{$_} eq 'informational') {
      push(@{$states->{OK}}, [$_, $self->{$_}]);
    } else {
      $self->set_level(CRITICAL);
      push(@{$states->{CRITICAL}}, [$_, $self->{$_}]);
    }
  }
  if ($self->{operatorActionRequest} eq 'yes') {
    $self->set_level(CRITICAL);
    $self->add_message(CRITICAL, 'operator action requested');
  }
  if ($self->{aggregatedMainDoorStatus} eq 'open') {
    $self->set_level(CRITICAL);
    push(@{$states->{CRITICAL}}, ['aggregatedMainDoorStatus', $self->{aggregatedMainDoorStatus}]);
  } elsif ($self->{aggregatedMainDoorStatus} eq 'closedAndUnLocked') {
    $self->set_level(WARNING);
    push(@{$states->{WARNING}}, ['aggregatedMainDoorStatus', $self->{aggregatedMainDoorStatus}]);
  } elsif ($self->{aggregatedMainDoorStatus} eq 'unknown') {
    $self->set_level(UNKNOWN);
    push(@{$states->{UNKNOWN}}, ['aggregatedMainDoorStatus', $self->{aggregatedMainDoorStatus}]);
  }
  if ($self->{aggregatedIEDoorStatus} eq 'open') {
    $self->set_level(CRITICAL);
    push(@{$states->{CRITICAL}}, ['aggregatedIEDoorStatus', $self->{aggregatedIEDoorStatus}]);
  } elsif ($self->{aggregatedIEDoorStatus} eq 'closedAndUnLocked') {
    $self->set_level(WARNING);
    push(@{$states->{WARNING}}, ['aggregatedIEDoorStatus', $self->{aggregatedIEDoorStatus}]);
  }
  $self->add_info(sprintf 'overall states: %s', join(' ', map { $_->[0].'='.$_->[1] } map { my $x = $_->[0]; $x =~ s/Status//; [$x, $_->[1]] } (@{$states->{CRITICAL}}, @{$states->{WARNING}}, @{$states->{UNKNOWN}}, @{$states->{OK}})));
  if ($self->get_level()) {
    $self->add_message($self->get_level());
  }
}

