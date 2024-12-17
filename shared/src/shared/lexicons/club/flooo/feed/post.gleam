import gleam/option.{type Option}

pub type Post {
  Post(
    artist_name: String,
    album_cover: Option(String),
    album_name: Option(String),
    track_name: String,
    created_at: Int,
  )
}
