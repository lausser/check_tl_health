package Classes::Adic::Components::ComponentSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('ADIC-INTELLIGENT-STORAGE-MIB', [
    ['components', 'componentTable', 'Classes::Adic::Components::ComponentSubsystem::Component'],
    #['powersupplies', 'powerSupplyTable', 'Monitoring::GLPlugin::TableItem'],
    #['voltages', 'voltageSensorTable', 'Monitoring::GLPlugin::TableItem'],
    #['temperatures', 'temperatureSensorTable', 'Monitoring::GLPlugin::TableItem'],
    #['fans', 'coolingFanTable', 'Monitoring::GLPlugin::TableItem'],
  ]);
}


package Classes::Adic::Components::ComponentSubsystem::Component;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'component %s is %s and %s',
      $self->{componentDisplayName}, $self->{componentControl},
      $self->{componentStatus});
  if ($self->{componentControl} eq 'online') {
    if ($self->{componentStatus} eq 'failed') {
      $self->add_critical();
    } elsif ($self->{componentStatus} eq 'warning') {
      $self->add_warning();
    } elsif ($self->{componentStatus} eq 'unknown') {
      $self->add_unknown();
    } # else ok oder unused
  }
if (ref($self) =~ /rasSystemStatusTable/) {
 $self->{rasStatusGroupLastChange};
}
}


