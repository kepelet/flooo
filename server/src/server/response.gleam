import wisp

import gleam/json
import gleam/string

import server/errors

pub fn home() {
  let message =
    "This is an AT Protocol Application View (AppView) for the \"flooo.club\" application: https://github.com/kepelet/flooo

Most API routes are under /xrpc/"

  wisp.response(200) |> wisp.string_body(message)
}

pub fn healthcheck() -> wisp.Response {
  let message: String = "OK"

  wisp.response(200) |> wisp.string_body(message)
}

pub fn not_found(path: List(String)) -> wisp.Response {
  let message = "Cannot GET /" <> string.join(path, "/")

  wisp.response(404) |> wisp.string_body(message)
}

pub fn method_not_implemented() -> wisp.Response {
  json.object([
    #("error", json.string("MethodNotImplemented")),
    #("message", json.string("Method Not Implemented")),
  ])
  |> json.to_string_tree
  |> wisp.json_response(501)
}

pub fn handle_error(err: errors.Error, message: String) {
  case err {
    errors.FetchError(_) -> json_bad_request("FetchError", message)
    errors.DatabaseError(_) -> json_internal_error("DatabaseError", message)
    errors.JsonError(_) -> json_bad_request("JsonError", message)
    errors.RecordNotFound ->
      json_bad_request("RecordNotFound", "Record not found")
    errors.DidNotFound -> json_bad_request("DidNotFound", message)
    errors.FeedNotFound -> json_bad_request("FeedNotFound", message)
    errors.ProfileNotFound -> json_not_found("ProfileNotFound", message)
    errors.UnknownDidMethods -> json_bad_request("UnknownDidMethods", message)
    errors.InvalidServiceEndpoint ->
      json_bad_request("InvalidServiceEndpoint", message)
    errors.InvalidDidDoc -> json_bad_request("InvalidDidDoc", message)
    errors.InvalidRequest -> json_bad_request("InvalidRequest", message)
    errors.InvalidURI -> json_bad_request("InvalidURI", message)
    errors.InvalidDid -> json_bad_request("InvalidDid", message)
    errors.ProxyError -> wisp.response(400) |> wisp.string_body(message)
    errors.ProxySourceNotFound ->
      wisp.response(404) |> wisp.string_body(message)
    errors.ProxySourceNotImage ->
      wisp.response(400) |> wisp.string_body(message)
    errors.UnhandledError ->
      json_internal_error("UnhandledError", "internal server rrror")
  }
}

fn json_bad_request(error: String, message: String) -> wisp.Response {
  json.object([
    #("error", json.string(error)),
    #("message", json.string(message)),
  ])
  |> json.to_string_tree
  |> wisp.json_response(400)
}

fn json_not_found(error: String, message: String) -> wisp.Response {
  json.object([
    #("error", json.string(error)),
    #("message", json.string(message)),
  ])
  |> json.to_string_tree
  |> wisp.json_response(404)
}

fn json_internal_error(error: String, message: String) -> wisp.Response {
  json.object([
    #("error", json.string(error)),
    #("message", json.string(message)),
  ])
  |> json.to_string_tree
  |> wisp.json_response(500)
}
