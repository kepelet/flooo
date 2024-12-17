dev:
  @just dev-client &
  @just dev-server

dev-server:
    @cd server && watchexec --restart --wrap-process=session --stop-signal SIGKILL --exts gleam --watch src/ -- "gleam run"

dev-client:
    @cd client && gleam run -m lustre/dev start

db-status:
    @just -E ./.db.dev.env _db-status

db-migrate:
    @just -E ./.db.dev.env _db-migrate

_db-migrate:
    @cd server && dbmate migrate

_db-status:
    @cd server && dbmate status
