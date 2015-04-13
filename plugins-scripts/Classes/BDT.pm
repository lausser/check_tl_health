package Classes::BDT;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /FlexStor II/i) {
    bless $self, 'Classes::BDT::FlexStorII';
    $self->debug('using Classes::BDT::FlexStorII');
  } else {
    $self->no_such_model();
  }
  if (ref($self) ne "Classes::BDT") {
    $self->init();
  }
}
