type t = Element.t

let string s = Element.Leaf s
let list children = Element.Node { tag = ""; attr = []; children }
let div = Tag.create "div"
let hr = Tag.create "hr"
let a = Tag.create "a"
let span = Tag.create "span"

let to_string t =
  let buf = Buffer.create 1024 in
  let fmt = Format.formatter_of_buffer buf in
  let t = Element.to_tyxml t in
  Tyxml.Xml.pp ~indent:true () fmt t;
  Format.pp_force_newline fmt ();
  Format.fprintf fmt "%!";
  let str = Buffer.contents buf in
  Bigstringaf.of_string ~off:0 ~len:(String.length str) str
