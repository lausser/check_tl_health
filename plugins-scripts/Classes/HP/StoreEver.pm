package Classes::HP::StoreEver;
our @ISA = qw(Classes::HP);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->{devices} = [];
  if (! $self->check_messages()) {
    if ($self->mode =~ /device::hardware::health/) {
      $self->analyze_environmental_subsystem();
      $self->check_environmental_subsystem();
    } elsif ($self->mode =~ /device::hardware::load/) {
      $self->analyze_cpu_subsystem();
      $self->check_cpu_subsystem();
    } elsif ($self->mode =~ /device::hardware::memory/) {
      $self->analyze_mem_subsystem();
      $self->check_mem_subsystem();
    } elsif ($self->mode =~ /device::shinken::interface/) {
      $self->analyze_interface_subsystem();
      $self->shinken_interface_subsystem();
    }
  }
}

sub analyze_environmental_subsystem {
  my $self = shift;
  $self->{'hpHttpMgHealth'} =
      $self->get_snmp_object('SEMI-MIB', 'hpHttpMgHealth');
  foreach ($self->get_snmp_table_objects(
      'SEMI-MIB', 'hpHttpMgDeviceTable')) {
    push(@{$self->{devices}},
        Classes::HP::StoreEver::Device->new(%{$_}));
  }
}

sub check_environmental_subsystem {
  my $self = shift;
  if (!@{$self->{devices}}) {
    my $info = sprintf 'status of device is %s', $self->{'hpHttpMgHealth'};
    if ($self->{'hpHttpMgHealth'} eq 'unknown') {
      $self->add_message(UNKNOWN, $info);
    } elsif ($self->{'hpHttpMgHealth'} eq 'ok') {
      $self->add_message(OK, $info);
    } elsif ($self->{'hpHttpMgHealth'} eq 'warning') {
      $self->add_message(WARNING, $info);
    } else {
      $self->add_message(CRITICAL, $info);
    }
  } else {
    foreach (@{$self->{devices}}) {
      $_->check();
    }
  }
  $self->dump()
      if $self->opts->verbose >= 2;
}

sub dump {
  my $self = shift;
  if (!@{$self->{devices}}) {
  } else {
    foreach (@{$self->{devices}}) {
      $_->dump();
    }
  }
}

package Classes::HP::StoreEver::Device;
our @ISA = qw(Classes::HP::StoreEver);

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
  foreach (qw(hpHttpMgDeviceIndex hpHttpMgDeviceHealth
      hpHttpMgDeviceManufacturer hpHttpMgDeviceProductName
      hpHttpMgDeviceSerialNumber)) {
    $self->{$_} = $params{$_};
  }
  bless $self, $class;
  return $self;
}

sub check {
  my $self = shift;
  $self->blacklist('d', $self->{hpHttpMgDeviceIndex});
  $self->add_info(sprintf 'device %s (%s %s, sn:%s) status is %s',
      $self->{hpHttpMgDeviceIndex},
      $self->{hpHttpMgDeviceManufacturer},
      $self->{hpHttpMgDeviceProductName},
      $self->{hpHttpMgDeviceSerialNumber},
      $self->{hpHttpMgDeviceHealth});
  if ($self->{hpHttpMgDeviceHealth} eq 'warning') {
    $self->add_message(WARNING, $self->{info});
  } elsif ($self->{hpHttpMgDeviceHealth} eq 'unknown') {
    $self->add_message(UNKNOWN, $self->{info});
  } elsif ($self->{hpHttpMgDeviceHealth} eq 'unused') {
  } elsif ($self->{hpHttpMgDeviceHealth} ne 'ok') {
    $self->add_message(CRITICAL, $self->{info});
  } else {
    $self->add_message(OK, $self->{info});
  }
}

sub dump {
  my $self = shift;
  printf "[DEVICE_%s]\n", $self->{hpHttpMgDeviceIndex};
  foreach (qw(hpHttpMgDeviceIndex hpHttpMgDeviceHealth
      hpHttpMgDeviceManufacturer hpHttpMgDeviceProductName
      hpHttpMgDeviceSerialNumber)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  printf "\n";
}



