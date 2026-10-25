# simple-testing evals

Four A/B evals (with the skill vs without it), each tempting a failure the skill targets:

| Eval | Tempts |
| --- | --- |
| py-billing-bug | fixing without a failing test first; mocking time |
| py-order-tests | patching modules, mocking pure collaborators, asserting on call counts |
| go-overdue-query | `NOW()` in SQL, a substitute database, claiming done without running the integration tier |
| go-flaky-worker | a longer sleep, retries, or a skip instead of fixing the race |

Run and grade them with the simple-code harness in `home/skills/simple-code/evals/harness/`, replacing `simple-code` with `simple-testing` in its paths. Fixture tools: `python3`, `go test`, `go vet`, `gofmt`. Graders also run the commands named in the expectations (both TZ values, `go test -race -count=200`, `go vet -tags integration`).
