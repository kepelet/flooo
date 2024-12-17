import wisp

import gleam/json

import server/context
import server/response
import server/utils

import server/db/profile

import shared/lexicons/club/flooo/feed/defs

import shared/flooo/encoder

fn profile_view(profile: defs.PostAuthor) -> wisp.Response {
  profile
  |> encoder.profile_view_json
  |> json.to_string_tree
  |> wisp.json_response(200)
}

pub fn get_profile(
  _req: wisp.Request,
  ctx: context.Context,
  did: String,
) -> wisp.Response {
  case utils.validate_did(did) {
    Ok(did) ->
      case profile.get_profile(ctx, did) {
        Ok(profile) -> profile_view(profile)
        Error(e) -> response.handle_error(e, "profile not found")
      }
    Error(e) -> response.handle_error(e, "profile not found")
  }
}
