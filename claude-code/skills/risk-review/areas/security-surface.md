# security-surface

Does the change add or widen a way for untrusted input or an unauthorized
actor to reach code, data or credentials?

Rate the change in surface. This is not a vulnerability audit of the changed
code. `/security-review` does that.

## Not applicable when

Never. A change that adds no input, permission, secret, network exposure or
dependency is `low`.

## Check

- **New inputs.** Endpoints, CLI arguments, file parsers, deserialization,
  environment variables, webhooks, uploads, fetched URLs.
- **Trust boundaries.** Does data from a less trusted source reach a shell,
  SQL, `eval`, a file path, a template or HTML without validation?
- **Authorization.** New, changed or removed checks. Default-allow. Wider
  roles, scopes, IAM policies, file modes or sandbox bindings.
- **Secrets.** Secrets added to the repository, logs, error messages or
  command lines. New handling of credentials.
- **Network exposure.** Listening addresses, ports, CORS, TLS settings,
  firewall rules.
- **Dependencies.** New dependencies, install scripts, unpinned versions,
  code fetched and executed at run time.
- **Cryptography.** Hand-written primitives or weakened parameters.
- **Privilege.** Execution as root, setuid, sudo rules, container
  capabilities.

## Levels

- `low`: no new input, permission, secret handling, network exposure or
  dependency.
- `medium`: the change adds surface and includes its validation or
  authorization. Or it adds a pinned dependency. Or it widens a permission
  that the changed code uses.
- `high`: untrusted input reaches an interpreter, a query or a file path
  without validation. Or the change removes an authorization check or
  defaults to allow. Or a secret is in the repository or in logs. Or
  unpinned code is fetched and executed. Or a permission is wider than the
  changed code uses.
