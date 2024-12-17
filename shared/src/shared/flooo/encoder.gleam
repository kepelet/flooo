import gleam/json

import shared/lexicons/club/flooo/feed/defs

pub fn post_view_json(scrobble: defs.PostView) -> json.Json {
  json.object([
    #(
      "post",
      json.object([
        #("uri", json.string(scrobble.uri)),
        #("cid", json.string(scrobble.cid)),
        #(
          "author",
          json.object([
            #("did", json.string(scrobble.author.did)),
            #("handle", json.string(scrobble.author.handle)),
          ]),
        ),
        #(
          "record",
          json.object([
            #("$type", json.string("club.flooo.scrobble")),
            #("artist_name", json.string(scrobble.record.artist_name)),
            #(
              "album_cover",
              json.nullable(scrobble.record.album_cover, of: json.string),
            ),
            #(
              "album_name",
              json.nullable(scrobble.record.album_name, of: json.string),
            ),
            #("track_name", json.string(scrobble.record.track_name)),
            #("created_at", json.int(scrobble.record.created_at)),
          ]),
        ),
        #("indexed_at", json.int(scrobble.indexed_at)),
      ]),
    ),
  ])
}

pub fn profile_view_json(profile: defs.PostAuthor) -> json.Json {
  json.object([
    #("did", json.string(profile.did)),
    #("handle", json.string(profile.handle)),
    #("display_name", json.nullable(profile.display_name, of: json.string)),
    #("avatar", json.nullable(profile.avatar, of: json.string)),
    #("banner", json.nullable(profile.banner, of: json.string)),
  ])
}
