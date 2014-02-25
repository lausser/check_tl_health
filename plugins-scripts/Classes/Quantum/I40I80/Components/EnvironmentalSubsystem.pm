package Classes::Quantum::I40I80::Components::EnvironmentalSubsystem;
our @ISA = qw(TL::Quantum);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    blacklisted => 0,
    info => undef,
    extendedinfo => undef,
  };
  bless $self, $class;
  $self->init(%params);
  return $self;
}

sub init {
  my $self = shift;
  foreach (qw(powerStatus coolingStatus controlStatus connectivityStatus
      roboticsStatus mediaStatus driveStatus operatorActionRequest
      aggregatedMainDoorStatus aggregatedIEDoorStatus
      libraryControl numStorageSlots numCleanSlots numIESlots
      numLogicalLibraries
      librarySNMPAgentDescription libraryName libraryVendor
      librarySerialNumber libraryDescription libraryModel
      libraryGlobalStatus libraryURL)) {
    $self->{$_} = $self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', $_, 0);
  }
}

sub check {
  my $self = shift;
  $self->add_info('checking overall system');
  $self->blacklist('tl', '');
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
  my $info = sprintf 'overall states: %s', join(' ', map { $_->[0].'='.$_->[1] } map { my $x = $_->[0]; $x =~ s/Status//; [$x, $_->[1]] } (@{$states->{CRITICAL}}, @{$states->{WARNING}}, @{$states->{UNKNOWN}}, @{$states->{OK}}));
  $self->add_info($info);
  if ($self->get_level()) {
    $self->add_message($self->get_level(), $info);
  }
}


sub dump {
  my $self = shift;
  printf "[LIBRARY_%s]\n", $self->{libraryName};
  foreach (qw(powerStatus coolingStatus controlStatus connectivityStatus
      roboticsStatus mediaStatus driveStatus operatorActionRequest
      aggregatedMainDoorStatus aggregatedIEDoorStatus
      libraryControl numStorageSlots numCleanSlots numIESlots
      numLogicalLibraries
      librarySNMPAgentDescription libraryName libraryVendor
      librarySerialNumber libraryDescription libraryModel
      libraryGlobalStatus libraryURL)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "\n";
}

