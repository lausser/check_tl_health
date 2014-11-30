package Classes::Adic::Components::EnvironmentalSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('ADIC-INTELLIGENT-STORAGE-MIB', (qw(
      productName productDisplayName productDescription
      productVendor productVersion productDisplayVersion
      productLibraryClass productSerialNumber
      agentGlobalStatus agentLastGlobalStatus agentTimeStamp 
  )));
  #$self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::ComponentSubsystem');
  $self->analyze_and_check_environmental_subsystem('Classes::Adic::Components::RasSubsystem');
}

sub dump {
  my $self = shift;
  printf "[ENVIRONMENTALSUBSYSTEM]\n";
  foreach (qw(
      productName productDisplayName productDescription
      productVendor productVersion productDisplayVersion
      productLibraryClass productSerialNumber
      agentGlobalStatus agentLastGlobalStatus agentTimeStamp)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
}

