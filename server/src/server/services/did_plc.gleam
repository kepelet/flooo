import gleam/http/request
import gleam/httpc
import gleam/result

import server/errors

pub fn get_did_doc_from_plc_directory(
  did: String,
  decoder: fn(String) -> Result(String, errors.Error),
) -> Result(String, errors.Error) {
  use res <- result.try(
    request.new()
    |> request.set_host("plc.directory")
    |> request.set_path(did)
    |> httpc.send
    |> result.map_error(errors.FetchError),
  )

  case res.status {
    200 -> decoder(res.body)
    404 -> Error(errors.DidNotFound)
    _ -> Error(errors.InvalidDidDoc)
  }
}
