import gleam/http/request
import gleam/httpc
import gleam/result

import server/errors

pub fn get_did_doc(
  hostname: String,
  decoder: fn(String) -> Result(String, errors.Error),
) -> Result(String, errors.Error) {
  use res <- result.try(
    request.new()
    |> request.set_host(hostname)
    |> request.set_path("/.well-known/did.json")
    |> httpc.send
    |> result.map_error(errors.FetchError),
  )

  case res.status {
    200 -> decoder(res.body)
    _ -> Error(errors.InvalidDidDoc)
  }
}
