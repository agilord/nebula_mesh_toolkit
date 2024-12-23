// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'network_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Network _$NetworkFromJson(Map<String, dynamic> json) => Network(
      domain: json['domain'] as String,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cipher: json['cipher'] as String?,
      os: json['os'] as String?,
      expiry: json['expiry'] as String?,
      keep: json['keep'] as String?,
      templates: (json['templates'] as List<dynamic>)
          .map((e) => Template.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NetworkToJson(Network instance) => <String, dynamic>{
      'domain': instance.domain,
      if (instance.addresses case final value?) 'addresses': value,
      if (instance.cipher case final value?) 'cipher': value,
      if (instance.os case final value?) 'os': value,
      if (instance.expiry case final value?) 'expiry': value,
      if (instance.keep case final value?) 'keep': value,
      'templates': instance.templates.map((e) => e.toJson()).toList(),
    };

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
      os: json['os'] as String?,
      staticHostMap: (json['static_host_map'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      listen: json['listen'] == null
          ? null
          : Listen.fromJson(json['listen'] as Map<String, dynamic>),
      tun: json['tun'] == null
          ? null
          : Tun.fromJson(json['tun'] as Map<String, dynamic>),
      punchy: json['punchy'] == null
          ? null
          : Punchy.fromJson(json['punchy'] as Map<String, dynamic>),
      relay: json['relay'] == null
          ? null
          : Relay.fromJson(json['relay'] as Map<String, dynamic>),
      firewallPresets: (json['firewall_presets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firewall: json['firewall'] == null
          ? null
          : Firewall.fromJson(json['firewall'] as Map<String, dynamic>),
      duration: json['duration'] as String?,
      hosts: (json['hosts'] as List<dynamic>)
          .map((e) => Host.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
      if (instance.groups case final value?) 'groups': value,
      if (instance.os case final value?) 'os': value,
      if (instance.staticHostMap case final value?) 'static_host_map': value,
      if (instance.listen?.toJson() case final value?) 'listen': value,
      if (instance.tun?.toJson() case final value?) 'tun': value,
      if (instance.punchy?.toJson() case final value?) 'punchy': value,
      if (instance.relay?.toJson() case final value?) 'relay': value,
      if (instance.firewallPresets case final value?) 'firewall_presets': value,
      if (instance.firewall?.toJson() case final value?) 'firewall': value,
      if (instance.duration case final value?) 'duration': value,
      'hosts': instance.hosts.map((e) => e.toJson()).toList(),
    };

Host _$HostFromJson(Map<String, dynamic> json) => Host(
      name: json['name'] as String,
      address: json['address'] as String?,
      os: json['os'] as String?,
      listen: json['listen'] == null
          ? null
          : Listen.fromJson(json['listen'] as Map<String, dynamic>),
      tun: json['tun'] == null
          ? null
          : Tun.fromJson(json['tun'] as Map<String, dynamic>),
      duration: json['duration'] as String?,
      publicAddresses: (json['publicAddresses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HostToJson(Host instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.address case final value?) 'address': value,
      if (instance.os case final value?) 'os': value,
      if (instance.listen?.toJson() case final value?) 'listen': value,
      if (instance.tun?.toJson() case final value?) 'tun': value,
      if (instance.duration case final value?) 'duration': value,
      if (instance.publicAddresses case final value?) 'publicAddresses': value,
    };
