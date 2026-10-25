# Architecture

Services are Kotlin on the JVM (Spring Boot), deployed to Kubernetes with Helm-free plain manifests in
`deploy/`. MySQL 8 is the database, RabbitMQ the message broker; both are run by the platform team.
Uploads land in the `uploads` bucket (S3 API). Decisions are in `decisions/`.
