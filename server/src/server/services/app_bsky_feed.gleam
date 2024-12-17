import gleam/httpc

import gleam/dynamic
import gleam/http/request
import gleam/json
import gleam/result

import server/errors

pub fn get_feed_skeleton(service_endpoint: String, feed: String) {
  use resp <- result.try(
    request.new()
    |> request.set_host(service_endpoint)
    |> request.set_path("/xrpc/app.bsky.feed.getFeedSkeleton")
    |> request.set_query([#("feed", feed)])
    |> httpc.send()
    |> result.map_error(errors.FetchError),
  )

  case resp.status {
    200 ->
      json.decode(
        resp.body,
        dynamic.field(
          "feed",
          dynamic.list(dynamic.field("post", dynamic.string)),
        ),
      )
      |> result.map_error(errors.JsonError)
    400 | 404 -> Error(errors.FeedNotFound)
    _ -> Error(errors.UnhandledError)
  }
}
