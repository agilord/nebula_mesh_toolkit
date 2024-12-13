A Dart CLI toolkit and configuration helper for Nebula mesh/overlay networks.

## Writing `nebula.yml` configuration files

`NebulaConfig` is a typed configuration class hierarchy to describe a nebula
configuration, and after creating the objects, the `YAML` file content can be
easily generated:

```dart
final config = NebulaConfig(
  pki: PkiConfig(/* ... */),
  staticHostMap: { '192.168.10.1': ['lighthouse-ip.example.com:4242']},
  /* ... */
);
print(config.toYamlString());
```

## Define a network and generate artifacts

Usually there are repeated patterns in the configuration of the Nebula nodes.
By defining the nodes as part of a template, one can keep the repeated parts
in a single source, keeping it consistent in a single place. E.g. the following
describes a simple network with some roles:

```yaml
id: 1 # the tun device id + network identifier
cipher: aes
duration: 182d

templates:
  - groups: ['lighthouse']
    listen:
      host: '0.0.0.0'
      port: 4242
    relay:
      am_relay: true
    firewall_presets: [any]
    hosts:
      - name: lighthouse-1
        address: 192.168.100.1/24
        publicAddresses: ['nebula.example.com:4242', '12.34.56.78:4242']

  - groups: ['server']
    punchy:
      punch: true
    relay:
      relays: ['@lighthouse'] # relays can be references with `@<group-name>`
    firewall_presets: [any]   # only the `any` preset is defined at the moment
    hosts:
      - name: server-1
        address: 192.168.100.10/24
  
  - groups: ['admin']
    hosts:
      - name: notebook-1
        address: 192.168.100.20/24
        os: windows
      - name: mobile-1
        address: 192.168.100.21/24
        os: android
```

The artifact generation creates the following output structure:

```
|- ca
|  |- keys
|  |  |- <not-before-timestamp>-<fingerprint>.crt
|  |  |- <not-before-timestamp>-<fingerprint>.crt.json
|  |  |- <not-before-timestamp>-<fingerprint>.crt.key
|  |  |- 20241213202756-2a3ebc600e3211203a158e1ddbb9b4d2b4f53d7b70280d8a433a1ebf4f2aa9a8.crt
|  |  |- 20241213202756-2a3ebc600e3211203a158e1ddbb9b4d2b4f53d7b70280d8a433a1ebf4f2aa9a8.crt.json
|  |  |- 20241213202756-2a3ebc600e3211203a158e1ddbb9b4d2b4f53d7b70280d8a433a1ebf4f2aa9a8.crt.key
|  |- nebula-1.ca.crt
|- hosts
|  |- lighthouse-1
|  |  |- bin
|  |  |  |- nebula
|  |  |  |- nebula-cert
|  |  |- etc
|  |    |- nebula-1.ca.crt
|  |    |- nebula-1-lighthouse-1.crt
|  |    |- nebula-1-lighthouse-1.crt.json
|  |    |- nebula-1-lighthouse-1.key
|  |    |- nebula-1-lighthouse-1.png
|  |    |- nebula-1-lighthouse-1.pub
|  |    |- nebula-1-lighthouse-1.yml
|  |- server-1
|  |  |- ...
|  |- notebook-1
|  |  |- ...
|  |- mobile-1
|     |- ...
```

## Limitations

**Planned improvements**:
- There is no incremental update or key rotation (yet).
- The script is tested only on Linux (yet).
- Firewall presets are not part of the network (yet).

**Outside of the scope of this toolkit**:
- The artifacts must be copied to the hosts separately.

## Contributing

Please open a new issue to discuss missing or expected features.

## See also

- [Nebula mesh networking](https://github.com/slackhq/nebula/) and
  [quick start guide](https://nebula.defined.net/docs/guides/quick-start/)
- [nebuilder](https://github.com/erykjj/nebulder) - a Python script with similar goals
