import envoy

import gleam/erlang/process
import gleam/int
import gleam/result

import mist

import wisp
import wisp/wisp_mist

import server/context
import server/router

pub fn main() {
  let ctx = context.init()

  let assert Ok(_) = start_http_server(ctx)
  let assert Ok(_) = start_jetstream_consumer(ctx)

  wisp.configure_logger()
  process.sleep_forever()
}

fn start_jetstream_consumer(ctx) {
  Ok(ctx)
}

fn start_http_server(ctx) {
  let host = envoy.get("HOST") |> result.unwrap("127.0.0.1")
  let port =
    envoy.get("PORT")
    |> result.then(int.parse)
    |> result.unwrap(8000)

  let secret_key_base = context.get_secret_key_base()

  router.handle_request(_, ctx)
  |> wisp_mist.handler(secret_key_base)
  |> mist.new
  |> mist.bind(host)
  |> mist.port(port)
  |> mist.start_http_server
}
