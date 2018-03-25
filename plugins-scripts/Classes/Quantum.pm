package Classes::Quantum;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->implements_mib('ADIC-TAPE-LIBRARY-MIB')) {
    bless $self, 'Classes::Quantum::ADICTAPELIBRARYMIB';
    $self->debug('using Classes::Quantum::ADICTAPELIBRARYMIB');
  } elsif ($self->implements_mib('QUANTUM-SMALL-TAPE-LIBRARY-MIB')) {
    bless $self, 'Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB';
    $self->debug('using Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB');
  } elsif ($self->implements_mib('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB')) {
    bless $self, 'Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB';
    $self->debug('using Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB');
  } elsif ($self->implements_mib('ADIC-INTELLIGENT-STORAGE-MIB')) {
    bless $self, 'Classes::Quantum::ADICINTELLIGENTSTORAGEMIB';
    $self->debug('using Classes::Quantum::ADICINTELLIGENTSTORAGEMIB');
  } elsif ($self->implements_mib('QUANTUM-SNMP-MIB')) {
    bless $self, 'Classes::Quantum::QUANTUMSNMPMIB';
    $self->debug('using Classes::Quantum::QUANTUMSNMPMIB');
  }
  if (ref($self) ne "Classes::Quantum") {
    $self->init();
  }
}

