package TL::HP;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(TL::Device);

use constant trees => (
    '1.3.6.1.4.1.11.2.36', # HP-httpManageable-MIB
);

sub init {
  my $self = shift;
  my %params = @_;
  $self->SUPER::init(%params);
  if ($self->{productname} =~ /Procurve/i) {
    bless $self, 'TL::HP::StoreEver';
    $self->debug('using TL::HP::StoreEver');
  }
  $self->init();
}

