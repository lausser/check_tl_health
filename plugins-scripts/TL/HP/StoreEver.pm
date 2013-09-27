package TL::HP::StoreEver;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(TL::HP);

sub init {
  my $self = shift;
  $self->{components} = {
      cpu_subsystem => undef,
      memory_subsystem => undef,
      environmental_subsystem => undef,
  };
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
      $self->get_snmp_object('HP-httpManageable-MIB', 'hpHttpMgHealth');
}

sub check_environmental_subsystem {
  my $self = shift;
  printf "%s\n", $self->{'hpHttpMgHealth'};
}

