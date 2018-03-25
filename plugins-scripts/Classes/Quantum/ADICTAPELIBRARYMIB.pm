package Classes::Quantum::ADICTAPELIBRARYMIB;
our @ISA = qw(Classes::Quantum);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Quantum::ADICTAPELIBRARYMIB::Components::EnvironmentalSubsystem');
    if ($self->implements_mib('HOST-RESOURCES-MIB')) {
      #$self->analyze_and_check_environmental_subsystem('Classes::HOSTRESOURCESMIB::Component::EnvironmentalSubsystem');
    }
    if (! $self->check_messages()) {
      $self->add_ok('hardware working fine');
    }
  } else {
    $self->no_such_mode();
  }
}

