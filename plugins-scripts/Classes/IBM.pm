package Classes::IBM;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /TS4300/i) {
    bless $self, 'Classes::IBM::TS4300';
    $self->debug('using Classes::IBM::TS4300');
  } else {
    $self->no_such_model();
  }
  if (ref($self) ne "Classes::IBM") {
    $self->init();
  }
}

