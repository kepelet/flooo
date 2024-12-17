import gleam/dynamic

import shared/lexicons/club/flooo/feed/defs
import shared/lexicons/club/flooo/feed/post

pub fn scrobble(
  data: dynamic.Dynamic,
) -> Result(post.Post, List(dynamic.DecodeError)) {
  dynamic.decode5(
    post.Post,
    dynamic.field("artist_name", dynamic.string),
    dynamic.field("album_cover", dynamic.optional(dynamic.string)),
    dynamic.field("album_name", dynamic.optional(dynamic.string)),
    dynamic.field("track_name", dynamic.string),
    dynamic.field("created_at", dynamic.int),
  )(data)
}

pub fn author(
  data: dynamic.Dynamic,
) -> Result(defs.PostAuthor, List(dynamic.DecodeError)) {
  dynamic.decode5(
    defs.PostAuthor,
    dynamic.field("did", dynamic.string),
    dynamic.field("handle", dynamic.string),
    dynamic.optional_field("display_name", dynamic.string),
    dynamic.optional_field("avatar", dynamic.string),
    dynamic.optional_field("banner", dynamic.string),
  )(data)
}

pub fn bsky(
  data: dynamic.Dynamic,
) -> Result(defs.PostAuthor, List(dynamic.DecodeError)) {
  dynamic.decode5(
    defs.PostAuthor,
    dynamic.field("did", dynamic.string),
    dynamic.field("handle", dynamic.string),
    dynamic.optional_field("displayName", dynamic.string),
    dynamic.optional_field("avatar", dynamic.string),
    dynamic.optional_field("banner", dynamic.string),
  )(data)
}

pub fn post(
  data: dynamic.Dynamic,
) -> Result(defs.PostView, List(dynamic.DecodeError)) {
  dynamic.decode5(
    defs.PostView,
    dynamic.field("uri", dynamic.string),
    dynamic.field("cid", dynamic.string),
    dynamic.field("author", author),
    dynamic.field("record", scrobble),
    dynamic.field("indexed_at", dynamic.int),
  )(data)
}

pub fn post_view(
  data: dynamic.Dynamic,
) -> Result(List(defs.PostView), List(dynamic.DecodeError)) {
  dynamic.field("feed", dynamic.list(dynamic.field("post", post)))(data)
}
