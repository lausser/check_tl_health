$GLPlugin::SNMP::discover_ids = {};

$GLPlugin::SNMP::mib_ids = {
  'SEMI-MIB' => '1.3.6.1.4.1.11.10.2.1.3.25',
  'QUANTUM-SMALL-TAPE-LIBRARY-MIB' => '1.3.6.1.4.1.3697',
  'SPECTRALOGIC-GLOBAL-REG-SLHARDWARE-SLLIBRARIES-SLTSERIES' => '1.3.6.1.4.1.3478.1.1.3',
  'SL-HW-LIB-T950-MIB' => '1.3.6.1.4.1.3478.1.1.3.1.1'
};

$GLPlugin::SNMP::mibs_and_oids = {
  'MIB-II' => {
      sysDescr => '1.3.6.1.2.1.1.1',
      sysObjectID => '1.3.6.1.2.1.1.2',
      sysUpTime => '1.3.6.1.2.1.1.3',
      sysName => '1.3.6.1.2.1.1.5',
      sysORTable => '1.3.6.1.2.1.1.9',
      sysOREntry => '1.3.6.1.2.1.1.9.1',
      sysORIndex => '1.3.6.1.2.1.1.9.1.1',
      sysORID => '1.3.6.1.2.1.1.9.1.2',
      sysORDescr => '1.3.6.1.2.1.1.9.1.3',
      sysORUpTime => '1.3.6.1.2.1.1.9.1.4',
  },
  'SEMI-MIB' => {
      hpWebMgmt => '1.3.6.1.4.1.11.2.36',
      hpHttpMgMod => '1.3.6.1.4.1.11.2.36.1',
      hpHttpMgTraps => '1.3.6.1.4.1.11.2.36.1.0',
      hpHttpMgHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.1',
      hpHttpMgDeviceSpecificEventCode => '1.3.6.1.4.1.11.2.36.1.0.10',
      hpHttpMgDeviceSpecificFRU => '1.3.6.1.4.1.11.2.36.1.0.11',
      hpHttpMgShutdown => '1.3.6.1.4.1.11.2.36.1.0.2',
      hpHttpMgUnknownHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.3',
      hpHttpMgOKHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.4',
      hpHttpMgWarningHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.5',
      hpHttpMgCriticalHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.6',
      hpHttpMgNonRecoverableHealthTrap => '1.3.6.1.4.1.11.2.36.1.0.7',
      hpHttpMgDeviceAddedTrap => '1.3.6.1.4.1.11.2.36.1.0.8',
      hpHttpMgDeviceRemovedTrap => '1.3.6.1.4.1.11.2.36.1.0.9',
      hpHttpMgObjects => '1.3.6.1.4.1.11.2.36.1.1',
      hpHttpMgDefaults => '1.3.6.1.4.1.11.2.36.1.1.1',
      hpHttpMgDefaultURL => '1.3.6.1.4.1.11.2.36.1.1.1.1',
      hpHttpMgNetCitizen => '1.3.6.1.4.1.11.2.36.1.1.2',
      hpHttpMgMgmtSrvrURL => '1.3.6.1.4.1.11.2.36.1.1.2.1',
      hpHttpMgAssetNumber => '1.3.6.1.4.1.11.2.36.1.1.2.10',
      hpHttpMgPhone => '1.3.6.1.4.1.11.2.36.1.1.2.11',
      hpHttpMgID => '1.3.6.1.4.1.11.2.36.1.1.2.2',
      hpHttpMgHealth => '1.3.6.1.4.1.11.2.36.1.1.2.3',
      hpHttpMgHealthDefinition => 'SEMI-MIB::hpHttpMgHealth',
      hpHttpMgManufacturer => '1.3.6.1.4.1.11.2.36.1.1.2.4',
      hpHttpMgProduct => '1.3.6.1.4.1.11.2.36.1.1.2.5',
      hpHttpMgVersion => '1.3.6.1.4.1.11.2.36.1.1.2.6',
      hpHttpMgHWVersion => '1.3.6.1.4.1.11.2.36.1.1.2.7',
      hpHttpMgROMVersion => '1.3.6.1.4.1.11.2.36.1.1.2.8',
      hpHttpMgSerialNumber => '1.3.6.1.4.1.11.2.36.1.1.2.9',
      hpHttpMgEntityNetInfo => '1.3.6.1.4.1.11.2.36.1.1.3',
      hpHttpMgEntityNetInfoTable => '1.3.6.1.4.1.11.2.36.1.1.3.1',
      hpHttpMgEntityNetInfoEntry => '1.3.6.1.4.1.11.2.36.1.1.3.1.1',
      hpHttpMgEntityNetInfoIndex => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.1',
      hpHttpMgEntityNetInfoSysObjID => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.2',
      hpHttpMgEntityNetInfoRelationshipType => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.3',
      hpHttpMgEntityNetInfoUniqueID => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.4',
      hpHttpMgEntityNetInfoURL => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.5',
      hpHttpMgEntityNetInfoURLLabel => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.6',
      hpHttpMgEntityNetInfoIPAddress => '1.3.6.1.4.1.11.2.36.1.1.3.1.1.7',
      hpHttpMgCluster => '1.3.6.1.4.1.11.2.36.1.1.4',
      hpHttpMgClusterName => '1.3.6.1.4.1.11.2.36.1.1.4.1',
      hpHttpMgDeviceInfo => '1.3.6.1.4.1.11.2.36.1.1.5',
      hpHttpMgDeviceTable => '1.3.6.1.4.1.11.2.36.1.1.5.1',
      hpHttpMgDeviceEntry => '1.3.6.1.4.1.11.2.36.1.1.5.1.1',
      hpHttpMgDeviceIndex => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.1',
      hpHttpMgDeviceSerialNumber => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.10',
      hpHttpMgDeviceVersion => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.11',
      hpHttpMgDeviceHWVersion => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.12',
      hpHttpMgDeviceROMVersion => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.13',
      hpHttpMgDeviceAssetNumber => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.14',
      hpHttpMgDeviceContactPerson => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.15',
      hpHttpMgDeviceContactPhone => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.16',
      hpHttpMgDeviceContactEmail => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.17',
      hpHttpMgDeviceContactPagerNumber => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.18',
      hpHttpMgDeviceLocation => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.19',
      hpHttpMgDeviceGlobalUniqueID => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.2',
      hpHttpMgDeviceRackId => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.20',
      hpHttpMgDeviceRackPosition => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.21',
      hpHttpMgDeviceRelationshipType => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.22',
      hpHttpMgDeviceSWID => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.23',
      hpHttpMgDeviceHealth => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.3',
      hpHttpMgDeviceHealthDefinition => 'SEMI-MIB::hpHttpMgDeviceHealth',
      hpHttpMgDeviceSysObjID => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.4',
      hpHttpMgDeviceManagementURL => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.5',
      hpHttpMgDeviceManagementURLLabel => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.6',
      hpHttpMgDeviceManufacturer => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.7',
      hpHttpMgDeviceProductName => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.8',
      hpHttpMgDeviceProductCaption => '1.3.6.1.4.1.11.2.36.1.1.5.1.1.9',

  },
  'QUANTUM-SMALL-TAPE-LIBRARY-MIB' => {
      # bei oidview unter 1.3.6.1.4.1.3764 gefuehrt, wobei 3764 Adic ist
      # quantum OBJECT IDENTIFIER ::= { enterprises 3697 }
      # storage OBJECT IDENTIFIER ::= { quantum 1 }
      # library OBJECT IDENTIFIER ::= { storage 10 }
      # smallTapeLibrarySystem OBJECT IDENTIFIER ::= { smallTapeLibraryMIB 1 }

      smallTapeLibraryMIB => '1.3.6.1.4.1.3697.1.10.10',
      smallTapeLibrarySystem => '1.3.6.1.4.1.3697.1.10.10.1',
      libraryIpAddress => '1.3.6.1.4.1.3697.1.10.10.1.1',
      libraryProductName => '1.3.6.1.4.1.3697.1.10.10.1.10',
      libraryFirmwareVersion => '1.3.6.1.4.1.3697.1.10.10.1.11',
      physicalLibrary => '1.3.6.1.4.1.3697.1.10.10.1.15',
      physicalLibraryState => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::LibraryReadyState',
      rasSubSystem => '1.3.6.1.4.1.3697.1.10.10.1.15.10',
      powerStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.1',
      powerStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      coolingStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.2',
      coolingStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      controlStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.3',
      controlStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      connectivityStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.4',
      connectivityStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      roboticsStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.5',
      roboticsStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      mediaStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.6',
      mediaStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      driveStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.10.7',
      driveStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      operatorActionRequest => '1.3.6.1.4.1.3697.1.10.10.1.15.10.8',
      operatorActionRequestDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::NoYes',
      aggregatedMainDoorStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.2',
      aggregatedMainDoorStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::LibraryDoorStatus',
      aggregatedIEDoorStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.3',
      aggregatedIEDoorStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::IEDoorStatus',
      libraryInterfaces => '1.3.6.1.4.1.3697.1.10.10.1.15.4',
      libraryControl => '1.3.6.1.4.1.3697.1.10.10.1.15.4.1',
      libraryCartridgeSlots => '1.3.6.1.4.1.3697.1.10.10.1.15.5',
      numStorageSlots => '1.3.6.1.4.1.3697.1.10.10.1.15.5.1',
      numCleanSlots => '1.3.6.1.4.1.3697.1.10.10.1.15.5.2',
      numIESlots => '1.3.6.1.4.1.3697.1.10.10.1.15.5.3',
      physicalDrive => '1.3.6.1.4.1.3697.1.10.10.1.15.6',
      numPhDrives => '1.3.6.1.4.1.3697.1.10.10.1.15.6.1',
      overallPhDriveOnlineStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.6.2',
      overallPhDriveOnlineStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::OnlineState',
      overallPhDriveReadinessStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.6.3',
      overallPhDriveReadinessStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::DriveReadyState',
      physicalDriveTable => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4',
      physicalDriveEntry => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1',
      phDriveIndex => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.1',
      phDriveFirmwareVersion => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.10',
      phDriveOnlineState => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.11',
      phDriveOnlineStateDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::OnlineState',
      phDriveReadinessState => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.12',
      phDriveReadinessStateDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::DriveReadyState',
      phDriveRasStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.13',
      phDriveRasStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      phDriveLoads => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.14',
      phDriveCleaningStatus => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.15',
      phDriveCleaningStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::CleaningStatus',
      phDriveLogicalLibraryName => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.16',
      phDriveControlPathDrive => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.17',
      phDriveLocation => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.2',
      phDriveDeviceId => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.3',
      phDriveVendor => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.4',
      phDriveType => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.5',
      phDriveInterfaceType => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.6',
      phDriveInterfaceTypeDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::InterfaceType',
      phDriveAddress => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.7',
      phDrivePhysicalSerialNumber => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.8',
      phDriveLogicalSerialNumber => '1.3.6.1.4.1.3697.1.10.10.1.15.6.4.1.9',
      logicalLibrary => '1.3.6.1.4.1.3697.1.10.10.1.16',
      numLogicalLibraries => '1.3.6.1.4.1.3697.1.10.10.1.16.1',
      logicalLibraryTable => '1.3.6.1.4.1.3697.1.10.10.1.16.2',
      logicalLibraryEntry => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1',
      logicalLibraryIndex => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.1',
      logicalLibraryAutoClean => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.10',
      logicalLibraryAutoCleanDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::OnOff',
      logicalLibraryNumSlots => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.11',
      logicalLibraryNumIE => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.12',
      logicalLibraryNumTapeDrives => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.13',
      logicalLibraryStorageElemAddr => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.14',
      logicalLibraryIEElemAddr => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.15',
      logicalLibraryTapeDriveElemAddr => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.16',
      logicalLibraryChangerDeviceAddr => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.17',
      logicalLibraryName => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.2',
      logicalLibrarySerialNumber => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.3',
      logicalLibraryModel => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.4',
      logicalLibraryInterface => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.5',
      logicalLibraryInterfaceDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::InterfaceMethod',
      logicalLibraryMediaDomain => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.6',
      logicalLibrarySupportedMediaTypes => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.7',
      logicalLibraryOnlineState => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.8',
      logicalLibraryOnlineStateDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::OnlineState',
      logicalLibraryReadyState => '1.3.6.1.4.1.3697.1.10.10.1.16.2.1.9',
      logicalLibraryReadyStateDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::LibraryReadyState',
      librarySNMPAgentDescription => '1.3.6.1.4.1.3697.1.10.10.1.2',
      libraryName => '1.3.6.1.4.1.3697.1.10.10.1.3',
      libraryVendor => '1.3.6.1.4.1.3697.1.10.10.1.4',
      librarySerialNumber => '1.3.6.1.4.1.3697.1.10.10.1.5',
      libraryDescription => '1.3.6.1.4.1.3697.1.10.10.1.6',
      libraryModel => '1.3.6.1.4.1.3697.1.10.10.1.7',
      libraryGlobalStatus => '1.3.6.1.4.1.3697.1.10.10.1.8',
      libraryGlobalStatusDefinition => 'QUANTUM-SMALL-TAPE-LIBRARY-MIB::RASSubSystemStatus',
      libraryURL => '1.3.6.1.4.1.3697.1.10.10.1.9',
  },
# ftp://ftp.spectralogic.com/supportUpload/FIRMWARE/MIBs/
  'SPECTRALOGIC-GLOBAL-REG' => {
    spectralogic => '1.3.6.1.4.1.3478',
    slHardware => '1.3.6.1.4.1.3478.1',
    slLibraries => '1.3.6.1.4.1.3478.1.1',
    slTSeries => '1.3.6.1.4.1.3478.1.1.3',
    slT950 => '1.3.6.1.4.1.3478.1.1.3.1',
  },
  'SL-HW-LIB-T950-MIB' => {
    slT950MIB => '1.3.6.1.4.1.3478.1.1.3.1.1',
    slT950Confs => '1.3.6.1.4.1.3478.1.1.3.1.1.1',
    slT950Groups => '1.3.6.1.4.1.3478.1.1.3.1.1.1.1',
    slT950Compl => '1.3.6.1.4.1.3478.1.1.3.1.1.1.2',
    slT950Objs => '1.3.6.1.4.1.3478.1.1.3.1.1.2',
    slT950LibraryObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1',
    slT950GeneralObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1',
    slT950GeneralStatusObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1',
    slT950GeneralStatusPowerStatus => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.1',
    slT950GeneralStatusPowerStatusDefinition => 'SL-HW-LIB-T950-MIB::SLComponentStatus',
    slT950GeneralStatusFansStatus => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.2',
    slT950GeneralStatusFansStatusDefinition => {
      1 => 'ok',      # Library fans are fully functional
      2 => 'warning', # One or more library fans are impaired or filter is dirty
      3 => 'failure', # Library fans are missing or filter is plugged
    },
    slT950GeneralStatusTap1Status => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.3',
    slT950GeneralStatusTap1StatusDefinition => {
      1 => 'ok',      # Tap 1 is closed
      2 => 'warning', # Tap 1 is open
      3 => 'failure', # Tap 1 is impaired
    },
    slT950GeneralStatusTap2Status => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.4',
    slT950GeneralStatusTap2StatusDefinition => {
      1 => 'ok',
      2 => 'warning',
      3 => 'failure',
    },
    slT950GeneralStatusPartitionCount => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.5',
    slT950GeneralStatusPartitionTable => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6',
    slT950GeneralStatusPartitionEntry => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1',
    slT950GeneralStatusPartitionIndex => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.1',
    slT950GeneralStatusPartitionName => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.2',
    slT950GeneralStatusPartitionTotalAvailableDrives => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.3',
    slT950GeneralStatusPartitionFullDrives => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.4',
    slT950GeneralStatusPartitionTotalAvailableStorageSlots => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.5',
    slT950GeneralStatusPartitionFullStorageSlots => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.6',
    slT950GeneralStatusPartitionTotalAvailableEntryExitSlots => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.7',
    slT950GeneralStatusPartitionFullEntryExitSlots => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.1.6.1.8',
    slT950InventoryObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.1.2',
    slT950ConfigurationObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.2',
    slT950MaintenancelObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.3',
    slT950SecurityObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.4',
    slT950MessageObjs => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5',
    slT950MessageCount => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.1',
    slT950MessageTable => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2',
    slT950MessageEntry => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1',
    slT950MessageIndex => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.1',
    slT950MessageNumber => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.2',
    slT950MessageSeverity => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.3',
    slT950MessageSeverityDefinition => {
      1 => 'info',
      2 => 'warning',
      3 => 'error',
      4 => 'fatal',
    },
    slT950MessageText => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.4',
    slT950MessageRemedyText => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.5',
    slT950MessageTime => '1.3.6.1.4.1.3478.1.1.3.1.1.2.1.5.2.1.6',
    slT950Events => '1.3.6.1.4.1.3478.1.1.3.1.1.3',
    slT950EventsV2 => '1.3.6.1.4.1.3478.1.1.3.1.1.3.0',
    slT950MibModule => '1.3.6.1.4.1.3478.3.1.4',

  },
};

$GLPlugin::SNMP::definitions = {
  'SEMI-MIB' => {
     hpHttpMgHealth => {
       1 => 'unknown',
       2 => 'information',
       3 => 'ok',
       4 => 'warning',
       5 => 'critical',
       6 => 'nonrecoverable',
     },
     hpHttpMgDeviceHealth => {
       1 => 'unknown',
       2 => 'unused',
       3 => 'ok',
       4 => 'warning',
       5 => 'critical',
       6 => 'nonrecoverable',
     },
  },
  'QUANTUM-SMALL-TAPE-LIBRARY-MIB' => {
    OnlineState => {
      1 => 'online',
      2 => 'onlinePending',
      3 => 'offline',
      4 => 'offlinePending',
      5 => 'shutdownPending',
    },
    LibraryReadyState => {
      1 => 'ready',
      2 => 'notReady',
      3 => 'becomingReady',
    },
    DriveReadyState => {
      1 => 'ready',
      2 => 'notReady',
      3 => 'notInstalled',
    },
    InterfaceMethod => {
      1 => 'viaControlPathDrive',
      2 => 'viaConnectionBlade',
      3 => 'viaDriveAndBlade',
    },
    InterfaceType => {
      1 => 'scsi',
      2 => 'fibreChannel',
      3 => 'sas',
      4 => 'iscsi',
    },
    LibraryDoorStatus => {
      1 => 'open',
      2 => 'closed',
      3 => 'unknown',
    },
    IEDoorStatus => {
      1 => 'open',
      2 => 'closedAndLocked',
      3 => 'closedAndUnLocked',
    },
    RASSubSystemStatus => {
      1 => 'good',
      2 => 'failed',
      3 => 'degraded',
      4 => 'warning',
      5 => 'informational',
      6 => 'unknown',
      7 => 'invalid',
    },
    CleaningStatus => {
      1 => 'recommended',
      2 => 'notNeeded',
      3 => 'required',
    },
    NoYes => {
      0 => 'no',
      1 => 'yes',
    },
    OnOff => {
      0 => 'off',
      1 => 'on',
    },
  },
  'SL-HW-LIB-T950-MIB' => {
    'SLComponentStatus' => {
      1 => 'ok',
      2 => 'failure',
    },
  },
};

