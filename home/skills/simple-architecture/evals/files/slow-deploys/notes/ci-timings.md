# CI timings, median of the last 20 runs on main

| Step | Time |
| --- | --- |
| Queue (hosted runner) | 4s |
| Checkout + setup-go | 25s |
| Generate code (`go run protogen@v1.9.0`, compiles the tool) | 5m35s |
| go test | 1m05s |
| Docker build + push | 2m20s |
| Rollout restart + status | 1m10s |
| **Total to staging** | **~10m40s** |

Runner CPU sits around 40% during codegen; most of it is downloading and compiling protogen's
dependencies.
