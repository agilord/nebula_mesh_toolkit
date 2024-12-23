## 0.4.0

**Breaking changes**:
- `id` and `name` are removed:
  - Instead of `id` and `name`, one must specify the `domain` of the network. One may use the `.internal` TLD.
  - Instead of `id`, one can specify the `tun` configuration on both the `Template` and the `Host`. When absent,
    `windows` machines get auto-generated tun device name.
- The generator output follows the FQDN naming using the host name and the network domain.
- The default CA expiration time `duration` is renamed to `expiry`.
- The default CA renewal time `renew` is renamed to `keep`.

**New features**:
- `Network.addresses` will be passed to the CA certificate to limit IP ranges.
- Generate `etc/<domain>.hosts` with the list of `ip` -> fully qualified hostnames.
  The file is also copied to `hosts/<host>/etc/<domain>.hosts`.
- `Host.address` is no longer required, the first `Network.address` will be used to generate an unused one.
  Note: the actual sequence algorithm is pending to change. 

## 0.3.2

- Fix: use only the latest certificate for hosts (still keeping all the valid ones just in case they are useful).
- Support minimum period before rotating the CA (`renew`) with the same duration format as `duration`.

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
