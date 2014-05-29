package Classes::HP::SEMIMIB::Components::EnvironmentalSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->{'hpHttpMgHealth'} =
      $self->get_snmp_object('SEMI-MIB', 'hpHttpMgHealth');
  $self->get_snmp_tables('SEMI-MIB', [
      ['devices', 'hpHttpMgDeviceTable', 'Classes::HP::StoreEver::Device'],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking overall system');
  if (!@{$self->{devices}}) {
    my $info = sprintf 'status of device is %s', $self->{'hpHttpMgHealth'};
    if ($self->{'hpHttpMgHealth'} eq 'unknown') {
      $self->add_unknown($info);
    } elsif ($self->{'hpHttpMgHealth'} eq 'ok') {
      $self->add_ok($info);
    } elsif ($self->{'hpHttpMgHealth'} eq 'warning') {
      $self->add_warning($info);
    } else {
      $self->add_critical($info);
    }
  } else {
    foreach (@{$self->{devices}}) {
      $_->check();
    }
  }
  $self->dump()
      if $self->opts->verbose >= 2;
}


package Classes::HP::StoreEver::Device;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;

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
    $self->add_warning($self->{info});
  } elsif ($self->{hpHttpMgDeviceHealth} eq 'unknown') {
    $self->add_unknown($self->{info});
  } elsif ($self->{hpHttpMgDeviceHealth} eq 'unused') {
  } elsif ($self->{hpHttpMgDeviceHealth} ne 'ok') {
    $self->add_critical($self->{info});
  } else {
    $self->add_ok($self->{info});
  }
}


