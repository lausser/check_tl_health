package GLPlugin::SNMP;
our @ISA = qw(GLPlugin);

use strict;
use File::Basename;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use AutoLoader;
our $AUTOLOAD;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

{
  our $mode = undef;
  our $plugin = undef;
  our $blacklist = undef;
  our $session = undef;
  our $rawdata = {};
  our $tablecache = {};
  our $info = [];
  our $extendedinfo = [];
  our $summary = [];
  our $oidtrace = [];
  our $uptime = 0;
}

sub validate_args {
  my $self = shift;
  $self->SUPER::validate_args();
  if ($self->opts->community) {
    if ($self->opts->community =~ /^snmpv3(.)(.+)/) {
      my $separator = $1;
      my ($authprotocol, $authpassword, $privprotocol, $privpassword, $username) =
          split(/$separator/, $2);
      $self->override_opt('authprotocol', $authprotocol) 
          if defined($authprotocol) && $authprotocol;
      $self->override_opt('authpassword', $authpassword) 
          if defined($authpassword) && $authpassword;
      $self->override_opt('privprotocol', $privprotocol) 
          if defined($privprotocol) && $privprotocol;
      $self->override_opt('privpassword', $privpassword) 
          if defined($privpassword) && $privpassword;
      $self->override_opt('username', $username) 
          if defined($username) && $username;
      $self->override_opt('protocol', '3') ;
    }
  }
  if ($self->opts->mode eq 'walk') {
    if ($self->opts->snmpwalk && $self->opts->hostname) {
      # snmp agent wird abgefragt, die ergebnisse landen in einem file
      # opts->snmpwalk ist der filename. da sich die ganzen get_snmp_table/object-aufrufe
      # an das walkfile statt an den agenten halten wuerden, muss opts->snmpwalk geloescht
      # werden. stattdessen wird opts->snmpdump als traeger des dateinamens mitgegeben.
      # nur sinnvoll mit mode=walk
      $self->create_opt('snmpdump');
      $self->override_opt('snmpdump', $self->opts->snmpwalk);
      $self->override_opt('snmpwalk', undef);
    } elsif (! $self->opts->snmpwalk && $self->opts->hostname && $self->opts->mode eq 'walk') {   
      # snmp agent wird abgefragt, die ergebnisse landen in einem file, dessen name
      # nicht vorgegeben ist
      $self->create_opt('snmpdump');
    }
  } else {    
    if (exists $ENV{NAGIOS__HOSTSNMPWALK} || exists $ENV{NAGIOS__SERVICESNMPWALK}) {
      $self->override_opt('snmpwalk', $ENV{NAGIOS__SERVICESNMPWALK} || $ENV{NAGIOS__HOSTSNMPWALK}); 
      $self->override_opt('offline', $ENV{NAGIOS__SERVICEOFFLINE} || $ENV{NAGIOS__HOSTOFFLIN});
    }
    if ($self->opts->snmpwalk && ! $self->opts->hostname) {
      # normaler aufruf, mode != walk, oid-quelle ist eine datei
      $self->override_opt('hostname', 'snmpwalk.file'.md5_hex($self->opts->snmpwalk))
    } elsif ($self->opts->snmpwalk && $self->opts->hostname) {
      # snmpwalk hat vorrang
      $self->override_opt('hostname', undef);
    }
  }
}

sub init {
  my $self = shift;
  if ($self->mode =~ /device::walk/) {
    my @trees = ();
    my $name = $0;
    $name =~ s/.*\///g;
    $name = sprintf "/tmp/snmpwalk_%s_%s", $name, $self->opts->hostname;
    if ($self->opts->oids) {
      # create pid filename
      # already running?;x
      @trees = split(",", $self->opts->oids);

    } elsif ($self->can("trees")) {
      @trees = $self->trees;
    }
    if ($self->opts->snmpdump) {
      $name = $self->opts->snmpdump;
    }
    if (defined $self->opts->offline) {
      $self->{pidfile} = $name.".pid";
      if (! $self->check_pidfile()) {
        $self->trace("Exiting because another walk is already running");
        printf STDERR "Exiting because another walk is already running\n";
        exit 3;
      }
      $self->write_pidfile();
      my $timedout = 0;
      my $snmpwalkpid = 0;
      $SIG{'ALRM'} = sub {
        $timedout = 1;
        printf "UNKNOWN - %s timed out after %d seconds\n",
            $GLPlugin::plugin->{name}, $self->opts->timeout;
        kill 9, $snmpwalkpid;
      };
      alarm($self->opts->timeout);
      unlink $name.".partial";
      while (! $timedout && @trees) {
        my $tree = shift @trees;
        $SIG{CHLD} = 'IGNORE';
        my $cmd = sprintf "snmpwalk -ObentU -v%s -c %s %s %s >> %s", 
            $self->opts->protocol,
            $self->opts->community,
            $self->opts->hostname,
            $tree, $name.".partial";
        $self->trace($cmd);
        $snmpwalkpid = fork;
        if (not $snmpwalkpid) {
          exec($cmd);
        } else {
          wait();
        }
      }
      rename $name.".partial", $name if ! $timedout;
      -f $self->{pidfile} && unlink $self->{pidfile};
      if ($timedout) {
        printf "CRITICAL - timeout. There are still %d snmpwalks left\n", scalar(@trees);
        exit 3;
      } else {
        printf "OK - all requested oids are in %s\n", $name;
      }
    } else {
      printf "rm -f %s\n", $name;
      foreach ($self->trees) {
        printf "snmpwalk -ObentU -v%s -c %s %s %s >> %s\n", 
            $self->opts->protocol,
            $self->opts->community,
            $self->opts->hostname,
            $_, $name;
      }
    }
    exit 0;
  } elsif ($self->mode =~ /device::uptime/) {
    $self->add_info(sprintf 'device is up since %s',
        $self->human_timeticks($self->{uptime}));
    $self->set_thresholds(warning => '15:', critical => '5:');
    $self->add_message($self->check_thresholds($self->{uptime}));
    $self->add_perfdata(
        label => 'uptime',
        value => $self->{uptime} / 60,
        places => 0,
    );
    my ($code, $message) = $self->check_messages(join => ', ', join_all => ', ');
    $GLPlugin::plugin->nagios_exit($code, $message);
  }
}

sub check_snmp_and_model {
  my $self = shift;
  $GLPlugin::SNMP::mibs_and_oids->{'MIB-II'} = {
    sysDescr => '1.3.6.1.2.1.1.1',
    sysObjectID => '1.3.6.1.2.1.1.2',
    sysUpTime => '1.3.6.1.2.1.1.3',
    sysName => '1.3.6.1.2.1.1.5',
  };
  if ($self->opts->snmpwalk) {
    my $response = {};
    if (! -f $self->opts->snmpwalk) {
      $self->add_message(CRITICAL, 
          sprintf 'file %s not found',
          $self->opts->snmpwalk);
    } elsif (-x $self->opts->snmpwalk) {
      my $cmd = sprintf "%s -ObentU -v%s -c%s %s 1.3.6.1.4.1 2>&1",
          $self->opts->snmpwalk,
          $self->opts->protocol,
          $self->opts->community,
          $self->opts->hostname;
      open(WALK, "$cmd |");
      while (<WALK>) {
        if (/^([\.\d]+) = .*?: (\-*\d+)/) {
          $response->{$1} = $2;
        } elsif (/^([\.\d]+) = .*?: "(.*?)"/) {
          $response->{$1} = $2;
          $response->{$1} =~ s/\s+$//;
        }
      }
      close WALK;
    } else {
      if (defined $self->opts->offline) {
        if ((time - (stat($self->opts->snmpwalk))[9]) > $self->opts->offline) {
          $self->add_message(UNKNOWN,
              sprintf 'snmpwalk file %s is too old', $self->opts->snmpwalk);
        }
      }
      $self->opts->override_opt('hostname', 'walkhost');
      open(MESS, $self->opts->snmpwalk);
      while(<MESS>) {
        # SNMPv2-SMI::enterprises.232.6.2.6.7.1.3.1.4 = INTEGER: 6
        if (/^([\d\.]+) = .*?INTEGER: .*\((\-*\d+)\)/) {
          # .1.3.6.1.2.1.2.2.1.8.1 = INTEGER: down(2)
          $response->{$1} = $2;
        } elsif (/^([\d\.]+) = .*?Opaque:.*?Float:.*?([\-\.\d]+)/) {
          # .1.3.6.1.4.1.2021.10.1.6.1 = Opaque: Float: 0.938965
          $response->{$1} = $2;
        } elsif (/^([\d\.]+) = STRING:\s*$/) {
          $response->{$1} = "";
        } elsif (/^([\d\.]+) = Network Address: (.*)/) {
          $response->{$1} = $2;
        } elsif (/^([\d\.]+) = Hex-STRING: (.*)/) {
          $response->{$1} = "0x".$2;
          $response->{$1} =~ s/\s+$//;
        } elsif (/^([\d\.]+) = \w+: (\-*\d+)/) {
          $response->{$1} = $2;
        } elsif (/^([\d\.]+) = \w+: "(.*?)"/) {
          $response->{$1} = $2;
          $response->{$1} =~ s/\s+$//;
        } elsif (/^([\d\.]+) = \w+: (.*)/) {
          $response->{$1} = $2;
          $response->{$1} =~ s/\s+$//;
        } elsif (/^([\d\.]+) = (\-*\d+)/) {
          $response->{$1} = $2;
        } elsif (/^([\d\.]+) = "(.*?)"/) {
          $response->{$1} = $2;
          $response->{$1} =~ s/\s+$//;
        }
      }
      close MESS;
    }
    foreach my $oid (keys %$response) {
      if ($oid =~ /^\./) {
        my $nodot = $oid;
        $nodot =~ s/^\.//g;
        $response->{$nodot} = $response->{$oid};
        delete $response->{$oid};
      }
    }
    map { $response->{$_} =~ s/^\s+//; $response->{$_} =~ s/\s+$//; }
        keys %$response;
    $self->set_rawdata($response);
  } else {
    if (eval "require Net::SNMP") {
      my %params = ();
      my $net_snmp_version = Net::SNMP->VERSION(); # 5.002000 or 6.000000
      $params{'-translate'} = [ # because we see "NULL" coming from socomec devices
        -all => 0x0,
        -nosuchobject => 1,
        -nosuchinstance => 1,
        -endofmibview => 1,
        -unsigned => 1,
      ];
      $params{'-hostname'} = $self->opts->hostname;
      $params{'-version'} = $self->opts->protocol;
      if ($self->opts->port) {
        $params{'-port'} = $self->opts->port;
      }
      if ($self->opts->domain) {
        $params{'-domain'} = $self->opts->domain;
      }
      if ($self->opts->protocol eq '3') {
        $params{'-username'} = $self->opts->username;
        if ($self->opts->authpassword) {
          $params{'-authpassword'} = $self->opts->authpassword;
        }
        if ($self->opts->authprotocol) {
          $params{'-authprotocol'} = $self->opts->authprotocol;
        }
        if ($self->opts->privpassword) {
          $params{'-privpassword'} = $self->opts->privpassword;
        }
        if ($self->opts->privprotocol) {
          $params{'-privprotocol'} = $self->opts->privprotocol;
        }
      } else {
        $params{'-community'} = $self->opts->community;
      }
      my ($session, $error) = Net::SNMP->session(%params);
      if (! defined $session) {
        $self->add_message(CRITICAL, 
            sprintf 'cannot create session object: %s', $error);
        $self->debug(Data::Dumper::Dumper(\%params));
      } else {
        my $max_msg_size = $session->max_msg_size();
        $session->max_msg_size(4 * $max_msg_size);
        $GLPlugin::SNMP::session = $session;
      }
    } else {
      $self->add_message(CRITICAL,
          'could not find Net::SNMP module');
    }
  }
  if (! $self->check_messages()) {
    my $sysUptime = $self->get_snmp_object('MIB-II', 'sysUpTime', 0);
    my $sysDescr = $self->get_snmp_object('MIB-II', 'sysDescr', 0);
    if (defined $sysUptime && defined $sysDescr) {
      $self->{uptime} = $self->timeticks($sysUptime);
      $self->{productname} = $sysDescr;
      $self->{sysobjectid} = $self->get_snmp_object('MIB-II', 'sysObjectID', 0);
      $self->debug(sprintf 'uptime: %s', $self->{uptime});
      $self->debug(sprintf 'up since: %s',
          scalar localtime (time - $self->{uptime}));
      $GLPlugin::SNMP::uptime = $self->{uptime};
      $self->debug('whoami: '.$self->{productname});
    } else {
      $self->add_message(CRITICAL,
          'could not contact snmp agent, got neither sysUptime nor sysDescr');
      $GLPlugin::SNMP::session->close if $GLPlugin::SNMP::session;
    }
  }
}

sub create_statefile {
  my $self = shift;
  my %params = @_;
  my $extension = "";
  $extension .= $params{name} ? '_'.$params{name} : '';
  if ($self->opts->community) {
    $extension .= md5_hex($self->opts->community);
  }
  $extension =~ s/\//_/g;
  $extension =~ s/\(/_/g;
  $extension =~ s/\)/_/g;
  $extension =~ s/\*/_/g;
  $extension =~ s/\s/_/g;
  if ($self->opts->snmpwalk && ! $self->opts->hostname) {
    return sprintf "%s/%s_%s%s", $self->statefilesdir(),
        'snmpwalk.file'.md5_hex($self->opts->snmpwalk),
        $self->opts->mode, lc $extension;
  } elsif ($self->opts->snmpwalk && $self->opts->hostname eq "walkhost") {
    return sprintf "%s/%s_%s%s", $self->statefilesdir(),
        'snmpwalk.file'.md5_hex($self->opts->snmpwalk),
        $self->opts->mode, lc $extension;
  } else {
    return sprintf "%s/%s_%s%s", $self->statefilesdir(),
        $self->opts->hostname, $self->opts->mode, lc $extension;
  }
}

sub discover_suitable_class {
  my $self = shift;
  my $sysobj = $self->get_snmp_object('MIB-II', 'sysObjectID', 0);
  if ($sysobj && exists $GLPlugin::SNMP::discover_ids->{$sysobj}) {
    return $GLPlugin::SNMP::discover_ids->{$sysobj};
  }
}

sub implements_mib {
  my $self = shift;
  my $mib = shift;
  if (! exists $GLPlugin::SNMP::mib_ids->{$mib}) {
    return 0;
  }
  my $sysobj = $self->get_snmp_object('MIB-II', 'sysObjectID', 0);
  $sysobj =~ s/^\.// if $sysobj;
  if ($sysobj && $sysobj eq $GLPlugin::SNMP::mib_ids->{$mib}) {
    $self->debug(sprintf "implements %s (sysobj exact)", $mib);
    return 1;
  }
  if ($GLPlugin::SNMP::mib_ids->{$mib} eq
      substr $sysobj, 0, length $GLPlugin::SNMP::mib_ids->{$mib}) {
    $self->debug(sprintf "implements %s (sysobj)", $mib);
    return 1;
  }
  # some mibs are only composed of tables
  my $traces = $self->opts->snmpwalk ?
    {@{[map {$_, $self->rawdata->{$_} } grep { substr($_, 0, length($GLPlugin::SNMP::mib_ids->{$mib})) eq $GLPlugin::SNMP::mib_ids->{$mib} }
    keys %{$self->rawdata}]}}
    :
    $GLPlugin::SNMP::session->get_next_request(
        -varbindlist => [
            $GLPlugin::SNMP::mib_ids->{$mib}
        ]
    );
  if ($traces && # must find oids following to the ident-oid
      ! exists $traces->{$GLPlugin::SNMP::mib_ids->{$mib}} && # must not be the ident-oid
      grep { # following oid is inside this tree
          substr($_, 0, length($GLPlugin::SNMP::mib_ids->{$mib})) eq $GLPlugin::SNMP::mib_ids->{$mib};
      } keys %{$traces}) {
    $self->debug(sprintf "implements %s (found traces)", $mib);
    return 1;
  }
}

sub timeticks {
  my $self = shift;
  my $timestr = shift;
  if ($timestr =~ /\((\d+)\)/) {
    # Timeticks: (20718727) 2 days, 9:33:07.27
    $timestr = $1 / 100;
  } elsif ($timestr =~ /(\d+)\s*day[s]*.*?(\d+):(\d+):(\d+)\.(\d+)/) {
    # Timeticks: 2 days, 9:33:07.27
    $timestr = $1 * 24 * 3600 + $2 * 3600 + $3 * 60 + $4;
  } elsif ($timestr =~ /(\d+):(\d+):(\d+)\.(\d+)/) {
    # Timeticks: 9:33:07.27
    $timestr = $1 * 3600 + $2 * 60 + $3;
  } elsif ($timestr =~ /(\d+)\s*hour[s]*.*?(\d+):(\d+)\.(\d+)/) {
    # Timeticks: 3 hours, 42:17.98
    $timestr = $1 * 3600 + $2 * 60 + $3;
  } elsif ($timestr =~ /(\d+)\s*minute[s]*.*?(\d+)\.(\d+)/) {
    # Timeticks: 36 minutes, 01.96
    $timestr = $1 * 60 + $2;
  } elsif ($timestr =~ /(\d+)\.\d+\s*second[s]/) {
    # Timeticks: 01.02 seconds
    $timestr = $1;
  } elsif ($timestr =~ /^(\d+)$/) {
    $timestr = $1 / 100;
  }
  return $timestr;
}

sub human_timeticks {
  my $self = shift;
  my $timeticks = shift;
  my $days = int($timeticks / 86400);
  $timeticks -= ($days * 86400);
  my $hours = int($timeticks / 3600);
  $timeticks -= ($hours * 3600);
  my $minutes = int($timeticks / 60);
  my $seconds = $timeticks % 60;
  $days = $days < 1 ? '' : $days .'d ';
  return $days . sprintf "%dh %dm %ds", $hours, $minutes, $seconds;
}

sub get_snmp_object {
  my $self = shift;
  my $mib = shift;
  my $mo = shift;
  my $index = shift;
  if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
      exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$mo}) {
    my $oid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$mo}.
        (defined $index ? '.'.$index : '');
    my $response = $self->get_request(-varbindlist => [$oid]);
    if (defined $response->{$oid}) {
      if ($response->{$oid} eq 'noSuchInstance' || $response->{$oid} eq 'noSuchObject') {
        $response->{$oid} = undef;
      } elsif (my @symbols = $self->make_symbolic($mib, $response, [[$index]])) {
        $response->{$oid} = $symbols[0]->{$mo};
      }
    }
    $self->debug(sprintf "GET: %s::%s (%s) : %s", $mib, $mo, $oid, defined $response->{$oid} ? $response->{$oid} : "<undef>");
    return $response->{$oid};
  }
  return undef;
}

sub get_snmp_objects {
  my $self = shift;
  my $mib = shift;
  my @mos = @_;
  foreach (@mos) {
    my $value = $self->get_snmp_object($mib, $_, 0);
    if (defined $value) {
      $self->{$_} = $value;
    } else {
      my $value = $self->get_snmp_object($mib, $_);
      if (defined $value) {
        $self->{$_} = $value;
      }
    }
  }
}

sub get_single_request_iq {
  my $self = shift;
  my %params = @_;
  my @oids = ();
  my $result = $self->get_request_iq(%params);
  foreach (keys %{$result}) {
    return $result->{$_};
  }
  return undef;
}

sub get_request_iq {
  my $self = shift;
  my %params = @_;
  my @oids = ();
  my $mib = $params{'-mib'};
  foreach my $oid (@{$params{'-molist'}}) {
    if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
        exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$oid}) {
      push(@oids, (exists $params{'-index'}) ?
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$oid}.'.'.$params{'-index'} :
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$oid});
    }
  }
  return $self->get_request(
      -varbindlist => \@oids);
}

sub valid_response {
  my $self = shift;
  my $mib = shift;
  my $oid = shift;
  my $index = shift;
  if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
      exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$oid}) {
    # make it numerical
    my $oid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$oid};
    if (defined $index) {
      $oid .= '.'.$index;
    }
    my $result = $self->get_request(
        -varbindlist => [$oid]
    );
    if (!defined($result) ||
        ! defined $result->{$oid} ||
        $result->{$oid} eq 'noSuchInstance' ||
        $result->{$oid} eq 'noSuchObject' ||
        $result->{$oid} eq 'endOfMibView') {
      return undef;
    } else {
      $self->add_rawdata($oid, $result->{$oid});
      return $result->{$oid};
    }
  } else {
    return undef;
  }
}

sub uptime {
  my $self = shift;
  return $GLPlugin::SNMP::uptime;
}

sub set_rawdata {
  my $self = shift;
  $GLPlugin::SNMP::rawdata = shift;
}

sub add_rawdata {
  my $self = shift;
  my $oid = shift;
  my $value = shift;
  $GLPlugin::SNMP::rawdata->{$oid} = $value;
}

sub rawdata {
  my $self = shift;
  return $GLPlugin::SNMP::rawdata;
}

sub add_oidtrace {
  my $self = shift;
  my $oid = shift;
  $self->debug("cache: ".$oid);
  push(@{$GLPlugin::SNMP::oidtrace}, $oid);
}

sub get_snmp_table_attributes {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $indices = shift || [];
  my @entries = ();
  my $augmenting_table;
  if ($table =~ /^(.*?)\+(.*)/) {
    $table = $1;
    $augmenting_table = $2;
  }
  my $entry = $table;
  $entry =~ s/Table/Entry/g;
  if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
      exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}) {
    my $toid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}.'.';
    my $toidlen = length($toid);
    my @columns = grep {
      substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $toidlen) eq
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}.'.'
    } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}};
    if ($augmenting_table &&
        exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}) {
      my $toid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}.'.';
      my $toidlen = length($toid);
      push(@columns, grep {
        substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $toidlen) eq
            $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}.'.'
      } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}});
    }
    return @columns;
  } else {
    return ();
  }
}

sub get_request {
  my $self = shift;
  my %params = @_;
  my @notcached = ();
  foreach my $oid (@{$params{'-varbindlist'}}) {
    $self->add_oidtrace($oid);
    if (! exists $GLPlugin::SNMP::rawdata->{$oid}) {
      push(@notcached, $oid);
    }
  }
  if (! $self->opts->snmpwalk && (scalar(@notcached) > 0)) {
    my $result = ($GLPlugin::SNMP::session->version() == 0) ?
        $GLPlugin::SNMP::session->get_request(
            -varbindlist => \@notcached,
        )
        :
        $GLPlugin::SNMP::session->get_request(  # get_bulk_request liefert next
            #-nonrepeaters => scalar(@notcached),
            -varbindlist => \@notcached,
        );
    foreach my $key (%{$result}) {
      $self->add_rawdata($key, $result->{$key});
    }
  }
  my $result = {};
  map { $result->{$_} = $GLPlugin::SNMP::rawdata->{$_} }
      @{$params{'-varbindlist'}};
  return $result;
}

# Level1
# get_snmp_table_objects('MIB-Name', 'Table-Name', 'Table-Entry', [indices])
#
# returns array of hashrefs
# evt noch ein weiterer parameter fuer ausgewaehlte oids
#
sub get_snmp_table_objects_with_cache {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  #return $self->get_snmp_table_objects($mib, $table);
  $self->update_entry_cache(0, $mib, $table, $key_attr);
  my @indices = $self->get_cache_indices($mib, $table, $key_attr);
  my @entries = ();
  foreach ($self->get_snmp_table_objects($mib, $table, \@indices)) {
    push(@entries, $_);
  }
  return @entries;
}

sub get_snmp_table_objects {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $indices = shift || [];
  my @entries = ();
  my $augmenting_table;
  $self->debug(sprintf "get_snmp_table_objects %s %s", $mib, $table);
  if ($table =~ /^(.*?)\+(.*)/) {
    $table = $1;
    $augmenting_table = $2;
  }
  my $entry = $table;
  $entry =~ s/Table/Entry/g;
  if (scalar(@{$indices}) == 1) {
    if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
        exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}) {
      my $eoid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.';
      my $eoidlen = length($eoid);
      my @columns = map {
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}
      } grep {
        substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $eoidlen) eq
            $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.'
      } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}};
      my $index = join('.', @{$indices->[0]});
      if ($augmenting_table && 
          exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}) {
        my $augmenting_entry = $augmenting_table;
        $augmenting_entry =~ s/Table/Entry/g;
        my $eoid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_entry}.'.';
        my $eoidlen = length($eoid);
        push(@columns, map {
            $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}
        } grep {
          substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $eoidlen) eq
              $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}.'.'
        } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}});
      }
      my  $result = $self->get_entries(
          -startindex => $index,
          -endindex => $index,
          -columns => \@columns,
      );
      @entries = $self->make_symbolic($mib, $result, $indices);
      @entries = map { $_->{indices} = shift @{$indices}; $_ } @entries;
    }
  } elsif (scalar(@{$indices}) > 1) {
    # man koennte hier pruefen, ob die indices aufeinanderfolgen
    # und dann get_entries statt get_table aufrufen
    if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
        exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}) {
      my $result = {};
      my $eoid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.';
      my $eoidlen = length($eoid);
      my @columns = map {
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}
      } grep {
        substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $eoidlen) eq
            $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.'
      } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}};
      my @sortedindices = map { $_->[0] }
          sort { $a->[1] cmp $b->[1] }
              map { [$_,
                  join '', map { sprintf("%30d",$_) } split( /\./, $_)
              ] } map { join('.', @{$_})} @{$indices};
      my $startindex = $sortedindices[0];
      my $endindex = $sortedindices[$#sortedindices];
      if (0) {
        # holzweg. dicke ciscos liefern unvollstaendiges resultat, d.h.
        # bei 138,19,157 kommt nur 138..144, dann ist schluss.
        # maxrepetitions bringt nichts.
        $result = $self->get_entries(
            -startindex => $startindex,
            -endindex => $endindex,
            -columns => \@columns,
        );
        if (! $result) {
          $result = $self->get_entries(
              -startindex => $startindex,
              -endindex => $endindex,
              -columns => \@columns,
              -maxrepetitions => 0,
          );
        }
      } else {
        foreach my $ifidx (@sortedindices) {
          my $ifresult = $self->get_entries(
              -startindex => $ifidx,
              -endindex => $ifidx,
              -columns => \@columns,
          );
          map { $result->{$_} = $ifresult->{$_} }
              keys %{$ifresult};
        }
      }
      if ($augmenting_table &&
          exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$augmenting_table}) {
        my $entry = $augmenting_table;
        $entry =~ s/Table/Entry/g;
        my $eoid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.';
        my $eoidlen = length($eoid);
        my @columns = map {
            $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}
        } grep {
          substr($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$_}, 0, $eoidlen) eq
              $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry}.'.'
        } keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}};
        foreach my $ifidx (@sortedindices) {
          my $ifresult = $self->get_entries(
              -startindex => $ifidx,
              -endindex => $ifidx,
              -columns => \@columns,
          );
          map { $result->{$_} = $ifresult->{$_} }
              keys %{$ifresult};
        }
      }
      # now we have numerical_oid+index => value
      # needs to become symboic_oid => value
      #my @indices =
      # $self->get_indices($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry});
      @entries = $self->make_symbolic($mib, $result, $indices);
      @entries = map { $_->{indices} = shift @{$indices}; $_ } @entries;
    }
  } else {
    if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
        exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}) {
      $self->debug(sprintf "get_snmp_table_objects calls get_table %s",
          $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table});
      my $result = $self->get_table(
          -baseoid => $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table});
      $self->debug(sprintf "get_snmp_table_objects get_table returns %d oids",
          scalar(keys %{$result}));
      # now we have numerical_oid+index => value
      # needs to become symboic_oid => value
      my @indices = 
          $self->get_indices(
              -baseoid => $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$entry},
              -oids => [keys %{$result}]);
      $self->debug(sprintf "get_snmp_table_objects get_table returns %d indices",
          scalar(@indices));
      @entries = $self->make_symbolic($mib, $result, \@indices);
      @entries = map { $_->{indices} = shift @indices; $_ } @entries;
    }
  }
  @entries = map { $_->{flat_indices} = join(".", @{$_->{indices}}); $_ } @entries;
  return @entries;
}

sub get_snmp_tables {
  my $self = shift;
  my $mib = shift;
  my $infos = shift;
  foreach my $info (@{$infos}) {
    my $arrayname = $info->[0];
    my $table = $info->[1];
    my $class = $info->[2];
    my $filter = $info->[3];
    $self->{$arrayname} = [] if ! exists $self->{$arrayname};
    if (! exists $GLPlugin::SNMP::tablecache->{$mib} || ! exists $GLPlugin::SNMP::tablecache->{$mib}->{$table}) {
      $GLPlugin::SNMP::tablecache->{$mib}->{$table} = [];
      foreach ($self->get_snmp_table_objects($mib, $table)) {
        my $new_object = $class->new(%{$_});
        next if (defined $filter && ! &$filter($new_object));
        push(@{$self->{$arrayname}}, $new_object);
        push(@{$GLPlugin::SNMP::tablecache->{$mib}->{$table}}, $new_object);
      }
    } else {
      $self->debug(sprintf "get_snmp_tables %s %s cache hit", $mib, $table);
      foreach (@{$GLPlugin::SNMP::tablecache->{$mib}->{$table}}) {
        push(@{$self->{$arrayname}}, $_);
      }
    }
  }
}

# make_symbolic
# mib is the name of a mib (must be in mibs_and_oids)
# result is a hash-key oid->value
# indices is a array ref of array refs. [[1],[2],...] or [[1,0],[1,1],[2,0]..
sub make_symbolic {
  my $self = shift;
  my $mib = shift;
  my $result = shift;
  my $indices = shift;
  my @entries = ();
  if (! wantarray && ref(\$result) eq "SCALAR" && ref(\$indices) eq "SCALAR") {
    # $self->make_symbolic('CISCO-IETF-NAT-MIB', 'cnatProtocolStatsName', $self->{cnatProtocolStatsName});
    my $oid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$result};
    $result = { $oid => $self->{$result} };
    $indices = [[]];
  }
  foreach my $index (@{$indices}) {
    # skip [], [[]], [[undef]]
    if (ref($index) eq "ARRAY") {
      if (scalar(@{$index}) == 0) {
        next;
      } elsif (!defined $index->[0]) {
        next;
      }
    }
    my $mo = {};
    my $idx = join('.', @{$index}); # index can be multi-level
    foreach my $symoid
        (keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}}) {
      my $oid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid};
      if (ref($oid) ne 'HASH') {
        my $fulloid = $oid . '.'.$idx;
        if (exists $result->{$fulloid}) {
          if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}) {
            if (ref($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}) eq 'HASH') {
              if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}->{$result->{$fulloid}}) {
                $mo->{$symoid} = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}->{$result->{$fulloid}};
              } else {
                $mo->{$symoid} = 'unknown_'.$result->{$fulloid};
              }
            } elsif ($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'} =~ /^OID::(.*)/) {
              my $othermib = $1;
              my @result = grep { $GLPlugin::SNMP::mibs_and_oids->{$othermib}->{$_} eq $result->{$fulloid} } keys %{$GLPlugin::SNMP::mibs_and_oids->{$othermib}};
              if (scalar(@result)) {
                $mo->{$symoid} = $result[0];
              } else {
                $mo->{$symoid} = 'unknown_'.$result->{$fulloid};
              }
            } elsif ($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'} =~ /^(.*?)::(.*)/) {
              my $mib = $1;
              my $definition = $2;
              if  (exists $GLPlugin::SNMP::definitions->{$mib} && exists $GLPlugin::SNMP::definitions->{$mib}->{$definition}
                  && exists $GLPlugin::SNMP::definitions->{$mib}->{$definition}->{$result->{$fulloid}}) {
                $mo->{$symoid} = $GLPlugin::SNMP::definitions->{$mib}->{$definition}->{$result->{$fulloid}};
              } else {
                $mo->{$symoid} = 'unknown_'.$result->{$fulloid};
              }
            } else {
              $mo->{$symoid} = 'unknown_'.$result->{$fulloid};
              # oder $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}?
            }
          } else {
            $mo->{$symoid} = $result->{$fulloid};
          }
        }
      }
    }
    push(@entries, $mo);
  }
  if (@{$indices} and scalar(@{$indices}) == 1 and !defined $indices->[0]->[0]) {
    my $mo = {};
    foreach my $symoid
        (keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}}) {
      my $oid = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid};
      if (ref($oid) ne 'HASH') {
        if (exists $result->{$oid}) {
          if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}) {
            if (ref($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}) eq 'HASH') {
              if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}->{$result->{$oid}}) {
                $mo->{$symoid} = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}->{$result->{$oid}};
                push(@entries, $mo);
              }
            } elsif ($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'} =~ /^(.*?)::(.*)/) {
              my $mib = $1;
              my $definition = $2;
              if  (exists $GLPlugin::SNMP::definitions->{$mib} && exists $GLPlugin::SNMP::definitions->{$mib}->{$definition}
                  && exists $GLPlugin::SNMP::definitions->{$mib}->{$definition}->{$result->{$oid}}) {
                $mo->{$symoid} = $GLPlugin::SNMP::definitions->{$mib}->{$definition}->{$result->{$oid}};
              } else {
                $mo->{$symoid} = 'unknown_'.$result->{$oid};
              }
            } else {
              $mo->{$symoid} = 'unknown_'.$result->{$oid};
              # oder $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$symoid.'Definition'}?
            }
          }
        }
      }
    }
    push(@entries, $mo) if keys %{$mo};
  }
  if (wantarray) {
    return @entries;
  } else {
    foreach my $entry (@entries) {
      foreach my $key (keys %{$entry}) {
        $self->{$key} = $entry->{$key};
      }
    }
  }
}

# Level2
# - get_table from Net::SNMP
# - get all baseoid-matching oids from rawdata
sub get_table {
  my $self = shift;
  my %params = @_;
  $self->add_oidtrace($params{'-baseoid'});
  if (! $self->opts->snmpwalk) {
    my @notcached = ();
    $self->debug(sprintf "get_table %s", Data::Dumper::Dumper(\%params));
    my $result = $GLPlugin::SNMP::session->get_table(%params);
    $self->debug(sprintf "get_table returned %d oids", scalar(keys %{$result}));
    if (scalar(keys %{$result}) == 0) {
      $self->debug(sprintf "get_table error: %s", 
          $GLPlugin::SNMP::session->error());
      $self->debug("get_table error: try fallback");
      $params{'-maxrepetitions'} = 1;
      $self->debug(sprintf "get_table %s", Data::Dumper::Dumper(\%params));
      $result = $GLPlugin::SNMP::session->get_table(%params);
      $self->debug(sprintf "get_table returned %d oids", scalar(keys %{$result}));
      if (scalar(keys %{$result}) == 0) {
        $self->debug(sprintf "get_table error: %s", 
            $GLPlugin::SNMP::session->error());
        $self->debug("get_table error: no more fallbacks. Try --protocol 1");
      }
    }
    # Drecksstinkstiefel Net::SNMP
    # '1.3.6.1.2.1.2.2.1.22.4 ' => 'endOfMibView',
    # '1.3.6.1.2.1.2.2.1.22.4' => '0.0',
    foreach my $key (keys %{$result}) {
      if (substr($key, -1) eq " ") {
        my $value = $result->{$key};
        delete $result->{$key};
        (my $shortkey = $key) =~ s/\s+$//g;
        if (! exists $result->{shortkey}) {
          $result->{$shortkey} = $value;
        }
        $self->add_rawdata($key, $result->{$key}) if exists $result->{$key};
      } else {
        $self->add_rawdata($key, $result->{$key});
      }
    }
  }
  return $self->get_matching_oids(
      -columns => [$params{'-baseoid'}]);
}

sub get_entries {
  my $self = shift;
  my %params = @_;
  # [-startindex]
  # [-endindex]
  # -columns
  my $result = {};
  $self->debug(sprintf "get_entries %s", Data::Dumper::Dumper(\%params));
  if (! $self->opts->snmpwalk) {
    my %newparams = ();
    $newparams{'-startindex'} = $params{'-startindex'}
        if defined $params{'-startindex'};
    $newparams{'-endindex'} = $params{'-endindex'}     
        if defined $params{'-endindex'};
    $newparams{'-columns'} = $params{'-columns'};
    $result = $GLPlugin::SNMP::session->get_entries(%newparams);
    if (! $result) {
      $newparams{'-maxrepetitions'} = 0;
      $result = $GLPlugin::SNMP::session->get_entries(%newparams);
      if (! $result) {
        $self->debug(sprintf "get_entries tries last fallback");
        delete $newparams{'-endindex'};
        delete $newparams{'-startindex'};
        delete $newparams{'-maxrepetitions'};
        $result = $GLPlugin::SNMP::session->get_entries(%newparams);
      }
    }
    foreach my $key (keys %{$result}) {
      if (substr($key, -1) eq " ") {
        my $value = $result->{$key};
        delete $result->{$key};
        $key =~ s/\s+$//g;
        $result->{$key} = $value;
        #
        # warum?
        #
        # %newparams ist:
        #  '-columns' => [
        #                  '1.3.6.1.2.1.2.2.1.8',
        #                  '1.3.6.1.2.1.2.2.1.13',
        #                  ...
        #                  '1.3.6.1.2.1.2.2.1.16'
        #                ],
        #  '-startindex' => '2', 
        #  '-endindex' => '2'
        #
        # und $result ist:
        #  ...
        #  '1.3.6.1.2.1.2.2.1.2.2' => 'Adaptive Security Appliance \'outside\' interface',
        #  '1.3.6.1.2.1.2.2.1.16.2 ' => 4281465004,
        #  '1.3.6.1.2.1.2.2.1.13.2' => 0,
        #  ...
        #
        # stinkstiefel!
        #
      }
      $self->add_rawdata($key, $result->{$key});
    }
  } else {
    my $preresult = $self->get_matching_oids(
        -columns => $params{'-columns'});
    foreach (keys %{$preresult}) {
      $result->{$_} = $preresult->{$_};
    }
    my @sortedkeys = map { $_->[0] }
        sort { $a->[1] cmp $b->[1] }
            map { [$_,
                    join '', map { sprintf("%30d",$_) } split( /\./, $_)
                  ] } keys %{$result};
    my @to_del = ();
    if ($params{'-startindex'}) {
      foreach my $resoid (@sortedkeys) {
        foreach my $oid (@{$params{'-columns'}}) {
          my $poid = $oid.'.';
          my $lpoid = length($poid);
          if (substr($resoid, 0, $lpoid) eq $poid) {
            my $oidpattern = $poid;
            $oidpattern =~ s/\./\\./g;
            if ($resoid =~ /^$oidpattern(.+)$/) {
              if ($1 lt $params{'-startindex'}) {
                push(@to_del, $oid.'.'.$1);
              }
            }
          }
        }
      }
    }
    if ($params{'-endindex'}) {
      foreach my $resoid (@sortedkeys) {
        foreach my $oid (@{$params{'-columns'}}) {
          my $poid = $oid.'.';
          my $lpoid = length($poid);
          if (substr($resoid, 0, $lpoid) eq $poid) {
            my $oidpattern = $poid;
            $oidpattern =~ s/\./\\./g;
            if ($resoid =~ /^$oidpattern(.+)$/) {
              if ($1 gt $params{'-endindex'}) {
                push(@to_del, $oid.'.'.$1);
              }
            }
          }
        }
      } 
    }
    foreach (@to_del) {
      delete $result->{$_};
    }
  }
  return $result;
}

# Level2
# helper function
sub get_matching_oids {
  my $self = shift;
  my %params = @_;
  my $result = {};
  $self->debug(sprintf "get_matching_oids %s", Data::Dumper::Dumper(\%params));
  foreach my $oid (@{$params{'-columns'}}) {
    my $oidpattern = $oid;
    $oidpattern =~ s/\./\\./g;
    map { $result->{$_} = $GLPlugin::SNMP::rawdata->{$_} }
        grep /^$oidpattern(?=\.|$)/, keys %{$GLPlugin::SNMP::rawdata};
  }
  $self->debug(sprintf "get_matching_oids returns %d from %d oids", 
      scalar(keys %{$result}), scalar(keys %{$GLPlugin::SNMP::rawdata}));
  return $result;
}

sub create_interface_cache_file {
  my $self = shift;
  my $extension = "";
  if ($self->opts->snmpwalk && ! $self->opts->hostname) {
    $self->opts->override_opt('hostname',
        'snmpwalk.file'.md5_hex($self->opts->snmpwalk))
  }
  if ($self->opts->community) { 
    $extension .= md5_hex($self->opts->community);
  }
  $extension =~ s/\//_/g;
  $extension =~ s/\(/_/g;
  $extension =~ s/\)/_/g;
  $extension =~ s/\*/_/g;
  $extension =~ s/\s/_/g;
  return sprintf "%s/%s_interface_cache_%s", $self->statefilesdir(),
      $self->opts->hostname, lc $extension;
}

sub no_such_model {
  my $self = shift;
  printf "Model %s is not implemented\n", $self->{productname};
  exit 3;
}

# get_cached_table_entries
#   get_table nur die table-basoid
#   mit liste von indices
#     get_entries -startindex x -endindex x konsekutive indices oder einzeln

sub get_table_entries {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $elements = shift;
  my $oids = {};
  my $entry;
  if (exists $GLPlugin::SNMP::mibs_and_oids->{$mib} &&
      exists $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}) {
    foreach my $key (keys %{$GLPlugin::SNMP::mibs_and_oids->{$mib}}) {
      if ($GLPlugin::SNMP::mibs_and_oids->{$mib}->{$key} =~
          /^$GLPlugin::SNMP::mibs_and_oids->{$mib}->{$table}/) {
        $oids->{$key} = $GLPlugin::SNMP::mibs_and_oids->{$mib}->{$key};
      }
    }
  }
  ($entry = $table) =~ s/Table/Entry/g;
  return $self->get_entries($oids, $entry);
}


sub xget_entries {
  my $self = shift;
  my $oids = shift;
  my $entry = shift;
  my $fallback = shift;
  my @params = ();
  my @indices = $self->get_indices($oids->{$entry});
  foreach (@indices) {
    my @idx = @{$_};
    my %params = ();
    my $maxdimension = scalar(@idx) - 1;
    foreach my $idxnr (1..scalar(@idx)) {
      $params{'index'.$idxnr} = $_->[$idxnr - 1];
    }
    foreach my $oid (keys %{$oids}) {
      next if $oid =~ /Table$/;
      next if $oid =~ /Entry$/;
      # there may be scalar oids ciscoEnvMonTemperatureStatusValue = curr. temp.
      next if ($oid =~ /Value$/ && ref ($oids->{$oid}) eq 'HASH');
      if (exists $oids->{$oid.'Value'}) {
        $params{$oid} = $self->get_object_value(
            $oids->{$oid}, $oids->{$oid.'Value'}, @idx);
      } else {
        $params{$oid} = $self->get_object($oids->{$oid}, @idx);
      }
    }     
    push(@params, \%params);
  }
  if (! $fallback && scalar(@params) == 0) {
    if ($GLPlugin::SNMP::session) {
      my $table = $entry;
      $table =~ s/(.*)\.\d+$/$1/;
      my $result = $self->get_table(
          -baseoid => $oids->{$table}
      );
      if ($result) {
        foreach my $key (keys %{$result}) {
          $self->add_rawdata($key, $result->{$key});
        }
        @params = $self->get_entries($oids, $entry, 1);
      }
      #printf "%s\n", Data::Dumper::Dumper($result);
    }
  }
  return @params;
}

sub get_indices {
  my $self = shift;
  my %params = @_;
  # -baseoid : entry
  # find all oids beginning with $entry
  # then skip one field for the sequence
  # then read the next numindices fields
  my $entrypat = $params{'-baseoid'};
  $entrypat =~ s/\./\\\./g;
  my @indices = map {
      /^$entrypat\.\d+\.(.*)/ && $1;
  } grep {
      /^$entrypat/
  } keys %{$GLPlugin::SNMP::rawdata};
  my %seen = ();
  my @o = map {[split /\./]} sort grep !$seen{$_}++, @indices;
  return @o;
}

sub get_size {
  my $self = shift;
  my $entry = shift;
  my $entrypat = $entry;
  $entrypat =~ s/\./\\\./g;
  my @entries = grep {
      /^$entrypat/
  } keys %{$GLPlugin::SNMP::rawdata};
  return scalar(@entries);
}

sub get_object {
  my $self = shift;
  my $object = shift;
  my @indices = @_;
  #my $oid = $object.'.'.join('.', @indices);
  my $oid = $object;
  $oid .= '.'.join('.', @indices) if (@indices);
  return $GLPlugin::SNMP::rawdata->{$oid};
}

sub get_object_value {
  my $self = shift;
  my $object = shift;
  my $values = shift;
  my @indices = @_;
  my $key = $self->get_object($object, @indices);
  if (defined $key) {
    return $values->{$key};
  } else {
    return undef;
  }
}

#SNMP::Utils::counter([$idxs1, $idxs2], $idx1, $idx2),
# this flattens a n-dimensional array and returns the absolute position
# of the element at position idx1,idx2,...,idxn
# element 1,2 in table 0,0 0,1 0,2 1,0 1,1 1,2 2,0 2,1 2,2 is at pos 6
sub get_number {
  my $self = shift;
  my $indexlists = shift; #, zeiger auf array aus [1, 2]
  my @element = @_;
  my $dimensions = scalar(@{$indexlists->[0]});
  my @sorted = ();
  my $number = 0;
  if ($dimensions == 1) {
    @sorted =
        sort { $a->[0] <=> $b->[0] } @{$indexlists};
  } elsif ($dimensions == 2) {
    @sorted =
        sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @{$indexlists};
  } elsif ($dimensions == 3) {
    @sorted =
        sort { $a->[0] <=> $b->[0] ||
               $a->[1] <=> $b->[1] ||
               $a->[2] <=> $b->[2] } @{$indexlists};
  }
  foreach (@sorted) {
    if ($dimensions == 1) {
      if ($_->[0] == $element[0]) {
        last;
      }
    } elsif ($dimensions == 2) {
      if ($_->[0] == $element[0] && $_->[1] == $element[1]) {
        last;
      }
    } elsif ($dimensions == 3) {
      if ($_->[0] == $element[0] &&
          $_->[1] == $element[1] &&
          $_->[2] == $element[2]) {
        last;
      }
    }
    $number++;
  }
  return ++$number;
}

sub create_entry_cache_file {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  return lc sprintf "%s_%s_%s_%s_cache",
      $self->create_interface_cache_file(),
      $mib, $table, join('#', @{$key_attr});
}

sub update_entry_cache {
  my $self = shift;
  my $force = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  if (ref($key_attr) ne "ARRAY") {
    $key_attr = [$key_attr];
  }
  my $cache = sprintf "%s_%s_%s_cache", 
      $mib, $table, join('#', @{$key_attr});
  my $statefile = $self->create_entry_cache_file($mib, $table, $key_attr);
  my $update = time - 3600;
  #my $update = time - 1;
  if ($force || ! -f $statefile || ((stat $statefile)[9]) < ($update)) {
    $self->debug(sprintf 'force update of %s %s %s %s cache',
        $self->opts->hostname, $self->opts->mode, $mib, $table);
    $self->{$cache} = {};
    foreach my $entry ($self->get_snmp_table_objects($mib, $table)) {
      my $key = join('#', map { $entry->{$_} } @{$key_attr});
      my $hash = $key . '-//-' . join('.', @{$entry->{indices}});
      $self->{$cache}->{$hash} = $entry->{indices};
    }
    $self->save_cache($mib, $table, $key_attr);
  }
  $self->load_cache($mib, $table, $key_attr);
}

#  $self->update_entry_cache(0, $mib, $table, $key_attr);
#  my @indices = $self->get_cache_indices();
sub get_cache_indices {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  if (ref($key_attr) ne "ARRAY") {
    $key_attr = [$key_attr];
  }
  my $cache = sprintf "%s_%s_%s_cache", 
      $mib, $table, join('#', @{$key_attr});
  my @indices = ();
  foreach my $key (keys %{$self->{$cache}}) {
    my ($descr, $index) = split('-//-', $key, 2);
    if ($self->opts->name) {
      if ($self->opts->regexp) {
        my $pattern = $self->opts->name;
        if ($descr =~ /$pattern/i) {
          push(@indices, $self->{$cache}->{$key});
        }
      } else {
        if ($self->opts->name =~ /^\d+$/) {
          if ($index == 1 * $self->opts->name) {
            push(@indices, [1 * $self->opts->name]);
          }
        } else {
          if (lc $descr eq lc $self->opts->name) {
            push(@indices, $self->{$cache}->{$key});
          }
        }
      }
    } else {
      push(@indices, $self->{$cache}->{$key});
    }
  }
  return @indices;
  return map { join('.', ref($_) eq "ARRAY" ? @{$_} : $_) } @indices;
}

sub save_cache {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  if (ref($key_attr) ne "ARRAY") {
    $key_attr = [$key_attr];
  }
  my $cache = sprintf "%s_%s_%s_cache", 
      $mib, $table, join('#', @{$key_attr});
  $self->create_statefilesdir();
  my $statefile = $self->create_entry_cache_file($mib, $table, $key_attr);
  open(STATE, ">".$statefile.".".$$);
  printf STATE Data::Dumper::Dumper($self->{$cache});
  close STATE;
  rename $statefile.".".$$, $statefile;
  $self->debug(sprintf "saved %s to %s",
      Data::Dumper::Dumper($self->{$cache}), $statefile);
}

sub load_cache {
  my $self = shift;
  my $mib = shift;
  my $table = shift;
  my $key_attr = shift;
  if (ref($key_attr) ne "ARRAY") {
    $key_attr = [$key_attr];
  }
  my $cache = sprintf "%s_%s_%s_cache", 
      $mib, $table, join('#', @{$key_attr});
  my $statefile = $self->create_entry_cache_file($mib, $table, $key_attr);
  $self->{$cache} = {};
  if ( -f $statefile) {
    our $VAR1;
    our $VAR2;
    eval {
      require $statefile;
    };
    if($@) {
      printf "rumms\n";
    }
    # keinesfalls mehr require verwenden!!!!!!
    # beim require enthaelt VAR1 andere werte als beim slurp
    # und zwar diejenigen, die beim letzten save_cache geschrieben wurden.
    my $content = do { local (@ARGV, $/) = $statefile; my $x = <>; close ARGV; $x };
    $VAR1 = eval "$content";
    $self->debug(sprintf "load %s", Data::Dumper::Dumper($VAR1));
    $self->{$cache} = $VAR1;
  }
}

sub no_such_mode {
  my $self = shift;
  if (ref($self) eq "Classes::Generic") {
    $self->init();
  } elsif (ref($self) eq "Classes::Device") {
    $self->add_message(UNKNOWN, 'the device did not implement the mibs this plugin is asking for');
    $self->add_message(UNKNOWN,
        sprintf('unknown device%s', $self->{productname} eq 'unknown' ?
            '' : '('.$self->{productname}.')'));
  } elsif (ref($self) eq "GLPlugin::SNMP") {
    # uptime, offline
    $self->init();
  } else {
    eval {
      bless $self, "Classes::Generic";
      $self->init();
    };
    if ($@) {
      bless $self, "GLPlugin::SNMP";
      $self->init();
    }
  }
  if (ref($self) eq "GLPlugin::SNMP") {
    printf "Mode %s is not implemented for this type of device\n",
        $self->opts->mode;
    exit 3;
  }
}

sub internal_name {
  my $self = shift;
  my $class = ref($self);
  $class =~ s/^.*:://;
  if (exists $self->{flat_indices}) {
    return sprintf "%s_%s", uc $class, $self->{flat_indices};
  } else {
    return sprintf "%s", uc $class;
  }
}


package GLPlugin::SNMP::Item;
our @ISA = qw(GLPlugin::Item GLPlugin::SNMP);
use strict;


package GLPlugin::SNMP::TableItem;
our @ISA = qw(GLPlugin::TableItem GLPlugin::SNMP);

sub ensure_index {
  my $self = shift;
  my $key = shift;
  $self->{$key} ||= $self->{flat_indices};
}

