package Classes::Storagetek;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if (1) {
    bless $self, 'Classes::Storagetek::SL4000';
    $self->debug('using Classes::Storagetek::SL4000');
  } else {
    #$self->no_such_model();
  }
  if (ref($self) ne "Classes::Storagetek") {
    $self->init();
  } else {
    $self->no_such_mode();
  }
}

