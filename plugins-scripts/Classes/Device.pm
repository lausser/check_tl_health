package Classes::Device;
our @ISA = qw(GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    $self->check_snmp_and_model();
    if ($self->opts->servertype) {
      $self->{productname} = 'storeever' if $self->opts->servertype eq 'storeever';
    }
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        printf "I am a %s\n", $self->{productname};
      }
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif ($self->{productname} =~ /(1\/8 G2)|(^ hp )|(storeever)/i) {
        bless $self, 'Classes::HP';
        $self->debug('using Classes::HP');
      } elsif ($self->implements_mib('SEMI-MIB')) {
        bless $self, 'Classes::HP::SEMIMIB';
        $self->debug('using Classes::HP::SEMIMIB');
      } elsif ($self->get_snmp_object('QUANTUM-SMALL-TAPE-LIBRARY-MIB', 'libraryVendor', 0)) {
        bless $self, 'Classes::Quantum';
        $self->debug('using Classes::Quantum');
      } elsif ($self->implements_mib('SPECTRALOGIC-GLOBAL-REG-SLHARDWARE-SLLIBRARIES-SLTSERIES')) {
        bless $self, 'Classes::Spectralogic::TSeries';
        $self->debug('using Classes::Spectralogic::TSeries');
      } elsif ($self->implements_mib('ADIC-INTELLIGENT-STORAGE-MIB')) {
        bless $self, 'Classes::Adic';
        $self->debug('using Adic');
      } elsif ($self->implements_mib('BDT-MIB')) {
        bless $self, 'Classes::BDT';
        $self->debug('using BDT');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } else {
          bless $self, 'Classes::Generic';
          $self->debug('using Classes::Generic');
        }
      }
    }
  }
  return $self;
}


package Classes::Generic;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /something specific/) {
  } else {
    bless $self, 'GLPlugin::SNMP';
    $self->no_such_mode();
  }
}

