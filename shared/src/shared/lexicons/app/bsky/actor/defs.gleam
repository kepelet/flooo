import gleam/option.{type Option}

import shared/lexicons/lexicons.{type Todo}

// app.bsky.feed.actor.defs#profileViewBasic
pub type ProfileViewBasic {
  ProfileViewBasic(
    did: String,
    handle: String,
    display_name: Option(String),
    avatar: Option(String),
    associated: Option(ProfileAssociated),
    viewer: Option(Todo),
    labels: Option(List(Todo)),
    created_at: Option(String),
  )
}

// app.bsky.feed.actor.defs#profileViewDetailed
pub type ProfileViewDetailed {
  ProfileViewDetailed(
    did: String,
    handle: String,
    display_name: Option(String),
    description: Option(String),
    avatar: Option(String),
    banner: Option(String),
    followers_count: Option(Int),
    follows_count: Option(Int),
    posts_count: Option(Int),
    associated: Option(ProfileAssociated),
    joined_via_starter_pack: Option(Todo),
    indexed_at: Option(String),
    created_at: Option(String),
    viewer: Option(Todo),
    labels: Option(List(Todo)),
    pinned_post: Option(Todo),
  )
}

// app.bsky.feed.actor.defs#profileAssociated
pub type ProfileAssociated {
  ProfileAssociated(
    lists: Option(Int),
    feedgens: Option(Int),
    starter_packs: Option(Int),
    labeler: Option(Bool),
    chat: Option(ProfileAssociatedChat),
  )
}

// app.bsky.feed.actor.defs#profileAssociatedChat
pub type ProfileAssociatedChat {
  ProfileAssociatedChat(allow_incoming: String)
}
