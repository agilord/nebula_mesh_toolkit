import 'package:nebula_mesh_toolkit/src/nebula_config.dart';
import 'package:test/test.dart';

void main() {
  group('config writer', () {
    test('all fields', () {
      final config = NebulaConfig(
        pki: PkiConfig(
          ca: '/path/to/ca.crt',
          cert: '/path/to/host.crt',
          key: '/path/to/host.key',
          blocklist: [],
          disconnectInvalid: true,
        ),
        staticHostMap: {
          '192.168.10.1': [
            'lighthouse-ip.example.com:4242',
          ],
        },
        lighthouse: LighthouseConfig(
          amLighthouse: false,
          hosts: [
            '192.168.10.1',
          ],
        ),
        listen: ListenConfig(
          host: '0.0.0.0',
          port: 0,
        ),
        punchy: PunchyConfig(
          punch: true,
        ),
        cipher: 'aes',
        relay: RelayConfig(
          amRelay: false,
          useRelays: true,
          relays: [
            '192.168.10.1',
          ],
        ),
        tun: TunConfig(
          dev: 'nebula1',
        ),
        firewall: FirewallConfig(
          outbound: [
            FirewallRule(host: 'any'),
          ],
          inbound: [
            FirewallRule(groups: ['admin-group']),
          ],
        ),
      );

      expect(
        config.toYamlString(),
        'pki:\n'
        '  ca: /path/to/ca.crt\n'
        '  cert: /path/to/host.crt\n'
        '  key: /path/to/host.key\n'
        '  blocklist: []\n'
        '  disconnect_invalid: true\n'
        'static_host_map:\n'
        '  192.168.10.1:\n'
        '    - lighthouse-ip.example.com:4242\n'
        'lighthouse:\n'
        '  am_lighthouse: false\n'
        '  hosts:\n'
        '    - 192.168.10.1\n'
        'listen:\n'
        '  host: 0.0.0.0\n'
        '  port: 0\n'
        'punchy:\n'
        '  punch: true\n'
        'cipher: aes\n'
        'relay:\n'
        '  relays:\n'
        '    - 192.168.10.1\n'
        '  am_relay: false\n'
        '  use_relays: true\n'
        'tun:\n'
        '  dev: nebula1\n'
        'firewall:\n'
        '  outbound:\n'
        '    - port: any\n'
        '      proto: any\n'
        '      host: any\n'
        '  inbound:\n'
        '    - port: any\n'
        '      proto: any\n'
        '      groups:\n'
        '        - admin-group',
      );
    });
  });
}
