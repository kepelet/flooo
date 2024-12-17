import wisp

import gleam/json
import gleam/option.{None, Some}
import gleam/result
import gleam/string

import server/context
import server/errors
import server/response
import server/utils

import server/db/scrobble

import server/services/app_bsky_feed
import server/services/com_atproto_repo
import server/services/pds

import shared/flooo/encoder
import shared/lexicons/club/flooo/feed/defs

fn fetch_feed_skeleton(
  ctx: context.Context,
  feed_uri: String,
) -> Result(List(String), errors.Error) {
  use feed_author_did <- result.try(utils.get_did_from_uri(feed_uri))
  use feed_author_pds <- result.try(pds.get_service_endpoint(
    ctx,
    feed_author_did,
  ))

  use feed_generator_endpoint <- result.try(com_atproto_repo.get_user_record(
    feed_author_pds,
    feed_uri,
  ))

  use hostname_from_did <- result.try(utils.get_hostname_from_did(
    feed_generator_endpoint,
  ))

  use feed_skeleton <- result.map(app_bsky_feed.get_feed_skeleton(
    hostname_from_did,
    feed_uri,
  ))

  feed_skeleton
}

fn create_feed_view(scrobbles: List(defs.PostView)) -> wisp.Response {
  scrobbles
  |> json.array(encoder.post_view_json)
  |> fn(scrobblers: json.Json) -> json.Json {
    json.object([#("feed", scrobblers)])
  }
  |> json.to_string_tree
  |> wisp.json_response(200)
}

pub fn get_feed(
  _req: wisp.Request,
  ctx: context.Context,
  feed_uri: String,
) -> wisp.Response {
  let feed = utils.cache_key("feed", feed_uri)

  let query_scrobbles_by_uris = fn(ctx: context.Context, posts: List(String)) {
    case scrobble.get_scrobbles_by_uris(ctx, posts) {
      Ok(scrobbles) -> create_feed_view(scrobbles)
      Error(e) -> response.handle_error(e, "can't create feed view")
    }
  }

  case ctx.cache.get(feed) {
    Some(cached_posts) ->
      query_scrobbles_by_uris(ctx, string.split(cached_posts, ","))
    None ->
      case fetch_feed_skeleton(ctx, feed_uri) {
        Ok(posts) -> {
          ctx.cache.set(feed, string.join(posts, ","))
          query_scrobbles_by_uris(ctx, posts)
        }
        Error(e) -> response.handle_error(e, "can't fetch feed skeleton")
      }
  }
}

pub fn get_author_feed(
  _req: wisp.Request,
  ctx: context.Context,
  did: String,
) -> wisp.Response {
  case utils.validate_did(did) {
    Ok(did) ->
      case scrobble.get_scrobbles_by_author_did(ctx, did) {
        Ok(scrobbles) -> create_feed_view(scrobbles)
        Error(e) -> response.handle_error(e, "can't get author feed")
      }
    Error(e) -> response.handle_error(e, "profile not found")
  }
}
