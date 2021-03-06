package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    $self->{broken_snmp_agent} = [
      sub {
        my $productElementName =
            $self->get_snmp_object('SNIA-SML-MIB', 'product-ElementName');
        if ($productElementName) {
          $self->{productname} = $productElementName;
          $self->{uptime} = $self->timeticks(100 * 3600);
          my $sysobj = $self->get_snmp_object('MIB-2-MIB', 'sysObjectID', 0);
          if (! $sysobj) {
            $self->add_rawdata('1.3.6.1.2.1.1.2.0', "mirhanvomwolddahoam");
          }
          return 1;
        }
        my $ksComplexName =
            $self->get_snmp_object('STREAMLINE-TAPE-LIBRARY4J-MIB', 'ksComplexName');
        if ($ksComplexName) {
          my $sysUptime = $self->get_snmp_object('MIB-2-MIB', 'sysUpTime', 0);
          $self->{uptime} = $self->timeticks($sysUptime);

          $self->{productname} = $ksComplexName;
          return 1;
        }
        return 0;
      },
    ];
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
      } elsif ($self->implements_mib('STREAMLINE-TAPE-LIBRARY4J-MIB')) {
        $self->rebless('Classes::Storagetek');
        $self->debug('using Classes::Storagetek');
      } elsif ($self->{productname} =~ /(1\/8 G2)|(^ hp )|(storeever)/i) {
        $self->rebless('Classes::HP');
        $self->debug('using Classes::HP');
      } elsif ($self->implements_mib('SEMI-MIB')) {
        $self->rebless('Classes::HP::SEMIMIB');
        $self->debug('using Classes::HP::SEMIMIB');
      } elsif ($self->implements_mib('QUANTUM-SNMP-MIB')) {
        $self->rebless('Classes::Quantum');
        $self->debug('using Classes::Quantum');
      } elsif ($self->implements_mib('QUANTUM-SMALL-TAPE-LIBRARY-MIB')) {
        $self->rebless('Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB');
        $self->debug('using Classes::Quantum::QUANTUMSMALLTAPELIBRARYMIB');
      } elsif ($self->implements_mib('QUANTUM-MIDRANGE-TAPE-LIBRARY-MIB')) {
        $self->rebless('Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB');
        $self->debug('using Classes::Quantum::QUANTUMMIDRANGETAPELIBRARYMIB');
      } elsif ($self->implements_mib('ADIC-INTELLIGENT-STORAGE-MIB')) {
        $self->rebless('Classes::Quantum');
        $self->debug('using Quantum');
      } elsif ($self->implements_mib('ADIC-TAPE-LIBRARY-MIB')) {
        $self->rebless('Classes::Quantum');
        $self->debug('using Quantum');
      } elsif ($self->implements_mib('SPECTRALOGIC-GLOBAL-REG-SLHARDWARE-SLLIBRARIES-SLTSERIES')) {
        $self->rebless('Classes::Spectralogic::TSeries');
        $self->debug('using Classes::Spectralogic::TSeries');
      } elsif ($self->implements_mib('BDT-MIB')) {
        $self->rebless('Classes::BDT');
        $self->debug('using BDT');
      } elsif ($self->{productname} =~ /IBM /) {
        $self->rebless('Classes::IBM');
        $self->debug('using Classes::IBM');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          $self->rebless($class);
          $self->debug('using '.$class);
        } else {
          $self->rebless('Classes::Generic');
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
    $self->rebless('Monitoring::GLPlugin::SNMP');
    $self->no_such_mode();
  }
}

