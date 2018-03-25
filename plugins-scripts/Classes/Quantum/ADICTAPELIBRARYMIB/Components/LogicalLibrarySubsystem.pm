package Classes::Quantum::ADICTAPELIBRARYMIB::Components::LogicalLibrarySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('ADIC-TAPE-LIBRARY-MIB', [
      ['logicalLibrary', 'logicalLibraryTable', 'Classes::Quantum::ADICTAPELIBRARYMIB::Components::LogicalLibrary'],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking logical libraries');
  foreach (@{$self->{logicalLibrary}}) {
    $_->check();
  }
}


package Classes::Quantum::ADICTAPELIBRARYMIB::Components::LogicalLibrary;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{logicalLibraryIndex} ||= $self->{flat_indices};
  $self->add_info(sprintf 'logical lib %d states: online=%s readyness=%s',
      $self->{logicalLibraryIndex}, $self->{logicalLibraryState},
      $self->{logicalLibraryState});
  if ($self->{logicalLibraryState} =~ /pending/i) {
    $self->set_level_warning();
  } elsif ($self->{logicalLibraryState} eq 'offline') {
    $self->set_level_critical();
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level());
  }
}

