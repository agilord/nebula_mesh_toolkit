import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:nebula_mesh_toolkit/nebula_mesh_toolkit.dart';
import 'package:yaml/yaml.dart';

part 'network_template.g.dart';

@JsonSerializable()
class Network {
  /// The domain name of the network.
  ///
  /// Will be used as CA name and also to fully qualify host names.
  ///
  /// Note: for internal nebula network, use the `.internal` TLD.
  final String domain;

  final String? cipher;

  final String? os;

  /// The CA expiry duration in the format of `<n>y<n>d<n>h<n>m<n>s`.
  final String? expiry;

  /// The current CA is kept for at least this period, in the format of `<n>y<n>d<n>h<n>m<n>s`.
  final String? keep;

  final List<Template> templates;

  Network({
    required this.domain,
    this.cipher,
    this.os,
    this.expiry,
    this.keep,
    required this.templates,
  });

  factory Network.fromJson(Map<String, dynamic> map) => _$NetworkFromJson(map);

  factory Network.fromYaml(String text) {
    final map = json.decode(json.encode(loadYamlNode(text)));
    return Network.fromJson(map as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => _$NetworkToJson(this);
}

@JsonSerializable()
class Template {
  final List<String>? groups;

  final String? os;

  @JsonKey(name: 'static_host_map')
  final Map<String, List<String>>? staticHostMap;

  final Listen? listen;

  final Tun? tun;

  final Punchy? punchy;

  final Relay? relay;

  @JsonKey(name: 'firewall_presets')
  final List<String>? firewallPresets;

  final Firewall? firewall;

  final String? duration;

  final List<Host> hosts;

  Template({
    this.groups,
    this.os,
    this.staticHostMap,
    this.listen,
    this.tun,
    this.punchy,
    this.relay,
    this.firewallPresets,
    this.firewall,
    this.duration,
    required this.hosts,
  });

  factory Template.fromJson(Map<String, dynamic> map) =>
      _$TemplateFromJson(map);

  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}

@JsonSerializable()
class Host {
  final String name;
  final String address;
  final String? os;
  final Listen? listen;
  final Tun? tun;
  final String? duration;
  final List<String>? publicAddresses;

  Host({
    required this.name,
    required this.address,
    this.os,
    this.listen,
    this.tun,
    this.duration,
    this.publicAddresses,
  });

  factory Host.fromJson(Map<String, dynamic> map) => _$HostFromJson(map);

  Map<String, dynamic> toJson() => _$HostToJson(this);
}
