open Riot

[@@@warning "-8"]

let main () =
  Logger.set_log_level (Some Info);
  Mesa.Router.Logger.set_log_level (Some Info);
  let (Ok _) = Logger.start () in
  sleep 0.1;
  let (Ok pid) = Mesa.Endpoint.start_link { port = 2112 } (module Endpoint) in
  wait_pids [ pid ]

let () = Riot.run @@ main
