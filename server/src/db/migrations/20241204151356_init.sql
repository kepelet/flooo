-- migrate:up
create table if not exists "club.flooo.scrobble" (
    id integer not null primary key autoincrement,
    uri text not null unique,
    cid text not null,
    author_did text not null,
    album_cover_cid text not null,
    album_name text not null,
    artist_name text not null,
    track_name text not null,
    created_at integer not null,
    indexed_at integer not null
);

create table if not exists "club.flooo.scrobbler" (
    id integer not null primary key autoincrement,
    did text not null unique,
    handler text not null,
    avatar text,
    banner text,
    display_name text,
    description text,
    created_at integer not null,
    indexed_at integer not null
);

-- migrate:down
drop table "club.flooo.scrobble";
drop table "club.flooo.scrobbler";
