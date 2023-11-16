let () =
  let phrases = Mlx2.from_in_channel stdin in
  Mlx2.pp Format.std_formatter phrases
