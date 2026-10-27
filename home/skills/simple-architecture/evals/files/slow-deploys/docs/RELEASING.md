# Releasing to production

1. `git checkout main && git pull`
2. `docker build -t registry.example.com/orders:prod .`
3. `docker push registry.example.com/orders:prod`
4. `kubectl --context prod rollout restart deploy/orders`
5. Watch the logs for a few minutes.

To undo a bad release, check out the previous commit and repeat.
