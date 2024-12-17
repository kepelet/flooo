import gleam/string

import server/errors

pub fn cache_key(namespace: String, key: String) {
  namespace <> ":" <> key
}

pub fn get_hostname_from_did(did: String) {
  case string.split(did, ":") {
    [_, _, hostname] -> Ok(hostname)
    _ -> Error(errors.InvalidDid)
  }
}

pub fn get_did_from_uri(uri: String) -> Result(String, errors.Error) {
  case string.split(uri, "/") {
    [_, __, did, _, _] -> validate_did(did)
    _ -> Error(errors.InvalidURI)
  }
}

pub fn get_hostname_from_uri(uri: String) -> Result(String, errors.Error) {
  case string.split(uri, "/") {
    [_, _, hostname] -> Ok(hostname)
    _ -> Error(errors.InvalidURI)
  }
}

pub fn validate_did(did: String) -> Result(String, errors.Error) {
  case string.split(did, ":") {
    ["did", "web", _] -> Ok(did)
    ["did", "plc", _] -> Ok(did)
    _ -> Error(errors.InvalidDid)
  }
}
