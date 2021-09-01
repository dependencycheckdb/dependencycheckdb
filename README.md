# dependencycheckdb

Docker container with a H2 database and a read-only user, ready to accept connections from Dependency-Check clients (in no-update mode), with automatic daily updates of the vulnerabilities database.

`
docker run -d --rm --name dependencycheckdb -p 9092:9092 dependencycheckdb/dependencycheckdb:latest
`

connectionString: jdbc:h2:tcp://localhost/db

databaseUser: readonly

databasePassword: readonly