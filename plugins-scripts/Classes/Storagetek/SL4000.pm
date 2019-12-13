package Classes::Storagetek::SL4000;
our @ISA = qw(Classes::Storagetek);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Storagetek::SL4000::Components::EnvironmentalSubsystem');
  } else {
    $self->no_such_mode();
  }
}

