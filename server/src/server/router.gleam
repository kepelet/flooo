import wisp

import server/context
import server/response

import server/routes/blob
import server/routes/xrpc

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)

  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}

pub fn handle_request(req: wisp.Request, ctx: context.Context) -> wisp.Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    [] -> response.home()

    ["healthcheck"] -> response.healthcheck()
    ["blob", did, cid] -> blob.proxy(req, ctx, did, cid)
    ["xrpc", ..] -> xrpc.router(req, ctx, wisp.path_segments(req))

    blud_is_lost -> response.not_found(blud_is_lost)
  }
}
