import wisp

import server/context
import server/errors
import server/response

import server/services/blob_proxy
import server/services/pds

pub fn proxy(
  _req: wisp.Request,
  ctx: context.Context,
  did: String,
  cid: String,
) -> wisp.Response {
  case pds.get_service_endpoint(ctx, did) {
    Ok(pds) ->
      case blob_proxy.get_blob(pds, did, cid) {
        Ok(blob) -> blob
        Error(errors.ProxySourceNotFound) ->
          response.handle_error(
            errors.ProxySourceNotFound,
            "source image is unrachable",
          )
        Error(err) -> response.handle_error(err, "source is not image")
      }
    Error(err) -> response.handle_error(err, "can't reach PDS")
  }
}
