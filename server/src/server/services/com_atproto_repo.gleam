import gleam/httpc

import gleam/http/request

import gleam/dynamic
import gleam/json
import gleam/result
import gleam/string

import server/errors

pub fn get_user_record(pds: String, uri: String) -> Result(String, errors.Error) {
  case string.split(uri, "/") {
    [_, _, repo, record, rkey] -> {
      use resp <- result.try({
        request.new()
        |> request.set_host(pds)
        |> request.set_path("/xrpc/com.atproto.repo.getRecord")
        |> request.set_query([
          #("repo", repo),
          #("collection", record),
          #("rkey", rkey),
        ])
        |> httpc.send()
        |> result.map_error(errors.FetchError)
      })

      case resp.status {
        200 ->
          resp.body
          |> json.decode(dynamic.field(
            "value",
            dynamic.field("did", dynamic.string),
          ))
          |> result.map_error(errors.JsonError)
        400 | 404 -> Error(errors.RecordNotFound)
        _ -> Error(errors.UnhandledError)
      }
    }
    _ -> Error(errors.InvalidURI)
  }
}
