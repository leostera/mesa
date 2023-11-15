open Trail

let endpoint =
  [
    logger { level = Info };
    request_id { kind = Uuid_v4 };
    (* more trails here *)
    Mesa.router (module Router);
  ]
