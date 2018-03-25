package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my ($self) = @_;
  $self->get_snmp_objects('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', (qw(
      libraryGlobalStatus libraryRASStatus)));
  $self->get_snmp_tables('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', [
      ['humidities', 'libraryHumiditySensorTable', 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::EnvironmentalSubsystem::Humidity'],
      ['temperatures', 'libraryTemperatureSensorTable', 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::EnvironmentalSubsystem::Temperature'],
  ]);
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "lib global status is %s",
      $self->{libraryGlobalStatus});
  if ($self->{libraryGlobalStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{libraryGlobalStatus} eq "redFailure") {
    $self->add_critical();
  } elsif ($self->{libraryGlobalStatus} eq "orangeDegraded") {
    $self->add_warning();
  } elsif ($self->{libraryGlobalStatus} eq "yellowWarning") {
    $self->add_warning();
  } elsif ($self->{libraryGlobalStatus} eq "blueAttention") {
    $self->add_warning();
  } elsif ($self->{libraryGlobalStatus} eq "greenInformation") {
    $self->add_ok();
  } elsif ($self->{libraryGlobalStatus} eq "greenGood") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->add_info(sprintf "lib global status is %s",
      $self->{libraryRASStatus});
  if ($self->{libraryRASStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{libraryRASStatus} eq "redFailure") {
    $self->add_critical();
  } elsif ($self->{libraryRASStatus} eq "orangeDegraded") {
    $self->add_warning();
  } elsif ($self->{libraryRASStatus} eq "yellowWarning") {
    $self->add_warning();
  } elsif ($self->{libraryRASStatus} eq "blueAttention") {
    $self->add_warning();
  } elsif ($self->{libraryRASStatus} eq "greenInformation") {
    $self->add_ok();
  } elsif ($self->{libraryRASStatus} eq "greenGood") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->SUPER::check();
}


package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::EnvironmentalSubsystem::Humidity;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{name} = $self->{libraryHumiditySensorLocation}.'_'.$self->{libraryHumiditySensorName};
  $self->{name} =~ s/\s+/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s shows %.1f%% status is %s",
      $self->{name}, $self->{libraryHumiditySensorValue},
      $self->{libraryHumiditySensorStatus});
  if ($self->{libraryHumiditySensorStatus} eq "critical") {
    $self->add_critical();
  } elsif ($self->{libraryHumiditySensorStatus} eq "warning") {
    $self->add_warning();
  } elsif ($self->{libraryHumiditySensorStatus} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->add_perfdata(
      label => $self->{name},
      value => $self->{libraryHumiditySensorValue},
      uom => '%',
  );
}


package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::EnvironmentalSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{name} = $self->{libraryTemperatureSensorLocation}.'_'.$self->{libraryTemperatureSensorName};
  $self->{name} =~ s/\s+/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s shows %.1fC status is %s",
      $self->{name}, $self->{libraryTemperatureSensorValue},
      $self->{libraryTemperatureSensorStatus});
  if ($self->{libraryTemperatureSensorStatus} eq "critical") {
    $self->add_critical();
  } elsif ($self->{libraryTemperatureSensorStatus} eq "warning") {
    $self->add_warning();
  } elsif ($self->{libraryTemperatureSensorStatus} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  $self->add_perfdata(
      label => $self->{name},
      value => $self->{libraryTemperatureSensorValue},
  );
}


