A Dart CLI toolkit and configuration helper for Nebula mesh/overlay networks.

## Writing `nebula.yml` configuration files

`NebulaConfig` is a typed configuration class hierarchy to describe a nebula
configuration, and after creation, the `YAML` file content can be easily generated:

```dart
final config = NebulaConfig(
  pki: PkiConfig(/* ... */),
  staticHostMap: { '192.168.10.1': ['lighthouse-ip.example.com:4242']},
  /* ... */
);
print(config.toYamlString());
```

## Planned features

- Support all fields in nebula's yaml.
- Invoke `nebula-cert` to generate CA and sign certificates.
- Process a network-level configuration and generate deployment artifacts.
