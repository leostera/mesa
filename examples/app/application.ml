open Riot

let name = "Test_application"

let start () =
  let child_specs = [
    App_web.Endpoint.child_spec { port = 2112 };
  ] in
  Supervisor.start_link ~child_specs ()
