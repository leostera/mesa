Riot.start
  ~apps:
    [
      (module Riot.Logger);
      (* the standard logger *)
      (module Application);
      (* our application *)
    ]
  ()
