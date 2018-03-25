package Classes::Quantum::I500;
our @ISA = qw(Classes::Quantum);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Quantum::I500::Components::EnvironmentalSubsystem');
    $self->analyze_and_check_drive_subsystem('Classes::Quantum::I500::Components::DriveSubsystem');
    $self->analyze_and_check_logical_subsystem('Classes::Quantum::I500::Components::LogicalLibrarySubsystem');
    if (! $self->check_messages()) {
      $self->add_ok('hardware working fine');
    }
  } else {
    $self->no_such_mode();
  }
}

