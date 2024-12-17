import gleam/httpc

import gleam/http/request
import gleam/http/response

import gleam/bit_array
import gleam/result

import server/errors

pub fn get_blob(
  pds: String,
  did: String,
  cid: String,
) -> Result(response.Response(BitArray), errors.Error) {
  request.new()
  |> request.set_host(pds)
  |> request.set_path("/xrpc/com.atproto.sync.getBlob")
  |> request.set_query([#("did", did), #("cid", cid)])
  |> request.set_body(bit_array.from_string(""))
  |> request.set_header("User-Agent", "flooo/1.0")
  |> httpc.send_bits()
  |> result.map_error(errors.FetchError)
}
