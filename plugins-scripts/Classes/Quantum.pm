package Classes::Quantum;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) && $self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) =~ /Scalar\s+i\d+/i) {
    bless $self, 'Classes::Quantum::I40I80';
    $self->debug('using Classes::Quantum::I40I80');
  } elsif ($self->implements_mib('QUANTUM-SNMP-MIB')) {
    bless $self, 'Classes::Quantum::QUANTUMSNMPMIB';
    $self->debug('using Classes::Quantum::QUANTUMSNMPMIB');
  }
  if (ref($self) ne "Classes::Quantum") {
    $self->init();
  }
}

