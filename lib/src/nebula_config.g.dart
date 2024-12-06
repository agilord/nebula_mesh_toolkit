// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'nebula_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NebulaConfig _$NebulaConfigFromJson(Map<String, dynamic> json) => NebulaConfig(
      pki: PkiConfig.fromJson(json['pki'] as Map<String, dynamic>),
      staticHostMap: (json['static_host_map'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lighthouse:
          LighthouseConfig.fromJson(json['lighthouse'] as Map<String, dynamic>),
      listen: json['listen'] == null
          ? null
          : ListenConfig.fromJson(json['listen'] as Map<String, dynamic>),
      punchy: json['punchy'] == null
          ? null
          : PunchyConfig.fromJson(json['punchy'] as Map<String, dynamic>),
      cipher: json['cipher'] as String?,
      relay: json['relay'] == null
          ? null
          : RelayConfig.fromJson(json['relay'] as Map<String, dynamic>),
      tun: json['tun'] == null
          ? null
          : TunConfig.fromJson(json['tun'] as Map<String, dynamic>),
      firewall: json['firewall'] == null
          ? null
          : FirewallConfig.fromJson(json['firewall'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NebulaConfigToJson(NebulaConfig instance) =>
    <String, dynamic>{
      'pki': instance.pki.toJson(),
      if (instance.staticHostMap case final value?) 'static_host_map': value,
      'lighthouse': instance.lighthouse.toJson(),
      if (instance.listen?.toJson() case final value?) 'listen': value,
      if (instance.punchy?.toJson() case final value?) 'punchy': value,
      if (instance.cipher case final value?) 'cipher': value,
      if (instance.relay?.toJson() case final value?) 'relay': value,
      if (instance.tun?.toJson() case final value?) 'tun': value,
      if (instance.firewall?.toJson() case final value?) 'firewall': value,
    };

PkiConfig _$PkiConfigFromJson(Map<String, dynamic> json) => PkiConfig(
      ca: json['ca'] as String,
      cert: json['cert'] as String,
      key: json['key'] as String,
      blocklist: (json['blocklist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      disconnectInvalid: json['disconnect_invalid'] as bool?,
    );

Map<String, dynamic> _$PkiConfigToJson(PkiConfig instance) => <String, dynamic>{
      'ca': instance.ca,
      'cert': instance.cert,
      'key': instance.key,
      if (instance.blocklist case final value?) 'blocklist': value,
      if (instance.disconnectInvalid case final value?)
        'disconnect_invalid': value,
    };

LighthouseConfig _$LighthouseConfigFromJson(Map<String, dynamic> json) =>
    LighthouseConfig(
      amLighthouse: json['am_lighthouse'] as bool?,
      hosts:
          (json['hosts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LighthouseConfigToJson(LighthouseConfig instance) =>
    <String, dynamic>{
      if (instance.amLighthouse case final value?) 'am_lighthouse': value,
      if (instance.hosts case final value?) 'hosts': value,
    };

ListenConfig _$ListenConfigFromJson(Map<String, dynamic> json) => ListenConfig(
      host: json['host'] as String?,
      port: (json['port'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ListenConfigToJson(ListenConfig instance) =>
    <String, dynamic>{
      if (instance.host case final value?) 'host': value,
      if (instance.port case final value?) 'port': value,
    };

PunchyConfig _$PunchyConfigFromJson(Map<String, dynamic> json) => PunchyConfig(
      punch: json['punch'] as bool?,
    );

Map<String, dynamic> _$PunchyConfigToJson(PunchyConfig instance) =>
    <String, dynamic>{
      if (instance.punch case final value?) 'punch': value,
    };

RelayConfig _$RelayConfigFromJson(Map<String, dynamic> json) => RelayConfig(
      relays:
          (json['relays'] as List<dynamic>?)?.map((e) => e as String).toList(),
      amRelay: json['am_relay'] as bool?,
      useRelays: json['use_relays'] as bool?,
    );

Map<String, dynamic> _$RelayConfigToJson(RelayConfig instance) =>
    <String, dynamic>{
      if (instance.relays case final value?) 'relays': value,
      if (instance.amRelay case final value?) 'am_relay': value,
      if (instance.useRelays case final value?) 'use_relays': value,
    };

TunConfig _$TunConfigFromJson(Map<String, dynamic> json) => TunConfig(
      dev: json['dev'] as String?,
    );

Map<String, dynamic> _$TunConfigToJson(TunConfig instance) => <String, dynamic>{
      if (instance.dev case final value?) 'dev': value,
    };

FirewallConfig _$FirewallConfigFromJson(Map<String, dynamic> json) =>
    FirewallConfig(
      outbound: (json['outbound'] as List<dynamic>?)
          ?.map((e) => FirewallRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      inbound: (json['inbound'] as List<dynamic>?)
          ?.map((e) => FirewallRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FirewallConfigToJson(FirewallConfig instance) =>
    <String, dynamic>{
      if (instance.outbound?.map((e) => e.toJson()).toList() case final value?)
        'outbound': value,
      if (instance.inbound?.map((e) => e.toJson()).toList() case final value?)
        'inbound': value,
    };

FirewallRule _$FirewallRuleFromJson(Map<String, dynamic> json) => FirewallRule(
      port: json['port'] as String? ?? 'any',
      proto: json['proto'] as String? ?? 'any',
      host: json['host'] as String?,
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FirewallRuleToJson(FirewallRule instance) =>
    <String, dynamic>{
      'port': instance.port,
      'proto': instance.proto,
      if (instance.host case final value?) 'host': value,
      if (instance.groups case final value?) 'groups': value,
    };
