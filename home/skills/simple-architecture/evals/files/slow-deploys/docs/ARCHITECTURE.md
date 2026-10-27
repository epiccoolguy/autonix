# Architecture

`orders` is one Go service on Kubernetes with a staging and a production cluster. CI is GitHub
Actions on hosted runners (`.github/workflows/ci.yml`). Staging deploys from CI on every push to
`main`; production releases are manual, see `docs/RELEASING.md`.
