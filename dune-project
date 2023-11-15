(lang dune 3.10)

(name mesa)

(generate_opam_files true)

(source
 (github leostera/mesa))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(package
 (name mesa)
 (synopsis "")
 (description "")
 (depends
   (ocaml (>= "5.1"))
   dune
   (trail (>= "0.0.1"))
   (atacama (>= "0.0.1"))
   (riot (>= "0.0.1"))
   (telemetry (>= "0.0.1"))
 )
 (tags
  (topics multicore erlang actor "message-passing" processes)))
