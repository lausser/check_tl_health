package TL::Quantum;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(TL::Device);

use constant trees => (
    '1.3.6.1.4.1.3697', # QUANTUM-SMALL-TAPE-LIBRARY-MIB
);

sub init {
  my $self = shift;
  my %params = @_;
  $self->SUPER::init(%params);
  if ($self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) && $self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryModel', 0) =~ /Scalar\s+i\d+/i) {
    bless $self, 'TL::Quantum::I40I80';
    $self->debug('using TL::Quantum::I40I80');
  } else {
    # unknown quantum
  }
  $self->init();
}

