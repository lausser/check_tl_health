package Classes::Quantum::I40I80;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(Classes::Quantum);

sub init {
  my $self = shift;
  $self->{components} = {
      drive_subsystem => undef,
      environmental_subsystem => undef,
      logical_subsystem => undef,
  };
  if (! $self->check_messages()) {
    if ($self->mode =~ /device::hardware::health/) {
      $self->analyze_environmental_subsystem();
      $self->analyze_drive_subsystem();
      $self->analyze_logical_subsystem();
      $self->check_environmental_subsystem();
      $self->check_drive_subsystem();
      $self->check_logical_subsystem();
      if (! $self->check_messages()) {
        $self->add_message(OK, 'hardware working fine');
      }
    }
  }
}

sub analyze_drive_subsystem {
  my $self = shift;
  $self->{components}->{drive_subsystem} = Classes::Quantum::I40I80::Components::DriveSubsystem->new();
}

sub analyze_environmental_subsystem {
  my $self = shift;
  $self->{components}->{environmental_subsystem} = Classes::Quantum::I40I80::Components::EnvironmentalSubsystem->new();
}

sub analyze_logical_subsystem {
  my $self = shift;
  $self->{components}->{logical_subsystem} = Classes::Quantum::I40I80::Components::LogicalLibrarySubsystem->new();
}

