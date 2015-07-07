package Classes::BDT::FlexStorII::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('BDT-MIB', (qw(
      bDTGlobalStatus
      bDTDisplayName
      bDTDescription 
      bDTAgentVendor
      bDTAgentVersion
      bDTGlobalData
      bDTGlobalStatus
      bDTGlobalStatusDefinition
      bDTLastGlobalStatus
      bDTLastGlobalStatusDefinition
      bDTTimeStamp
      bDTGetTimeOut
      bDTErrorCode
      bDTRefreshRate
      bDTErrorData
      bDTDeviceInfo
      bDTDevSerialNumber
      bDTDevVendorID
      bDTDevProductID
      bDTDevFirmwareRev
      bDTDevRobFirmwareRev
      bDTDevBootcodeRev
  )));
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "%sstatus is %s", 
      ($self->{bDTDisplayName} ? $self->{bDTDisplayName}." " : ""),
      $self->{bDTGlobalStatus});
  if ($self->{bDTGlobalStatus} =~ /other|unknown/) {
    $self->add_unknown();
  } elsif ($self->{bDTGlobalStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{bDTGlobalStatus} eq "non-critical") {
    $self->annotate_info(sprintf "error: %s code: %s serial: %s",
        $self->{bDTErrorData}, $self->{bDTErrorCode}, $self->{bDTDevSerialNumber});
    $self->add_warning();
  } else {
    $self->annotate_info(sprintf "error: %s code: %s serial: %s",
        $self->{bDTErrorData}, $self->{bDTErrorCode}, $self->{bDTDevSerialNumber});
    $self->add_critical();
  }
}

