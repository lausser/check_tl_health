package Classes::Spectralogic::TSeries;
our @ISA = qw(Classes::Spectralogic);
use strict;

sub init {
  my $self = shift;
  if ($self->implements_mib('SL-HW-LIB-T950-MIB')) {
    bless $self, 'Classes::Spectralogic::TSeries::T950';
    $self->debug('using Classes::Spectralogic::TSeries::T950');
  } else {
    $self->no_such_model();
  }
  if (ref($self) ne "Classes::Spectralogic::TSeries") {
    $self->init();
  }
}

