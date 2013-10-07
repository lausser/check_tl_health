package TL::Quantum::I40I80::Components::LogicalLibrarySubsystem;
our @ISA = qw(TL::Quantum);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    logical_libraries => [],
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
  foreach ($self->get_snmp_table_objects(
      'QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'logicalLibraryTable')) {
    push(@{$self->{logical_libraries}},
        TL::Quantum::I40I80::Components::LogicalLibrary->new(%{$_}));
  }
}

sub check {
  my $self = shift;
  $self->add_info('checking logical libraries');
  foreach (@{$self->{logical_libraries}}) {
    $_->check();
  }
}

sub dump {
  my $self = shift;
  foreach (@{$self->{logical_libraries}}) {
    $_->dump();
  }
}

package TL::Quantum::I40I80::Components::LogicalLibrary;
our @ISA = qw(TL::Quantum::I40I80::Components::DriveSubsystem);

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
  foreach (qw(logicalLibraryIndex logicalLibraryAutoClean
      logicalLibraryNumSlots logicalLibraryNumIE logicalLibraryNumTapeDrives
      logicalLibraryStorageElemAddr logicalLibraryIEElemAddr
      logicalLibraryTapeDriveElemAddr logicalLibraryChangerDeviceAddr
      logicalLibraryName logicalLibrarySerialNumber logicalLibraryModel
      logicalLibraryInterface logicalLibraryMediaDomain logicalLibraryOnlineState
      logicalLibraryReadyState indices)) {
    $self->{$_} = $params{$_};
  }
  $self->{logicalLibraryIndex} ||= $self->{indices}->[0];
  bless $self, $class;
  return $self;
}

sub check {
  my $self = shift;
  $self->blacklist('ld', $self->{logicalLibraryIndex});
  my $info = sprintf 'logical lib %d states: online=%s readyness=%s',
      $self->{logicalLibraryIndex}, $self->{logicalLibraryOnlineState},
      $self->{logicalLibraryReadyState};
  $self->add_info($info);
  if ($self->{logicalLibraryOnlineState} =~ /pending/i) {
    $self->set_level(WARNING);
  } elsif ($self->{logicalLibraryOnlineState} eq 'offline') {
    $self->set_level(CRITICAL);
  }
  if ($self->{logicalLibraryReadyState} eq 'becomingReady') {
    $self->set_level(WARNING);
  } elsif ($self->{logicalLibraryReadyState} eq 'notReady') {
    $self->set_level(CRITICAL);
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level(), $info);
  }

}

sub dump {
  my $self = shift;
  printf "[LOG_LIB_%s]\n", $self->{logicalLibraryIndex};
  foreach (qw(logicalLibraryIndex logicalLibraryAutoClean
      logicalLibraryNumSlots logicalLibraryNumIE logicalLibraryNumTapeDrives
      logicalLibraryStorageElemAddr logicalLibraryIEElemAddr
      logicalLibraryTapeDriveElemAddr logicalLibraryChangerDeviceAddr
      logicalLibraryName logicalLibrarySerialNumber logicalLibraryModel
      logicalLibraryInterface logicalLibraryMediaDomain logicalLibraryOnlineState
      logicalLibraryReadyState)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  printf "\n";
}


