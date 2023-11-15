open Riot
module Router = Router

let router (module R : Router.Intf) = Router.make R.router

module Endpoint = struct
  type config = { port : int }

  module type Intf = sig
    val endpoint : Trail.t
  end

  let start_link config (module E : Intf) =
    Logger.info (fun f ->
        f "Starting Mesa server at http://0.0.0.0:%d" config.port);
    Trail.start_link ~port:config.port E.endpoint
end
