import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:nebula_mesh_toolkit/nebula_mesh_toolkit.dart';
import 'package:yaml/yaml.dart';

part 'network_template.g.dart';

@JsonSerializable()
class Network {
  /// The name of the CA.
  final String? name;

  /// The number part of the device id (as the name may be fixed format on
  /// certain platforms).
  final int id;

  final String? cipher;

  final String? os;

  final List<Template> templates;

  Network({
    this.name,
    required this.id,
    this.cipher,
    this.os,
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

  final Punchy? punchy;

  final Relay? relay;

  @JsonKey(name: 'firewall_presets')
  final List<String>? firewallPresets;

  final Firewall? firewall;

  final List<Host> hosts;

  Template({
    this.groups,
    this.os,
    this.staticHostMap,
    this.listen,
    this.punchy,
    this.relay,
    this.firewallPresets,
    this.firewall,
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
  final List<String>? publicAddresses;

  Host({
    required this.name,
    required this.address,
    this.os,
    this.listen,
    this.publicAddresses,
  });

  factory Host.fromJson(Map<String, dynamic> map) => _$HostFromJson(map);

  Map<String, dynamic> toJson() => _$HostToJson(this);
}
