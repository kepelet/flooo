import envoy
import sqlight
import wisp

import cici

pub type Environment {
  Production
  Development
  Testing
}

pub type Context {
  Context(db: sqlight.Connection, cache: cici.Cache, env: Environment)
}

const preflight = "
pragma foreign_keys = on;
pragma journal_mode = wal;
"

pub fn init() {
  let cache = cici.new(ttl: 60 * 12)

  let env = read_environment()
  let database = setup_database()

  let assert Ok(db) = sqlight.open(database)
  let assert Ok(_) = sqlight.exec(preflight, db)

  Context(db:, cache:, env:)
}

fn read_environment() {
  case envoy.get("GLEAM_ENV") {
    Ok("development") -> Development
    Ok("testing") -> Testing
    _ -> Production
  }
}

fn setup_database() {
  case envoy.get("DATABASE_URL") {
    Ok(path) -> path
    Error(Nil) ->
      case read_environment() {
        Production | Development -> "./data/database.sqlite"
        Testing -> ":memory:"
      }
  }
}

pub fn get_secret_key_base() {
  wisp.random_string(64)
}
