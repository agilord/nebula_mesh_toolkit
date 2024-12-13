import 'dart:convert';
import 'dart:io';

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
        // generate artifacts programmatically:
        // final map = _loadYamlAsMap('test/small_local_network.yaml');
        // final network = Network.fromJson(map);
        // final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');
        // await network.generateArtifacts(outputPath: temp.path, assets: gh);

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
        expect(pr.exitCode, 0);

        // expected files
        final files = temp
            .listSync(recursive: true)
            .whereType<File>()
            .map((f) => p.relative(f.path, from: temp.path))
            .toSet()
            .toList()
          ..sort();
        // uncomment to debug-print the files below
        // print(files.map((e) => '\'$e\',\n').join());
        expect(files, {
          'ca/nebula-1-ca.crt',
          'ca/nebula-1-ca.key',
          'hosts/lighthouse-1/bin/nebula',
          'hosts/lighthouse-1/bin/nebula-cert',
          'hosts/lighthouse-1/etc/nebula-1-ca.crt',
          'hosts/lighthouse-1/etc/nebula-1-lighthouse-1.crt',
          'hosts/lighthouse-1/etc/nebula-1-lighthouse-1.key',
          'hosts/lighthouse-1/etc/nebula-1-lighthouse-1.png',
          'hosts/lighthouse-1/etc/nebula-1-lighthouse-1.yml',
          'hosts/mobile-1/etc/nebula-1-ca.crt',
          'hosts/mobile-1/etc/nebula-1-mobile-1.crt',
          'hosts/mobile-1/etc/nebula-1-mobile-1.key',
          'hosts/mobile-1/etc/nebula-1-mobile-1.png',
          'hosts/mobile-1/etc/nebula-1-mobile-1.yml',
          'hosts/notebook-1/bin/dist/windows/wintun/LICENSE.txt',
          'hosts/notebook-1/bin/dist/windows/wintun/README.md',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/amd64/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/arm/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/arm64/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/bin/x86/wintun.dll',
          'hosts/notebook-1/bin/dist/windows/wintun/include/wintun.h',
          'hosts/notebook-1/bin/nebula-cert.exe',
          'hosts/notebook-1/bin/nebula.exe',
          'hosts/notebook-1/etc/nebula-1-ca.crt',
          'hosts/notebook-1/etc/nebula-1-notebook-1.crt',
          'hosts/notebook-1/etc/nebula-1-notebook-1.key',
          'hosts/notebook-1/etc/nebula-1-notebook-1.png',
          'hosts/notebook-1/etc/nebula-1-notebook-1.yml',
          'hosts/server-1/bin/nebula',
          'hosts/server-1/bin/nebula-cert',
          'hosts/server-1/etc/nebula-1-ca.crt',
          'hosts/server-1/etc/nebula-1-server-1.crt',
          'hosts/server-1/etc/nebula-1-server-1.key',
          'hosts/server-1/etc/nebula-1-server-1.png',
          'hosts/server-1/etc/nebula-1-server-1.yml',
        });

        expect(
          _loadYamlAsMap(p.join(
              temp.path, 'hosts/lighthouse-1/etc/nebula-1-lighthouse-1.yml')),
          {
            'pki': {
              'ca': 'nebula-1-ca.crt',
              'cert': 'nebula-1-lighthouse-1.crt',
              'key': 'nebula-1-lighthouse-1.key',
            },
            'lighthouse': {'am_lighthouse': true},
            'listen': {'host': '0.0.0.0', 'port': 4242},
            'cipher': 'aes',
            'relay': {'am_relay': true},
            'tun': {'dev': 'tun1'},
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
          _loadYamlAsMap(
              p.join(temp.path, 'hosts/server-1/etc/nebula-1-server-1.yml')),
          {
            'pki': {
              'ca': 'nebula-1-ca.crt',
              'cert': 'nebula-1-server-1.crt',
              'key': 'nebula-1-server-1.key',
            },
            'static_host_map': {
              '192.168.100.1/24': [
                'nebula.example.com:4242',
                '12.34.56.78:4242',
              ],
            },
            'lighthouse': {
              'hosts': ['192.168.100.1/24'],
            },
            'punchy': {'punch': true},
            'cipher': 'aes',
            'relay': {
              'relays': ['192.168.100.1']
            },
            'tun': {'dev': 'tun1'},
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
              temp.path, 'hosts/notebook-1/etc/nebula-1-notebook-1.yml')),
          {
            'pki': {
              'ca': 'nebula-1-ca.crt',
              'cert': 'nebula-1-notebook-1.crt',
              'key': 'nebula-1-notebook-1.key'
            },
            'static_host_map': {
              '192.168.100.1/24': [
                'nebula.example.com:4242',
                '12.34.56.78:4242',
              ],
            },
            'lighthouse': {
              'hosts': ['192.168.100.1/24'],
            },
            'cipher': 'aes',
            'tun': {'dev': 'tun1'},
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
