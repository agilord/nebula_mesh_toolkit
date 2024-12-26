import 'dart:convert';
import 'dart:io';

import 'package:nebula_mesh_toolkit/src/generator.dart';
import 'package:nebula_mesh_toolkit/src/network_template.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Network generator', () {
    test('config test', () {
      final map = _loadYamlAsMap('test/small_local_network.yaml');
      final network = Network.fromJson(map);
      expect(network.toJson(), map);
    });

    test('generate assets', () async {
      final temp = await Directory.systemTemp.createTemp();
      try {
        // generate artifacts by running the binary:
        final pr = await Process.run(
          'dart',
          [
            'bin/nebula_mesh_toolkit.dart',
            'generate-artifacts',
            '--input',
            'test/small_local_network.yaml',
            '--output',
            temp.path,
            '--github-asset-cache',
            '.dart_tool/cached-github',
          ],
        );
        expect(pr.exitCode, 0, reason: pr.stderr.toString());
        final caCertificates = await loadCertificatesFromDirectory(
            p.join(temp.path, 'ca', 'keys'));

        // expected files
        final files = temp
            .listSync(recursive: true)
            .whereType<File>()
            .map((f) => p.relative(f.path, from: temp.path))
            .toList()
          ..sort();

        Iterable<String> hostCerts(String host) =>
            caCertificates.map((cf) => cf.certificate).expand(
                  (c) => [
                    'hosts/$host/certs/${c.canonicalId}.crt',
                    'hosts/$host/certs/${c.canonicalId}.crt.json',
                    'hosts/$host/certs/${c.canonicalId}.png',
                  ],
                );

        // uncomment to debug-print the files below
        // print(files.map((e) => '\'$e\',\n').join());
        expect(files, {
          ...caCertificates.map((cf) => cf.certificate).expand(
                (c) => [
                  'ca/keys/${c.canonicalId}.crt',
                  'ca/keys/${c.canonicalId}.crt.json',
                  'ca/keys/${c.canonicalId}.key',
                ],
              ),
          'ca/neb.internal.ca.crt',
          'etc/neb.internal.hosts',
          'hosts/lighthouse-1/bin/nebula',
          'hosts/lighthouse-1/bin/nebula-cert',
          ...hostCerts('lighthouse-1'),
          'hosts/lighthouse-1/etc/neb.internal.ca.crt',
          'hosts/lighthouse-1/etc/neb.internal.hosts',
          'hosts/lighthouse-1/etc/lighthouse-1.neb.internal.crt',
          'hosts/lighthouse-1/etc/lighthouse-1.neb.internal.key',
          'hosts/lighthouse-1/etc/lighthouse-1.neb.internal.pub',
          'hosts/lighthouse-1/etc/lighthouse-1.neb.internal.yml',
          ...hostCerts('mobile-1'),
          'hosts/mobile-1/etc/neb.internal.ca.crt',
          'hosts/mobile-1/etc/neb.internal.hosts',
          'hosts/mobile-1/etc/mobile-1.neb.internal.crt',
          'hosts/mobile-1/etc/mobile-1.neb.internal.key',
          'hosts/mobile-1/etc/mobile-1.neb.internal.pub',
          'hosts/mobile-1/etc/mobile-1.neb.internal.yml',
          ...hostCerts('notebook-1'),
          'hosts/notebook-1/bin/dist/windows/wintun/LICENSE.txt',
          'hosts/notebook-1/bin/dist/windows/wintun/README.md',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/amd64/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/arm/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/arm64/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/x86/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/include/wintun.h',
          'hosts/notebook-1/bin/nebula-cert.exe',
          'hosts/notebook-1/bin/nebula.exe',
          'hosts/notebook-1/etc/neb.internal.ca.crt',
          'hosts/notebook-1/etc/neb.internal.hosts',
          'hosts/notebook-1/etc/notebook-1.neb.internal.crt',
          'hosts/notebook-1/etc/notebook-1.neb.internal.key',
          'hosts/notebook-1/etc/notebook-1.neb.internal.pub',
          'hosts/notebook-1/etc/notebook-1.neb.internal.yml',
          ...hostCerts('server-1'),
          'hosts/server-1/bin/nebula',
          'hosts/server-1/bin/nebula-cert',
          'hosts/server-1/etc/neb.internal.ca.crt',
          'hosts/server-1/etc/neb.internal.hosts',
          'hosts/server-1/etc/server-1.neb.internal.crt',
          'hosts/server-1/etc/server-1.neb.internal.key',
          'hosts/server-1/etc/server-1.neb.internal.pub',
          'hosts/server-1/etc/server-1.neb.internal.yml',
        });

        expect(
          _loadYamlAsMap(p.join(temp.path,
              'hosts/lighthouse-1/etc/lighthouse-1.neb.internal.yml')),
          {
            'pki': {
              'ca': 'neb.internal.ca.crt',
              'cert': 'lighthouse-1.neb.internal.crt',
              'key': 'lighthouse-1.neb.internal.key',
            },
            'lighthouse': {'am_lighthouse': true},
            'listen': {'host': '0.0.0.0', 'port': 4242},
            'cipher': 'aes',
            'relay': {'am_relay': true},
            'firewall': {
              'outbound': [
                {'port': 'any', 'proto': 'any', 'host': 'any'},
              ],
              'inbound': [
                {'port': 'any', 'proto': 'any', 'host': 'any'},
              ]
            }
          },
        );

        expect(
          _loadYamlAsMap(p.join(
              temp.path, 'hosts/server-1/etc/server-1.neb.internal.yml')),
          {
            'pki': {
              'ca': 'neb.internal.ca.crt',
              'cert': 'server-1.neb.internal.crt',
              'key': 'server-1.neb.internal.key',
            },
            'static_host_map': {
              '192.168.100.1': [
                'nebula.example.com:4242',
                '12.34.56.78:4242',
              ],
            },
            'lighthouse': {
              'hosts': ['192.168.100.1'],
            },
            'punchy': {'punch': true},
            'cipher': 'aes',
            'relay': {
              'relays': ['192.168.100.1']
            },
            'firewall': {
              'outbound': [
                {'port': 'any', 'proto': 'any', 'host': 'any'},
              ],
              'inbound': [
                {'port': 'any', 'proto': 'any', 'host': 'any'},
              ]
            }
          },
        );

        expect(
          _loadYamlAsMap(p.join(
              temp.path, 'hosts/notebook-1/etc/notebook-1.neb.internal.yml')),
          {
            'pki': {
              'ca': 'neb.internal.ca.crt',
              'cert': 'notebook-1.neb.internal.crt',
              'key': 'notebook-1.neb.internal.key'
            },
            'static_host_map': {
              '192.168.100.1': [
                'nebula.example.com:4242',
                '12.34.56.78:4242',
              ],
            },
            'lighthouse': {
              'hosts': ['192.168.100.1'],
            },
            'cipher': 'aes',
            'tun': {'dev': 'tun24'},
            'firewall': {
              'outbound': [
                {'port': 'any', 'proto': 'any', 'host': 'any'},
              ],
              'inbound': [
                {'port': 'any', 'proto': 'icmp', 'host': 'any'},
              ],
            },
          },
        );

        expect(
          File(p.join(temp.path, 'etc', 'neb.internal.hosts'))
              .readAsLinesSync(),
          [
            '192.168.100.1   lighthouse-1.neb.internal',
            '192.168.100.10  server-1.neb.internal',
            '192.168.100.253 notebook-1.neb.internal',
            '192.168.100.254 mobile-1.neb.internal',
          ],
        );
      } finally {
        await temp.delete(recursive: true);
      }
    });
  });
}

Map<String, dynamic> _loadYamlAsMap(String path) {
  final map =
      json.decode(json.encode(loadYamlNode(File(path).readAsStringSync())));
  return map as Map<String, dynamic>;
}
