type ast = Text of Bitstring.t | Code of Bitstring.t

let until char data =
  let char_len = String.length char in
  let rec go char data len =
    print_endline ("data: " ^ Bitstring.string_of_bitstring data);
    match%bitstring data with
    | {| _ |} as rest when Bitstring.bitstring_length rest < char_len ->
        (Bitstring.bitstring_length data, Bitstring.empty_bitstring)
    | {| curr : (char_len)*8 : string; rest : -1 : bitstring |}
      when String.equal curr char ->
        (len, rest)
    | {| _curr : 8 : string; rest : -1 : bitstring |} -> go char rest (len + 1)
  in
  let len, rest = go char data 0 in
  let captured = Bitstring.subbitstring data 0 (len * 8) in
  (captured, rest)

let rec parse data =
  if Bitstring.bitstring_length data = 0 then [] else parse_text data

and parse_text data =
  let text, rest = until "<%" data in
  print_endline ("text: " ^ Bitstring.string_of_bitstring text);
  Text text :: parse_code rest

and parse_code data =
  let code, rest = until "%>" data in
  print_endline ("code: " ^ Bitstring.string_of_bitstring code);
  Code code :: parse rest

let from_src ~src =
  let buf = Lexing.from_string src in
  match Parser.use_file Lexer.token buf with
  | exception e ->
      Printf.eprintf "Found an error in line:\n%s"
        (Bytes.to_string buf.lex_buffer);
      Printf.eprintf "%*s %s" buf.lex_curr_pos "^" (Printexc.to_string e);
      Error e
  | ast -> Ok ast

let from_in_channel ch = parse (Bitstring.bitstring_of_chan ch)

let pp_ast fmt t =
  match t with
  | Text text ->
      Format.fprintf fmt "\"%s\"" (Bitstring.string_of_bitstring text)
  | Code code -> Format.fprintf fmt "%s" (Bitstring.string_of_bitstring code)

let pp fmt phrases =
  Format.fprintf fmt "(* generated with mlx: do not edit! *)";
  Format.pp_force_newline fmt ();
  Format.pp_print_list
    ~pp_sep:(fun fmt _ -> Format.fprintf fmt " ^ ")
    (fun fmt phrase -> Format.fprintf fmt "%a" pp_ast phrase)
    fmt phrases;
  Format.pp_force_newline fmt ()
