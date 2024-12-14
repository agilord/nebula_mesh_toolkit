## 0.3.1

- Do not override existing private and public key when they exists.
- Cleanup of host certificates when public key does not exists.

## 0.3.0

- New output directory structure: separating `hosts/` and `ca/`
- Support for key rotation:
  - `ca/keys` store multiple CA keys for rolling updates in the `<ts>-<fingerprint>.crt` format
  - `hosts/<host>/certs` store multiple certificate signature for rolling updates in the above format
- `nebula-cert` `ca` and `sign` also outputs `.crt.json` with the certificate info
- `nebula-cert` `keygen` is used to generate public key, `sign` uses it if exists
- Support expiry `duration`.
- Updated lints.

## 0.2.0

- Better class names for nebula `yaml` configurtion.
- `Network` template definition + generating artifacts.

## 0.1.0

- Partial support for writing nebula `yaml` configuration.
