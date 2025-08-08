# Patches for external dependencies
## 0001-ex_marcel-fix-warning.patch
**Not required**, fixes persistent warning in logs https://github.com/chaskiq/ex-marcel/pull/2

## 0002-assent-base-header.patch
**Required** for Vroid OAuth, adds default headers to all pow_assent requests.
Headers are set in provider custom strategy using key :base_headers
