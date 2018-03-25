package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::PowerSupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my ($self) = @_;
  $self->get_snmp_objects('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', qw(
      libraryPSPowerConsumption
  ));
  $self->get_snmp_tables('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB', [
      ['supplies', 'libraryPowerSupplyTable', 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::PowerSupplySubsystem::PowerSupply', sub { shift->{libraryPSStatus} ne "missing" }],
  ]);
}


package Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB::Components::PowerSupplySubsystem::PowerSupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{name} = $self->{libraryPSLocation}.'_'.$self->{libraryPSName};
  $self->{name} =~ s/\s+/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s %s status is %s",
      $self->{libraryPSType},
      $self->{name},
      $self->{libraryPSStatus});
  if ($self->{libraryPSStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{libraryPSStatus} eq "good") {
    $self->add_ok();
  } elsif ($self->{libraryPSStatus} =~ /unknown_/) {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
  if (exists $self->{libraryPSPowerConsumption}) {
    $self->add_info(sprintf "overall power consumption is %.1fW",
        $self->{libraryPSPowerConsumption});
    $self->add_perfdata(
        label => "overall_watt",
        value => $self->{libraryPSPowerConsumption},
    );
  }
}


