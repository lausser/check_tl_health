package Classes::HP::SEMIMIB;
our @ISA = qw(Classes::HP);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::HP::SEMIMIB::Components::EnvironmentalSubsystem');
  } else {
    $self->no_such_mode();
  }
}
