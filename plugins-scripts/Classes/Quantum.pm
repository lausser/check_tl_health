package Classes::Quantum;
our @ISA = qw(Classes::Device);
use strict;

use constant trees => (
    '1.3.6.1.4.1.3697', # QUANTUM-SMALL-TAPE-LIBRARY-MIB
);

sub init {
  my $self = shift;
  if ($self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) && $self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) =~ /Scalar\s+i\d+/i) {
    bless $self, 'Classes::Quantum::I40I80';
    $self->debug('using Classes::Quantum::I40I80');
  }
  if (ref($self) ne "Classes::Quantum") {
    $self->init();
  } else {
printf "dong\n";
  }
}

