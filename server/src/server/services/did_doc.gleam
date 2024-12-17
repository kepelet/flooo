import gleam/dynamic
import gleam/json
import gleam/list
import gleam/result
import gleam/string

import server/errors
import server/services/did_plc
import server/services/did_web

pub fn get_pds_from_did_doc(did: String) -> Result(String, errors.Error) {
  case string.split(did, ":") {
    [_did, method, controller] -> {
      case method {
        "web" -> did_web.get_did_doc(controller, decode)
        "plc" -> did_plc.get_did_doc_from_plc_directory(did, decode)
        _ -> Error(errors.UnknownDidMethods)
      }
    }
    _ -> Error(errors.InvalidDid)
  }
}

fn decode(body: String) -> Result(String, errors.Error) {
  let decoder =
    dynamic.field(
      "service",
      dynamic.list(dynamic.field("serviceEndpoint", dynamic.string)),
    )

  use endpoints <- result.try({
    json.decode(body, decoder)
    |> result.map_error(errors.JsonError)
  })

  list.first(endpoints) |> result.replace_error(errors.InvalidServiceEndpoint)
}
