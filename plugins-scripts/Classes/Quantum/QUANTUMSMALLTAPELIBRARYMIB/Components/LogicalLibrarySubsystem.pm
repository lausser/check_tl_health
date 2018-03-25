package Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB::Components::LogicalLibrarySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('QUANTUM-SMALL-TAPE-LIBRARY-MIB', [
      ['logical_libraries', 'logicalLibraryTable', 'Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB::Components::LogicalLibrary'],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking logical libraries');
  foreach (@{$self->{logical_libraries}}) {
    $_->check();
  }
}


package Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB::Components::LogicalLibrary;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{logicalLibraryIndex} ||= $self->{flat_indices};
  $self->add_info(sprintf 'logical lib %d states: online=%s readyness=%s',
      $self->{logicalLibraryIndex}, $self->{logicalLibraryOnlineState},
      $self->{logicalLibraryReadyState});
  if ($self->{logicalLibraryOnlineState} =~ /pending/i) {
    $self->set_level_warning();
  } elsif ($self->{logicalLibraryOnlineState} eq 'offline') {
    $self->set_level_critical();
  }
  if ($self->{logicalLibraryReadyState} eq 'becomingReady') {
    $self->set_level_warning();
  } elsif ($self->{logicalLibraryReadyState} eq 'notReady') {
    $self->set_level_critical();
  }
  if ($self->get_level()) {
    $self->add_message($self->get_level());
  }
}

