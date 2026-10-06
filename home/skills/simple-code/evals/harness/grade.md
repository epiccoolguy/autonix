Grade the simple-code eval run in R=~/simple-code-evals/run-copilot-1 blind. Do not open key-*.tsv until step 3.

1. Read /etc/nix-darwin/home/skills/simple-code/evals/evals.json for each eval's expectations.
2. For every R/out/<id>.diff, read R/out/<id>.meta (eval name, model, repeat) and R/out/<id>.txt. Ignore R/out/<id>.jsonl except to check what the run did when the diff is unclear; don't use it to infer the arm. Grade each expectation pass/fail with one line of evidence quoted from the diff or final text. Note correctness bugs and unrequested changes separately in R/notes.tsv. Where the toolchain allows, check the code in R/work/<id> (python3 -m py_compile, go vet and go test, rustc --edition 2021 --test, tsc with a small @nestjs/common shim). Write every grade to R/grades.tsv (id, eval, model, repeat, expectation number, pass, evidence) before continuing.
3. Only now join grades.tsv with R/key-with-skill.tsv and R/key-without-skill.tsv (columns: id, arm, outcome, committed, artifacts, skill_loaded).
4. Write R/grading-report.md (not report.md: macOS filesystems ignore case, and runners write REPORT.md):
   - Treatment check first: with-skill runs with skill_loaded=yes vs no, and any without-skill run with skill_loaded=yes. Analyse with-skill runs with skill_loaded=yes as the treatment, and report the rest separately.
   - Outcomes: no-change, failed, and timeout counts per arm x model. These are their own outcome; don't fold them into expectation pass rates.
   - Pass rate per arm x model over completed runs, as the mean and range across the 3 repeats.
   - Per eval and expectation: where the arms differ consistently across repeats (at least 2 of 3), versus noise.
   - Hygiene: unasked commits and staged build artifacts per arm.
   - Expectations that still pass or fail everywhere (non-discriminating).
   - Verdict: does the skill measurably improve results on top of the AGENTS.md core, for which models and which kinds of task? Say plainly if the evidence is too thin.
