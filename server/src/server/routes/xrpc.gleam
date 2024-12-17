import wisp

import gleam/list
import gleam/result

import server/context
import server/errors
import server/response

import server/routes/xrpc/club_flooo_feed
import server/routes/xrpc/club_flooo_get_profile

pub fn router(
  req: wisp.Request,
  ctx: context.Context,
  routes: List(String),
) -> wisp.Response {
  case routes {
    ["xrpc", "club.flooo.feed.getFeed"] ->
      case
        wisp.get_query(req)
        |> list.find(fn(params) { params.0 == "feed" })
        |> result.map(fn(params) { params.1 })
      {
        Ok("") | Ok("undefined") ->
          response.handle_error(errors.InvalidRequest, "feed not found")
        Ok(feed) -> club_flooo_feed.get_feed(req, ctx, feed)
        Error(_) ->
          response.handle_error(errors.InvalidRequest, "feed not found")
      }
    ["xrpc", "club.flooo.feed.getAuthorFeed"] ->
      case
        wisp.get_query(req)
        |> list.find(fn(params) { params.0 == "actor" })
        |> result.map(fn(params) { params.1 })
      {
        Ok("") | Ok("undefined") ->
          response.handle_error(errors.InvalidRequest, "profile not found")
        Ok(did) -> club_flooo_feed.get_author_feed(req, ctx, did)
        Error(_) ->
          response.handle_error(errors.InvalidRequest, "profile not found")
      }
    ["xrpc", "club.flooo.getProfile"] ->
      case
        wisp.get_query(req)
        |> list.find(fn(params) { params.0 == "actor" })
        |> result.map(fn(params) { params.1 })
      {
        Ok("") | Ok("undefined") ->
          response.handle_error(errors.InvalidRequest, "profile not found")
        Ok(did) -> club_flooo_get_profile.get_profile(req, ctx, did)
        Error(_) ->
          response.handle_error(errors.InvalidRequest, "profile not found")
      }
    _ -> response.method_not_implemented()
  }
}
