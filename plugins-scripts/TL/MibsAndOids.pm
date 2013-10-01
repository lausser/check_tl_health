$TL::Device::mibs_and_oids = {
  'MIB-II' => {
      sysDescr => '1.3.6.1.2.1.1.1',
      sysObjectID => '1.3.6.1.2.1.1.2',
      sysUpTime => '1.3.6.1.2.1.1.3',
      sysName => '1.3.6.1.2.1.1.5',
  },
  'IFMIB' => {
      ifTable => '1.3.6.1.2.1.2.2',
      ifEntry => '1.3.6.1.2.1.2.2.1',
      ifIndex => '1.3.6.1.2.1.2.2.1.1',
      ifDescr => '1.3.6.1.2.1.2.2.1.2',
      ifType => '1.3.6.1.2.1.2.2.1.3',
      ifTypeDefinition => 'IFMIB::ifType',
      ifMtu => '1.3.6.1.2.1.2.2.1.4',
      ifSpeed => '1.3.6.1.2.1.2.2.1.5',
      ifPhysAddress => '1.3.6.1.2.1.2.2.1.6',
      ifAdminStatus => '1.3.6.1.2.1.2.2.1.7',
      ifOperStatus => '1.3.6.1.2.1.2.2.1.8',
      ifLastChange => '1.3.6.1.2.1.2.2.1.9',
      ifInOctets => '1.3.6.1.2.1.2.2.1.10',
      ifInUcastPkts => '1.3.6.1.2.1.2.2.1.11',
      ifInNUcastPkts => '1.3.6.1.2.1.2.2.1.12',
      ifInDiscards => '1.3.6.1.2.1.2.2.1.13',
      ifInErrors => '1.3.6.1.2.1.2.2.1.14',
      ifInUnknownProtos => '1.3.6.1.2.1.2.2.1.15',
      ifOutOctets => '1.3.6.1.2.1.2.2.1.16',
      ifOutUcastPkts => '1.3.6.1.2.1.2.2.1.17',
      ifOutNUcastPkts => '1.3.6.1.2.1.2.2.1.18',
      ifOutDiscards => '1.3.6.1.2.1.2.2.1.19',
      ifOutErrors => '1.3.6.1.2.1.2.2.1.20',
      ifOutQLen => '1.3.6.1.2.1.2.2.1.21',
      ifSpecific => '1.3.6.1.2.1.2.2.1.22',
      ifAdminStatusDefinition => {
          1 => 'up',
          2 => 'down',
          3 => 'testing',
      },
      ifOperStatusDefinition => {
          1 => 'up',
          2 => 'down',
          3 => 'testing',
          4 => 'unknown',
          5 => 'dormant',
          6 => 'notPresent',
          7 => 'lowerLayerDown',
      },
      # INDEX { ifIndex }
      #
      ifXTable => '1.3.6.1.2.1.31.1.1',
      ifXEntry => '1.3.6.1.2.1.31.1.1.1',
      ifName => '1.3.6.1.2.1.31.1.1.1.1',
      ifInMulticastPkts => '1.3.6.1.2.1.31.1.1.1.2',
      ifInBroadcastPkts => '1.3.6.1.2.1.31.1.1.1.3',
      ifOutMulticastPkts => '1.3.6.1.2.1.31.1.1.1.4',
      ifOutBroadcastPkts => '1.3.6.1.2.1.31.1.1.1.5',
      ifHCInOctets => '1.3.6.1.2.1.31.1.1.1.6',
      ifHCInUcastPkts => '1.3.6.1.2.1.31.1.1.1.7',
      ifHCInMulticastPkts => '1.3.6.1.2.1.31.1.1.1.8',
      ifHCInBroadcastPkts => '1.3.6.1.2.1.31.1.1.1.9',
      ifHCOutOctets => '1.3.6.1.2.1.31.1.1.1.10',
      ifHCOutUcastPkts => '1.3.6.1.2.1.31.1.1.1.11',
      ifHCOutMulticastPkts => '1.3.6.1.2.1.31.1.1.1.12',
      ifHCOutBroadcastPkts => '1.3.6.1.2.1.31.1.1.1.13',
      ifLinkUpDownTrapEnable => '1.3.6.1.2.1.31.1.1.1.14',
      ifHighSpeed => '1.3.6.1.2.1.31.1.1.1.15',
      ifPromiscuousMode => '1.3.6.1.2.1.31.1.1.1.16',
      ifConnectorPresent => '1.3.6.1.2.1.31.1.1.1.17',
      ifAlias => '1.3.6.1.2.1.31.1.1.1.18',
      ifCounterDiscontinuityTime => '1.3.6.1.2.1.31.1.1.1.19',
      ifLinkUpDownTrapEnableDefinition => {
          1 => 'enabled',
          2 => 'disabled',
      },
      # ifXEntry AUGMENTS ifEntry
      #
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
};

$TL::Device::definitions = {
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
};
