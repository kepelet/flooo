import sqlight

import gleam/dynamic
import gleam/option
import gleam/result
import gleam/string

import server/context
import server/errors

import shared/lexicons/club/flooo/feed/defs
import shared/lexicons/club/flooo/feed/post

pub fn get_scrobbles_by_author_did(ctx: context.Context, did: String) {
  "select
    s.id,
    s.cid,
    s.uri,
    s.artist_name,
    s.album_cover_cid,
    s.album_name,
    s.track_name,
    s.created_at,
    s.indexed_at,
    s.author_did,
    u.handler
    from
    \"club.flooo.scrobble\" s
  left join
    \"club.flooo.scrobbler\" u on s.author_did = u.did
  where
    s.author_did = ?"
  |> sqlight.query(
    ctx.db,
    with: [sqlight.text(did)],
    expecting: rows_to_scrobble,
  )
  |> result.map_error(errors.DatabaseError)
}

pub fn get_scrobbles_by_uris(ctx: context.Context, uris: List(String)) {
  "select
    s.id,
    s.cid,
    s.uri,
    s.artist_name,
    s.album_cover_cid,
    s.album_name,
    s.track_name,
    s.created_at,
    s.indexed_at,
    s.author_did,
    u.handler
    from
    \"club.flooo.scrobble\" s
  left join
    \"club.flooo.scrobbler\" u on s.author_did = u.did
  where
    s.uri in (?)"
  |> sqlight.query(
    ctx.db,
    with: [sqlight.text(string.join(uris, ","))],
    expecting: rows_to_scrobble,
  )
  |> result.map_error(errors.DatabaseError)
}

pub fn rows_to_scrobble(
  data: dynamic.Dynamic,
) -> Result(defs.PostView, List(dynamic.DecodeError)) {
  let decode_scrobble =
    dynamic.decode9(
      fn(
        _id: Int,
        cid: String,
        uri: String,
        artist_name: String,
        album_cover: option.Option(String),
        album_name: option.Option(String),
        track_name: String,
        created_at: Int,
        indexed_at: Int,
      ) {
        let post =
          decode_scrobble_post(
            artist_name,
            album_cover,
            album_name,
            track_name,
            created_at,
          )

        fn(author_did: String, author_handler: String) {
          let author =
            defs.PostAuthor(
              author_did,
              author_handler,
              option.None,
              option.None,
              option.None,
            )

          defs.PostView(uri, cid, author, post, indexed_at)
        }
      },
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, dynamic.string),
      dynamic.element(3, dynamic.string),
      dynamic.element(4, dynamic.optional(dynamic.string)),
      dynamic.element(5, dynamic.optional(dynamic.string)),
      dynamic.element(6, dynamic.string),
      dynamic.element(7, dynamic.int),
      dynamic.element(8, dynamic.int),
    )(data)

  case decode_scrobble {
    Ok(constructor) -> decode_rest(data, constructor)
    Error(e) -> Error(e)
  }
}

fn decode_rest(
  data: dynamic.Dynamic,
  constructor: fn(String, String) -> defs.PostView,
) -> Result(defs.PostView, List(dynamic.DecodeError)) {
  case
    dynamic.element(9, dynamic.string)(data),
    dynamic.element(10, dynamic.string)(data)
  {
    Ok(element9), Ok(element10) -> Ok(constructor(element9, element10))
    Error(e), _ | _, Error(e) -> Error(e)
  }
}

fn decode_scrobble_post(
  artist_name: String,
  album_cover_cid: option.Option(String),
  album_name: option.Option(String),
  track_name: String,
  created_at: Int,
) -> post.Post {
  post.Post(artist_name, album_cover_cid, album_name, track_name, created_at)
}
