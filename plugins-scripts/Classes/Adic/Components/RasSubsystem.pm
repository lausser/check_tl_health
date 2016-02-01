package Classes::Adic::Components::RasSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  use Data::Dumper;
  $self->get_snmp_tables('ADIC-MANAGEMENT-MIB', [
    ['rassystems', 'rasSystemStatusTable', 'Classes::Adic::Components::RasSubsystem::RasSystem'],
  ]);
}

package Classes::Adic::Components::RasSubsystem::RasSystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  eval {
    $self->{rasStatusGroupLastChangeHuman} = 
        scalar localtime $self->{rasStatusGroupLastChange};
  };
  if ($@) {
    $self->{rasStatusGroupLastChangeHuman} = '_unknown_';
  }
}


sub check {
  my $self = shift;
  $self->{rasStatusGroupTextSummary} =~ s/[\|'"]+/_/g;
  if ($self->{rasStatusGroupStatus} eq 'good' ||
      $self->{rasStatusGroupStatus} eq 'informational') {
    $self->add_info(sprintf '%s has status %s',
        $self->{rasStatusGroupIndex}, $self->{rasStatusGroupStatus});
  } else {
    $self->add_info(sprintf '%s has status %s%s%s',
        $self->{rasStatusGroupIndex}, $self->{rasStatusGroupStatus},
        $self->{rasStatusGroupTextSummary} ? 
            sprintf(' (%s)', $self->{rasStatusGroupTextSummary}) : '',
        $self->{rasStatusGroupLastChangeHuman} ne '_unknown_' ?
            sprintf(' since %s', $self->{rasStatusGroupLastChangeHuman}) : ''
    );
    if ($self->{rasStatusGroupStatus} eq 'failed') {
      $self->add_critical();
    } elsif ($self->{rasStatusGroupStatus} eq 'degraded') {
      $self->add_warning();
    } elsif ($self->{rasStatusGroupStatus} eq 'warning') {
      $self->add_warning();
    } elsif ($self->{rasStatusGroupStatus} eq 'unknown') {
      $self->add_unknown();
    } elsif ($self->{rasStatusGroupStatus} eq 'invalid') {
      $self->add_unknown();
    } # else ok oder unused
  }
}

