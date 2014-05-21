package Classes::Quantum::I40I80::Components::LogicalLibrarySubsystem;
our @ISA = qw(GLPlugin::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('QUANTUM-SMALL-TAPE-LIBRARY-MIB', [
      ['logical_libraries', 'logicalLibraryTable', 'Classes::Quantum::I40I80::Components::LogicalLibrary'],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking logical libraries');
  foreach (@{$self->{logical_libraries}}) {
    $_->check();
  }
}


package Classes::Quantum::I40I80::Components::LogicalLibrary;
our @ISA = qw(GLPlugin::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->{logicalLibraryIndex} ||= $self->{flat_indices};
  $self->blacklist('ld', $self->{logicalLibraryIndex});
  my $info = sprintf 'logical lib %d states: online=%s readyness=%s',
      $self->{logicalLibraryIndex}, $self->{logicalLibraryOnlineState},
      $self->{logicalLibraryReadyState};
  $self->add_info($info);
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
    $self->add_message($self->get_level(), $info);
  }
}

