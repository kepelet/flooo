import sqlight

import gleam/httpc
import gleam/json

pub type Error {
  FetchError(httpc.HttpError)
  DatabaseError(sqlight.Error)
  JsonError(json.DecodeError)
  RecordNotFound
  DidNotFound
  FeedNotFound
  ProfileNotFound
  UnknownDidMethods
  InvalidServiceEndpoint
  InvalidDidDoc
  InvalidRequest
  InvalidURI
  InvalidDid
  ProxyError
  ProxySourceNotImage
  ProxySourceNotFound
  UnhandledError
}
