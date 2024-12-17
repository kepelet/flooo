import gleam/option.{None, Some}
import gleam/result

import server/context
import server/errors
import server/services/did_doc
import server/utils

pub fn get_service_endpoint(
  ctx: context.Context,
  did: String,
) -> Result(String, errors.Error) {
  let cache_key = utils.cache_key("pds", did)

  case ctx.cache.get(cache_key) {
    Some(cached) -> Ok(cached)
    None -> {
      use pds <- result.try(did_doc.get_pds_from_did_doc(did))
      use hostname <- result.try(utils.get_hostname_from_uri(pds))

      ctx.cache.set(cache_key, hostname)
      Ok(hostname)
    }
  }
}
