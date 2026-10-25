DATABASE_URL ?= postgres://postgres:test@localhost:55432/postgres

test:
	go test ./...

test-integration:
	docker compose up -d --wait
	DATABASE_URL=$(DATABASE_URL) go test -tags integration ./...
