import sqlight

import gleam/dynamic
import gleam/result

import server/context
import server/errors

import shared/lexicons/club/flooo/feed/defs

pub fn get_profile(ctx: context.Context, did: String) {
  "select
    did,
    handler,
    display_name,
    avatar,
    banner
  from
    \"club.flooo.scrobbler\"
  where
    did = ?"
  |> sqlight.query(ctx.db, with: [sqlight.text(did)], expecting: decoder)
  |> result.map_error(errors.DatabaseError)
  |> result.then(fn(results) {
    case results {
      [profile] -> Ok(profile)
      [] -> Error(errors.ProfileNotFound)
      _ -> Error(errors.UnhandledError)
    }
  })
}

fn decoder(data: dynamic.Dynamic) {
  dynamic.decode5(
    defs.PostAuthor,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.optional(dynamic.string)),
    dynamic.element(3, dynamic.optional(dynamic.string)),
    dynamic.element(4, dynamic.optional(dynamic.string)),
  )(data)
}
