package Classes::HP;
our @ISA = qw(Classes::Device);
use strict;

use constant trees => (
    '1.3.6.1.4.1.11.2.36', # HP-httpManageable-MIB
);

sub init {
  my $self = shift;
  if ($self->{productname} =~ /StoreEver/i) {
    bless $self, 'Classes::HP::SEMIMIB';
    $self->debug('using Classes::HP::SEMIMIB');
  } else {
    $self->no_such_model();
  }
  if (ref($self) ne "Classes::HP") {
    $self->init();
  }
}

