package Classes::IBM::TS4300;
our @ISA = qw(Classes::IBM);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::IBM::TS4300::Components::EnvironmentalSubsystem');
  } else {
    $self->no_such_mode();
  }
}

