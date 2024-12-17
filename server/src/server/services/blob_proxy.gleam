import wisp

import gleam/http/response

import gleam/bytes_tree
import gleam/list
import gleam/result
import gleam/string

import server/errors
import server/services/com_atproto_sync

pub fn get_blob(
  pds: String,
  did: String,
  cid: String,
) -> Result(wisp.Response, errors.Error) {
  case com_atproto_sync.get_blob(pds, did, cid) {
    Ok(res) -> {
      case res.status {
        404 | 400 -> Error(errors.ProxySourceNotFound)
        _ -> {
          let content_type =
            response.get_header(res, "content-type")
            |> result.unwrap("")
            |> string.lowercase()

          let image_types = [
            "image/jpeg", "image/png", "image/gif", "image/webp", "image/avif",
          ]

          case list.contains(image_types, content_type) {
            True -> {
              wisp.ok()
              |> wisp.set_body(wisp.Bytes(res.body |> bytes_tree.from_bit_array))
              |> fn(response) {
                list.fold(res.headers, response, fn(resp, header) {
                  wisp.set_header(resp, header.0, header.1)
                })
              }
              |> wisp.set_header("Cache-Control", "public,max-age=43200")
              |> wisp.set_header("X-via", "api.flooo.club")
              |> Ok
            }
            False -> Error(errors.ProxySourceNotImage)
          }
        }
      }
    }
    Error(_) -> Error(errors.ProxyError)
  }
}
