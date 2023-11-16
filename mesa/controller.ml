module Conn = Trail.Conn

let text conn body = Conn.send_response ~status:`OK ~body conn

let render (type args) conn (module T : Template.Intf with type args = args)
    (args : args) =
  let start_render = Ptime_clock.now () in
  let body = T.render args |> Mlx.Html.to_string in
  let end_render = Ptime_clock.now () in
  Logger.trace (fun f ->
      f "rendered body in %a" Ptime.Span.pp (Ptime.diff end_render start_render));
  conn |> Conn.with_body body |> Conn.send
