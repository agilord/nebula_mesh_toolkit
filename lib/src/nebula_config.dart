import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:yaml_edit/yaml_edit.dart';

part 'nebula_config.g.dart';

/// Configuration from https://nebula.defined.net/docs/config/
@JsonSerializable()
class Nebula {
  /// Defines the path of each file required for a Nebula host: CA certificate, host certificate, and host key.
  /// Each of these files can also be stored inline as YAML multiline strings.
  ///
  /// https://nebula.defined.net/docs/config/pki/
  final Pki pki;

  /// The static host map defines a set of hosts with fixed IP addresses on the
  /// internet (or any network). A host can have multiple fixed IP addresses
  /// defined here, and nebula will try each when establishing a tunnel.
  /// The syntax is:
  ///
  ///     "<nebula ip>": ["<routable ip/dns name>:<routable port>"]
  ///
  /// https://nebula.defined.net/docs/config/static-host-map/
  @JsonKey(name: 'static_host_map')
  final Map<String, List<String>>? staticHostMap;

  /// https://nebula.defined.net/docs/config/lighthouse/
  final Lighthouse lighthouse;

  /// `listen` sets the UDP port Nebula will use for sending/receiving traffic and for handshakes.
  ///
  /// https://nebula.defined.net/docs/config/listen/
  final Listen? listen;

  /// `punchy` configures the sending of inbound/outbound packets at a regular
  /// interval to avoid expiration of firewall NAT mappings.
  ///
  /// https://nebula.defined.net/docs/config/punchy/
  final Punchy? punchy;

  /// DANGER: This value must be identical on ALL nodes and lighthouses.
  ///         Nebula does not support the use of different ciphers simultaneously!
  /// `cipher` allows you to choose between the available ciphers for your network.
  /// You may choose `chachapoly` to use the `ChaCha20-Poly1305` cipher or `aes` for `AES256-GCM`.
  ///
  /// Because most devices have hardware support for the AES instruction set (e.g. AES-NI), this is the recommended option.
  /// https://nebula.defined.net/docs/config/cipher/
  final String? cipher;

  /// Relay hosts forward traffic between two peers. This can be useful if two
  /// nodes struggle to communicate directly with each other (e.g. some NATs
  /// can make it difficult to establish direct connections between two nodes.)
  ///
  /// https://nebula.defined.net/docs/config/relay/
  final Relay? relay;

  /// https://nebula.defined.net/docs/config/tun/
  final Tun? tun;

  /// The default state of the Nebula interface host firewall is deny all for all
  /// inbound and outbound traffic. Firewall rules can be added to allow traffic
  /// for specified ports and protocols, but it is not possible to explicitly
  /// define a deny rule.
  ///
  /// https://nebula.defined.net/docs/config/firewall/
  final Firewall? firewall;

  Nebula({
    required this.pki,
    this.staticHostMap,
    required this.lighthouse,
    this.listen,
    this.punchy,
    this.cipher,
    this.relay,
    this.tun,
    this.firewall,
  });

  factory Nebula.fromJson(Map<String, dynamic> map) => _$NebulaFromJson(map);

  Map<String, dynamic> toJson() => _$NebulaToJson(this);

  String toYamlString() {
    final editor = YamlEditor('')..update([], toJson());
    return editor.toString();
  }
}

/// Defines the path of each file required for a Nebula host: CA certificate, host certificate, and host key.
/// Each of these files can also be stored inline as YAML multiline strings.
///
/// https://nebula.defined.net/docs/config/pki/
@JsonSerializable()
class Pki {
  /// The ca is a collection of one or more certificate authorities this host should trust.
  /// In the above example, /etc/nebula/ca.crt contains PEM-encoded data for each CA we should
  /// trust, concatenated into a single file. The following example shows a CA cert inlined
  /// as a YAML multiline string.
  ///
  /// https://nebula.defined.net/docs/config/pki/#pkica
  final String ca;

  /// NOTE: A new certificate will only take effect after a reload if the IP address has not
  /// changed, but all other properties of the certificate can be changed.
  ///
  /// The cert is a certificate unique to every host on a Nebula network. The certificate
  /// identifies a host’s IP address, name, and group membership within a Nebula network.
  /// The certificate is signed by a certificate authority when created, which informs
  /// other hosts on whether to trust a particular host certificate.
  ///
  /// https://nebula.defined.net/docs/config/pki/#pkicert
  final String cert;

  /// The key is a private key unique to every host on a Nebula network.
  /// It is used in conjunction with the host certificate to prove a host’s
  /// identity to other members of the Nebula network. The private key should
  /// never be shared with other hosts.
  ///
  /// https://nebula.defined.net/docs/config/pki/#pkikey
  final String key;

  /// NOTE: The blocklist is not distributed via Lighthouses. To ensure access to your entire network is blocked
  /// you must distribute the full blocklist to every host in your network. This is typically done via tooling
  /// such as Ansible, Chef, or Puppet.
  ///
  /// The blocklist contains a list of individual hosts' certificate fingerprints which should be blocked even
  /// if the certificate is otherwise valid (signed by a trusted CA and unexpired.) This should be used if a
  /// host's credentials are stolen or compromised.
  ///
  /// https://nebula.defined.net/docs/config/pki/#pkiblocklist
  final List<String>? blocklist;

  /// `disconnect_invalid` is a toggle to force a client to be disconnected if the certificate is expired or invalid.
  ///
  /// https://nebula.defined.net/docs/config/pki/#pkidisconnect_invalid
  @JsonKey(name: 'disconnect_invalid')
  final bool? disconnectInvalid;

  Pki({
    required this.ca,
    required this.cert,
    required this.key,
    this.blocklist,
    this.disconnectInvalid,
  });

  factory Pki.fromJson(Map<String, dynamic> map) => _$PkiFromJson(map);

  Map<String, dynamic> toJson() => _$PkiToJson(this);
}

/// https://nebula.defined.net/docs/config/lighthouse/
@JsonSerializable()
class Lighthouse {
  /// `am_lighthouse` is used to enable lighthouse functionality for a node.
  /// This should ONLY be true on nodes you have configured to be lighthouses in your network
  ///
  /// https://nebula.defined.net/docs/config/lighthouse/#lighthouseam_lighthouse
  @JsonKey(name: 'am_lighthouse')
  final bool? amLighthouse;

  /// `hosts` is a list of lighthouse hosts this node should report to and query
  /// from. The lighthouses listed here should be referenced by their nebula IP,
  /// not by the IPs of their physical network interfaces.
  ///
  /// https://nebula.defined.net/docs/config/lighthouse/#lighthousehosts
  final List<String>? hosts;

  Lighthouse({
    this.amLighthouse,
    this.hosts,
  });

  factory Lighthouse.fromJson(Map<String, dynamic> map) =>
      _$LighthouseFromJson(map);

  Map<String, dynamic> toJson() => _$LighthouseToJson(this);
}

/// `listen` sets the UDP port Nebula will use for sending/receiving traffic and for handshakes.
///
/// https://nebula.defined.net/docs/config/listen/
@JsonSerializable()
class Listen {
  /// `host` is the ip of the interface to use when binding the listener.
  /// The default is `0.0.0.0` for all IPv4 interfaces.
  /// To enable IPv6, use `[::]` instead. host may also contain a hostname.
  ///
  /// https://nebula.defined.net/docs/config/listen/#listenhost
  final String? host;

  /// `port` is the UDP port nebula should use on a host. For a lighthouse node,
  /// the port should be defined, conventionally to `4242`, however using port `0`
  /// or leaving port unset will dynamically assign a port and is recommended for
  /// roaming nodes. Using `0` on lighthouses and relay hosts will likely lead
  /// to connectivity issues.
  ///
  /// https://nebula.defined.net/docs/config/listen/#listenport
  final int? port;

  // TODO: batch, read_buffer, write_buffer

  Listen({
    this.host,
    this.port,
  });

  factory Listen.fromJson(Map<String, dynamic> map) => _$ListenFromJson(map);

  Map<String, dynamic> toJson() => _$ListenToJson(this);
}

/// `punchy` configures the sending of inbound/outbound packets at a regular
/// interval to avoid expiration of firewall NAT mappings.
///
/// https://nebula.defined.net/docs/config/punchy/
@JsonSerializable()
class Punchy {
  /// When enabled, Nebula will periodically send "empty" packets to the
  /// underlay IP addresses of hosts it has established tunnels to in order
  /// to maintain the "hole" punched in the NAT's firewall.
  ///
  /// https://nebula.defined.net/docs/config/punchy/#punchypunch
  final bool? punch;

  Punchy({
    this.punch,
  });

  factory Punchy.fromJson(Map<String, dynamic> map) => _$PunchyFromJson(map);

  Map<String, dynamic> toJson() => _$PunchyToJson(this);
}

/// Relay hosts forward traffic between two peers. This can be useful if two
/// nodes struggle to communicate directly with each other (e.g. some NATs
/// can make it difficult to establish direct connections between two nodes.)
///
/// https://nebula.defined.net/docs/config/relay/
@JsonSerializable()
class Relay {
  /// `relays` is a list of Nebula IPs that peers can use to relay packets to
  /// this host. IPs in this list must have am_relay set to true in their
  /// configs, otherwise they will reject relay requests.
  ///
  /// https://nebula.defined.net/docs/config/relay/#relayrelays
  final List<String>? relays;

  /// Set `am_relay` to true to enable forwarding packets for other hosts.
  /// This host will only forward traffic for hosts which specify it as a
  /// relay in their own config file. The default is false.
  ///
  /// https://nebula.defined.net/docs/config/relay/#relayam_relay
  @JsonKey(name: 'am_relay')
  final bool? amRelay;

  /// Set use_relays to false to prevent this instance from attempting to
  /// establish connections through relays. The default is true.
  ///
  /// https://nebula.defined.net/docs/config/relay/#relayuse_relays
  @JsonKey(name: 'use_relays')
  final bool? useRelays;

  Relay({
    this.relays,
    this.amRelay,
    this.useRelays,
  });

  Relay replace({List<String>? relays}) {
    return Relay(
      relays: relays ?? this.relays,
      amRelay: amRelay,
      useRelays: useRelays,
    );
  }

  factory Relay.fromJson(Map<String, dynamic> map) => _$RelayFromJson(map);

  Map<String, dynamic> toJson() => _$RelayToJson(this);
}

/// https://nebula.defined.net/docs/config/tun/
@JsonSerializable()
class Tun {
  /// `dev` sets the interface name for your nebula interface.
  /// If not set, a default will be chosen by the OS.
  /// - For macOS: Not required. If set, must be in the form `utun[0-9]+`.
  /// - For FreeBSD: Required to be set, must be in the form `tun[0-9]+`.
  ///
  /// https://nebula.defined.net/docs/config/tun/#tundev
  final String? dev;

  Tun({
    this.dev,
  });

  factory Tun.fromJson(Map<String, dynamic> map) => _$TunFromJson(map);

  Map<String, dynamic> toJson() => _$TunToJson(this);
}

/// The default state of the Nebula interface host firewall is deny all for all
/// inbound and outbound traffic. Firewall rules can be added to allow traffic
/// for specified ports and protocols, but it is not possible to explicitly
/// define a deny rule.
///
/// https://nebula.defined.net/docs/config/firewall/
@JsonSerializable()
class Firewall {
  /// https://nebula.defined.net/docs/config/firewall/#firewalloutbound
  final List<FirewallRule>? outbound;

  /// https://nebula.defined.net/docs/config/firewall/#firewallinbound
  final List<FirewallRule>? inbound;

  Firewall({
    this.outbound,
    this.inbound,
  });

  factory Firewall.fromJson(Map<String, dynamic> map) =>
      _$FirewallFromJson(map);

  Map<String, dynamic> toJson() => _$FirewallToJson(this);
}

/// https://nebula.defined.net/docs/config/firewall/
@JsonSerializable()
class FirewallRule {
  final String port;
  final String proto;
  final String? host;
  final List<String>? groups;

  FirewallRule({
    this.port = 'any',
    this.proto = 'any',
    this.host,
    this.groups,
  });

  factory FirewallRule.fromJson(Map<String, dynamic> map) =>
      _$FirewallRuleFromJson(map);

  Map<String, dynamic> toJson() => _$FirewallRuleToJson(this);

  late final _asJsonString = json.encode(toJson());

  @override
  int get hashCode => _asJsonString.hashCode;

  @override
  bool operator ==(Object other) {
    return (other is FirewallRule) && _asJsonString == other._asJsonString;
  }
}
