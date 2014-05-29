package Classes::Spectralogic::TSeries::T950::Components::EnvironmentalSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('SL-HW-LIB-T950-MIB', (qw(
      slT950GeneralStatusPowerStatus
      slT950GeneralStatusFansStatus
      slT950GeneralStatusTap1Status
      slT950GeneralStatusTap2Status
  )));
  $self->get_snmp_tables('SL-HW-LIB-T950-MIB', [
    ['partitions', 'slT950GeneralStatusPartitionTable', 'GLPlugin::SNMP::TableItem' ],
    ['messages', 'slT950MessageTable', 'Classes::Spectralogic::TSeries::T950::Components::EnvironmentalSubsystem::Message' ],
  ]);
}

sub check {
  my $self = shift;
  if ($self->{slT950GeneralStatusPowerStatus} eq 'failure') {
    $self->add_critical('power supply failure');
  }
  if ($self->{slT950GeneralStatusFansStatus} eq 'warning') {
    $self->add_warning('one or more library fans are impaired or filter is dirty');
  } elsif ($self->{slT950GeneralStatusFansStatus} eq 'failure') {
    $self->add_warning('one or more library fans are missing or filter is plugged');
  }
  if ($self->{slT950GeneralStatusTap1Status} eq 'warning') {
    $self->add_warning('tap 1 is open');
  } elsif ($self->{slT950GeneralStatusTap1Status} eq 'failure') {
    $self->add_warning('tap 1 is impaired');
  }
  if ($self->{slT950GeneralStatusTap2Status} eq 'warning') {
    $self->add_warning('tap 2 is open');
  } elsif ($self->{slT950GeneralStatusTap2Status} eq 'failure') {
    $self->add_warning('tap 2 is impaired');
  }
  foreach (@{$self->{messages}}) {
    $_->check();
  }
}


package Classes::Spectralogic::TSeries::T950::Components::EnvironmentalSubsystem::Message;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;
use Date::Manip;

sub check {
  my $self = shift;
  # slT950MessageTime = SLTimeStampString 
  #    YYYY-MM-DD hh:mm:ss where^M
  #    YYYY  four digit year^M
  #    MM    two digit month, zero padded if necessary^M
  #    DD    two digit day, zero padded if necessary^M
  #    hh    two digit, 24 hr clock hour, zero padded if necessary^M
  #    mm    two digit minute, zero padded if necessary^M
  #    ss    two digit second, zero padded if necessary^M
  #    For example, 2005-05-13 23:01:30 would represent 11:01:30 pm^M
  #    on May 13, 2005"^M
  my $date = new Date::Manip::Date;
  $date->parse_format("%Y-%m-%d %H:%M:%S", $self->{slT950MessageTime});
  my $age = time - $date->printf("%s");
  if ($age < 3600) {
    if ($self->{slT950MessageSeverity} eq 'warning') {
      $self->add_warning(sprintf "alarm: %s (%d min ago, %s)",
          $self->{slT950MessageText}, $age / 60, $self->{slT950MessageRemedyText});
    } elsif ($self->{slT950MessageSeverity} eq 'error' ||
        $self->{slT950MessageSeverity} eq 'fatal') {
      $self->add_critical(sprintf "alarm: %s (%d min ago, %s)",
          $self->{slT950MessageText}, $age / 60, $self->{slT950MessageRemedyText});
    }
  }
}


