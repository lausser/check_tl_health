package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::VoltageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my ($self) = @_;
  $self->get_snmp_tables('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', [
      ['voltages', 'libraryVoltageSensorTable', 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::VoltageSubsystem::Voltage'],
  ]);
}


package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::VoltageSubsystem::Voltage;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{name} = $self->{libraryVoltageSensorLocation}.'_'.$self->{libraryVoltageSensorName};
  $self->{name} =~ s/\s+/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s %s shows %.1fC status is %s",
      $self->{libraryVoltageSensorType},
      $self->{name}, $self->{libraryVoltageSensorValue},
      $self->{libraryVoltageSensorStatus});
  if ($self->{libraryVoltageSensorStatus} eq "critical") {
    $self->add_critical();
  } elsif ($self->{libraryVoltageSensorStatus} eq "warning") {
    $self->add_warning();
  } elsif ($self->{libraryVoltageSensorStatus} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->add_perfdata(
      label => $self->{name},
      value => $self->{libraryVoltageSensorValue},
  );
}


