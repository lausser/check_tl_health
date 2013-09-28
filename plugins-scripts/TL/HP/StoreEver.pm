package TL::HP::StoreEver;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(TL::HP);

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
        TL::HP::StoreEver::Device->new(%{$_}));
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
  }
}

