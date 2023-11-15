open Trail

let new_ req = req
let get req = req
let index req = req |> Conn.send_response ~status:`OK ~body:"here's your photos"
let edit req = req
let create req = req
let update req = req
let delete req = req
