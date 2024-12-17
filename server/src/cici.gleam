import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}

type Key =
  String

type Value =
  String

type TTL =
  Int

pub type Cache {
  ETS(
    get: fn(Key) -> Option(Value),
    set: fn(Key, Value) -> Nil,
    set_with_ttl: fn(Key, Value, TTL) -> Nil,
    delete: fn(Key) -> Nil,
  )
}

pub fn new(ttl ttl: TTL) -> Cache {
  let t = create_table()

  ETS(
    get: fn(k) {
      case get(t, k, current_time()) {
        Ok(v) -> Some(v)
        Error(_) -> None
      }
    },
    delete: fn(k) { delete(t, k) },
    set: fn(k, v) { insert(t, k, v, current_time() + ttl) },
    set_with_ttl: fn(k, v, ttl) { insert(t, k, v, current_time() + ttl) },
  )
}

@external(erlang, "cici_ets", "create_table")
fn create_table() -> Dynamic

@external(erlang, "cici_ets", "get")
fn get(table: Dynamic, key: Key, current_time: TTL) -> Result(Value, Nil)

@external(erlang, "cici_ets", "insert")
fn insert(table: Dynamic, key: Key, value: Value, expiry: TTL) -> Nil

@external(erlang, "cici_ets", "delete")
fn delete(table: Dynamic, key: Key) -> Nil

@external(erlang, "cici_ets", "current_time")
fn current_time() -> Int
