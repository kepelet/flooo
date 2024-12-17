CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE IF NOT EXISTS "club.flooo.scrobble" (
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
CREATE TABLE IF NOT EXISTS "club.flooo.scrobbler" (
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
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20241204151356');
