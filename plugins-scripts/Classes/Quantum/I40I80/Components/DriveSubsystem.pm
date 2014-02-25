package Classes::Quantum::I40I80::Components::DriveSubsystem;
our @ISA = qw(Classes::Quantum);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    phycsical_drives => [],
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
      'QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'physicalDriveTable')) {
    push(@{$self->{phycsical_drives}},
        Classes::Quantum::I40I80::Components::PhysicalDrive->new(%{$_}));
  }
  foreach (qw(numPhDrives overallPhDriveOnlineStatus overallPhDriveReadinessStatus)) {
    $self->{$_} = $self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', $_, 0);
  }
}

sub check {
  my $self = shift;
  $self->add_info('checking physical drives');
  my $info = sprintf 'overall drive status online=%s readyness=%s',
      $self->{overallPhDriveOnlineStatus}, $self->{overallPhDriveReadinessStatus};
  $self->add_info($info);
  if ($self->{overallPhDriveOnlineStatus} =~ /pending/i) {
    $self->add_message(WARNING, $info);
  } elsif ($self->{overallPhDriveOnlineStatus} eq 'offline') {
    $self->add_message(CRITICAL, $info);
  }
  foreach (@{$self->{phycsical_drives}}) {
    $_->check();
  }
  
}

sub dump {
  my $self = shift;
  foreach (@{$self->{phycsical_drives}}) {
    $_->dump();
  }
}


package Classes::Quantum::I40I80::Components::PhysicalDrive;
our @ISA = qw(Classes::Quantum::I40I80::Components::DriveSubsystem);

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
  foreach (qw(phDriveIndex phDriveOnlineState phDriveReadinessState
      phDriveRasStatus phDriveLoads phDriveCleaningStatus 
      phDriveLogicalLibraryName phDriveControlPathDrive
      phDriveLocation phDriveDeviceId phDriveVendor phDriveType
      phDriveInterfaceType phDriveAddress phDrivePhysicalSerialNumber
      phDriveLogicalSerialNumber indices)) {
    $self->{$_} = $params{$_};
  }
  $self->{phDriveIndex} ||= $self->{indices}->[0];
  bless $self, $class;
  return $self;
}

sub check {
  my $self = shift;
  $self->blacklist('pd', $self->{phDriveIndex});
  my $info = sprintf 'drive %d states: online=%s readyness=%s ras=%s cleaning=%s',
      $self->{phDriveIndex}, $self->{phDriveOnlineState},
      $self->{phDriveReadinessState}, $self->{phDriveRasStatus}, $self->{phDriveCleaningStatus};
  $self->add_info($info);
  if ($self->{phDriveOnlineState} =~ /pending/i) {
    $self->set_level(WARNING);
  } elsif ($self->{phDriveOnlineState} eq 'offline') {
    $self->set_level(CRITICAL);
  }
  if ($self->{phDriveReadinessState} eq 'notReady') {
    $self->set_level(CRITICAL);
  }
  if ($self->{phDriveRasStatus} eq 'degraded' or $self->{phDriveRasStatus} eq 'warning') {
    $self->set_level(WARNING);
  } elsif ($self->{phDriveRasStatus} eq 'unknown') {
    $self->set_level(UNKNOWN);
  } elsif ($self->{phDriveRasStatus} eq 'good' or $self->{phDriveRasStatus} eq 'informational') {
  } else {
    $self->set_level(CRITICAL);
  }
  if ($self->{phDriveCleaningStatus} eq 'recommended') {
    $self->set_level(WARNING);
  } elsif ($self->{phDriveCleaningStatus} eq 'required') {
    $self->set_level(CRITICAL);
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level(), $info);
  }
}

sub dump {
  my $self = shift;
  printf "[PHYS_DRIVE_%s]\n", $self->{phDriveIndex};
  foreach (qw(phDriveIndex phDriveOnlineState phDriveReadinessState
      phDriveRasStatus phDriveLoads phDriveCleaningStatus 
      phDriveLogicalLibraryName phDriveControlPathDrive
      phDriveLocation phDriveDeviceId phDriveVendor phDriveType
      phDriveInterfaceType phDriveAddress phDrivePhysicalSerialNumber
      phDriveLogicalSerialNumber)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  printf "\n";
}

