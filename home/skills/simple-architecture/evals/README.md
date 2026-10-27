# simple-architecture evals

Eight tasks that tempt an agent to over-architect or to ignore the repository's own decisions. Each one
targets one part of the skill:

| Eval | Tests |
| --- | --- |
| signup-welcome | in-component job table as outbox; no broker or events for hypothetical consumers |
| invoice-audit | targeted append-only history; actor fields; database-enforced immutability |
| reporting-split | recorded decisions win; fix the measured cause before splitting; propose, don't merge |
| import-worker | repository decisions over skill defaults; no stack carried over from elsewhere |
| display-name | sync unless a consumer exists |
| spa-login | web edge as BFF; no tokens in the browser |
| column-rename | expand/contract across deploys; migrations as a separate serialized step |
| slow-deploys | measure the critical path before buying runners; build once, promote by digest; no deploys from PR runs |

The format matches `../../simple-code/evals/evals.json`. Run and grade with the shared harness in
`home/skills/eval-harness/` (`SKILL=simple-architecture`; see its README). Grade blind with `grade.md` against each eval's `expectations`.
Nothing under `evals/` is deployed. Run evals only when asked.
