open Riot
open Trail

let endpoint =
  [
    logger { level = Info };
    request_id { kind = Uuid_v4 };
    (* more trails here *)
    Mesa.router (module Router);
  ]

let start_link config = Mesa.Endpoint.start_link config endpoint
let child_spec config = Supervisor.child_spec ~start_link config
