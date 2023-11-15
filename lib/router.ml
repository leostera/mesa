module Logger = Riot.Logger.Make (struct
  let namespace = [ "mesa"; "router" ]
end)

module type Resource = sig
  open Trail

  val create : Conn.t -> Conn.t
  val delete : Conn.t -> Conn.t
  val edit : Conn.t -> Conn.t
  val get : Conn.t -> Conn.t
  val index : Conn.t -> Conn.t
  val new_ : Conn.t -> Conn.t
  val update : Conn.t -> Conn.t
end

type t =
  | Scope of { name : string; routes : t list }
  | Route of { meth : Http.Method.t; path : string; handler : Trail.trail }

let scope name routes = Scope { name; routes }
let route meth path handler = Route { meth; path; handler }
let delete path handler = route `DELETE path handler
let get path handler = route `GET path handler
let head path handler = route `HEAD path handler
let patch path handler = route `PATCH path handler
let post path handler = route `POST path handler
let put path handler = route `PUT path handler

let resource name (module R : Resource) =
  scope name
    [
      get "/" R.index;
      get "/:id/edit" R.edit;
      get "/new" R.new_;
      post "/" R.create;
      patch "/:id" R.update;
      put "/:id" R.update;
      delete "/:id" R.delete;
    ]

module Route_compiler = struct
  exception Empty_router

  type t = Last of string * Trail.trail | Path of string * t
  type compiled = (Http.Method.t * t * string) list

  let rec compile_path path handler =
    match path with
    | [] -> raise Empty_router
    | [ path ] -> Last (path, handler)
    | [ path; "" ] -> Last (path, handler)
    | path :: rest -> Path (path, compile_path rest handler)

  let remove_trailing_slash s =
    let s =
      if String.starts_with ~prefix:"/" s then
        String.sub s 1 (String.length s - 1)
      else s
    in
    if String.ends_with ~suffix:"/" s then String.sub s 0 (String.length s - 2)
    else s

  let rec compile t last =
    match t with
    | Scope { name; routes } ->
        let name = remove_trailing_slash name in
        let prefix = name :: last in
        routes |> List.map (fun route -> compile route prefix) |> List.flatten
    | Route { meth; path; handler } ->
        let path = remove_trailing_slash path in
        let path = path :: last in
        [ (meth, compile_path path handler, String.concat "/" (List.rev path)) ]

  let compile t = compile t []

  let rec match_one route parts =
    match (route, parts) with
    | Last (pattern, handler), [ path ] ->
        Logger.trace (fun f -> f "Last -> %s ~= %s" pattern path);
        if String.equal pattern path then Some handler
        else (
          Logger.trace (fun f -> f "break");
          None)
    | Path (pattern, rest), path :: parts ->
        Logger.trace (fun f ->
            f "Path -> %s ~= %s -> %b" pattern path (String.equal pattern path));
        if String.equal pattern path then match_one rest parts
        else (
          Logger.trace (fun f -> f "break");
          None)
    | Last (pat, _), _ ->
        Logger.trace (fun f -> f "more last than route: %S" pat);
        None
    | Path (pat, _), _ ->
        Logger.trace (fun f -> f "more path than route: %S" pat);
        None

  let rec run_routes routes parts =
    match routes with
    | [] -> Error `Not_found
    | (route, stringy_route) :: routes -> (
        Logger.trace (fun f -> f "check route %s" stringy_route);
        match match_one route parts with
        | Some handler -> Ok handler
        | None -> run_routes routes parts)

  let try_match (t : compiled) meth parts =
    match
      List.filter_map
        (fun (m, r, s) -> if m = meth then Some (r, s) else None)
        t
    with
    | [] -> Error `Not_found
    | routes -> run_routes routes parts
end

let make (t : t) =
  let routes = Route_compiler.compile t in
  fun (conn : Trail.Conn.t) ->
    let parts = conn.path |> String.split_on_char '/' in
    match Route_compiler.try_match routes conn.meth parts with
    | Ok handler -> handler conn
    | Error _ ->
        (* TODO(@leostera): 404 handler *)
        assert false

module type Intf = sig
  val router : t
end
