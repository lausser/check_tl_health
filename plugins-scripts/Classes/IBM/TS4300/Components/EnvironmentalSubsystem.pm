package Classes::IBM::TS4300::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  # there is a lot of useless information in the mib
  # except for power supplies there are no status oids, no events
  # you should receive traps in order to get the whole picture.
  $self->get_snmp_tables('IBM-AUTOMATION-QUERY-MIB', [
      ['config', 'libraryConfigEntry', 'Classes::IBM::TS4300::Components::EnvironmentalSubsystem::Config'],
      ['chassis', 'frameConfigEntry', 'Classes::IBM::TS4300::Components::EnvironmentalSubsystem::Chassis'],

      #['logicals', 'logicalLibraryConfigTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['drives', 'driveConfigTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['users', 'userConfigTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
  ]);
#  $self->get_snmp_tables('SNIA-SML-MIB', [
#      ['subChassisTable', 'subChassisTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['mediaAccessDeviceTable', 'mediaAccessDeviceTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['physicalPackageTable', 'physicalPackageTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['softwareElementTable', 'softwareElementTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['changerDeviceTable', 'changerDeviceTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['scsiProtocolControllerTable', 'scsiProtocolControllerTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['storageMediaLocationTable', 'storageMediaLocationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['limitedAccessPortTable', 'limitedAccessPortTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['fCPortTable', 'fCPortTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#      ['trapDestinationTable', 'trapDestinationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#  ]);
}

sub icheck {
  my ($self) = @_;
  $self->SUPER::check();
  $self->reduce_messages_short('environmental hardware working fine');
}


package Classes::IBM::TS4300::Components::EnvironmentalSubsystem::Config;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::IBM::TS4300::Components::EnvironmentalSubsystem::Chassis;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s chassis_%s PS (%d drives) status is PS1=%s,PS2=%s',
      $self->{'chassis-IOType'},
      $self->{'chassis-Index'},
      $self->{'chassis-NumberofInstalledDrives'},
      $self->{'chassis-PS1Status'},
      $self->{'chassis-PS2Status'},
  );
  if ($self->{'chassis-NumberofInstalledDrives'} == 0) {
  } elsif ($self->{'chassis-PS1Status'} eq 'notok' &&
      $self->{'chassis-PS2Status'} eq 'notok') {
    $self->add_critical();
  } elsif ($self->{'chassis-PS1Status'} eq 'notok' ||
      $self->{'chassis-PS2Status'} eq 'notok') {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}


