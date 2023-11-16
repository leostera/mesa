module Logger = Logger
module Controller = Controller
module Router = Router

let router (module R : Router.Intf) = Router.make R.router

module Endpoint = struct
  type config = { port : int }

  let start_link config endpoint =
    let open Riot in
    Logger.info (fun f ->
        f "Starting Mesa server at http://0.0.0.0:%d" config.port);
    Trail.start_link ~port:config.port endpoint
end

module Html = Mlx.Html
