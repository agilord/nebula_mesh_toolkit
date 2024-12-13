// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'nebula_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nebula _$NebulaFromJson(Map<String, dynamic> json) => Nebula(
      pki: Pki.fromJson(json['pki'] as Map<String, dynamic>),
      staticHostMap: (json['static_host_map'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lighthouse:
          Lighthouse.fromJson(json['lighthouse'] as Map<String, dynamic>),
      listen: json['listen'] == null
          ? null
          : Listen.fromJson(json['listen'] as Map<String, dynamic>),
      punchy: json['punchy'] == null
          ? null
          : Punchy.fromJson(json['punchy'] as Map<String, dynamic>),
      cipher: json['cipher'] as String?,
      relay: json['relay'] == null
          ? null
          : Relay.fromJson(json['relay'] as Map<String, dynamic>),
      tun: json['tun'] == null
          ? null
          : Tun.fromJson(json['tun'] as Map<String, dynamic>),
      firewall: json['firewall'] == null
          ? null
          : Firewall.fromJson(json['firewall'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NebulaToJson(Nebula instance) => <String, dynamic>{
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

Pki _$PkiFromJson(Map<String, dynamic> json) => Pki(
      ca: json['ca'] as String,
      cert: json['cert'] as String,
      key: json['key'] as String,
      blocklist: (json['blocklist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      disconnectInvalid: json['disconnect_invalid'] as bool?,
    );

Map<String, dynamic> _$PkiToJson(Pki instance) => <String, dynamic>{
      'ca': instance.ca,
      'cert': instance.cert,
      'key': instance.key,
      if (instance.blocklist case final value?) 'blocklist': value,
      if (instance.disconnectInvalid case final value?)
        'disconnect_invalid': value,
    };

Lighthouse _$LighthouseFromJson(Map<String, dynamic> json) => Lighthouse(
      amLighthouse: json['am_lighthouse'] as bool?,
      hosts:
          (json['hosts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LighthouseToJson(Lighthouse instance) =>
    <String, dynamic>{
      if (instance.amLighthouse case final value?) 'am_lighthouse': value,
      if (instance.hosts case final value?) 'hosts': value,
    };

Listen _$ListenFromJson(Map<String, dynamic> json) => Listen(
      host: json['host'] as String?,
      port: (json['port'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ListenToJson(Listen instance) => <String, dynamic>{
      if (instance.host case final value?) 'host': value,
      if (instance.port case final value?) 'port': value,
    };

Punchy _$PunchyFromJson(Map<String, dynamic> json) => Punchy(
      punch: json['punch'] as bool?,
    );

Map<String, dynamic> _$PunchyToJson(Punchy instance) => <String, dynamic>{
      if (instance.punch case final value?) 'punch': value,
    };

Relay _$RelayFromJson(Map<String, dynamic> json) => Relay(
      relays:
          (json['relays'] as List<dynamic>?)?.map((e) => e as String).toList(),
      amRelay: json['am_relay'] as bool?,
      useRelays: json['use_relays'] as bool?,
    );

Map<String, dynamic> _$RelayToJson(Relay instance) => <String, dynamic>{
      if (instance.relays case final value?) 'relays': value,
      if (instance.amRelay case final value?) 'am_relay': value,
      if (instance.useRelays case final value?) 'use_relays': value,
    };

Tun _$TunFromJson(Map<String, dynamic> json) => Tun(
      dev: json['dev'] as String?,
    );

Map<String, dynamic> _$TunToJson(Tun instance) => <String, dynamic>{
      if (instance.dev case final value?) 'dev': value,
    };

Firewall _$FirewallFromJson(Map<String, dynamic> json) => Firewall(
      outbound: (json['outbound'] as List<dynamic>?)
          ?.map((e) => FirewallRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      inbound: (json['inbound'] as List<dynamic>?)
          ?.map((e) => FirewallRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FirewallToJson(Firewall instance) => <String, dynamic>{
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

Certificate _$CertificateFromJson(Map<String, dynamic> json) => Certificate(
      details: json['details'] == null
          ? null
          : CertificateDetails.fromJson(
              json['details'] as Map<String, dynamic>),
      fingerprint: json['fingerprint'] as String?,
      signature: json['signature'] as String?,
    );

Map<String, dynamic> _$CertificateToJson(Certificate instance) =>
    <String, dynamic>{
      if (instance.details?.toJson() case final value?) 'details': value,
      if (instance.fingerprint case final value?) 'fingerprint': value,
      if (instance.signature case final value?) 'signature': value,
    };

CertificateDetails _$CertificateDetailsFromJson(Map<String, dynamic> json) =>
    CertificateDetails(
      curve: json['curve'] as String?,
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ips: (json['ips'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isCa: json['isCa'] as bool?,
      issuer: json['issuer'] as String?,
      name: json['name'] as String?,
      notAfter: json['notAfter'] == null
          ? null
          : DateTime.parse(json['notAfter'] as String),
      notBefore: json['notBefore'] == null
          ? null
          : DateTime.parse(json['notBefore'] as String),
      publicKey: json['publicKey'] as String?,
      subnets:
          (json['subnets'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CertificateDetailsToJson(CertificateDetails instance) =>
    <String, dynamic>{
      if (instance.curve case final value?) 'curve': value,
      if (instance.groups case final value?) 'groups': value,
      if (instance.ips case final value?) 'ips': value,
      if (instance.isCa case final value?) 'isCa': value,
      if (instance.issuer case final value?) 'issuer': value,
      if (instance.name case final value?) 'name': value,
      if (instance.notAfter?.toIso8601String() case final value?)
        'notAfter': value,
      if (instance.notBefore?.toIso8601String() case final value?)
        'notBefore': value,
      if (instance.subnets case final value?) 'subnets': value,
      if (instance.publicKey case final value?) 'publicKey': value,
    };
