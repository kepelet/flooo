import gleam/option.{type Option}

import shared/lexicons/club/flooo/feed/post

pub type PostAuthor {
  PostAuthor(
    did: String,
    handle: String,
    display_name: Option(String),
    avatar: Option(String),
    banner: Option(String),
  )
}

pub type PostView {
  PostView(
    uri: String,
    cid: String,
    author: PostAuthor,
    record: post.Post,
    indexed_at: Int,
  )
}
