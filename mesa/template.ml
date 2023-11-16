module type Intf = sig
  type args

  val render : args -> Mlx.Html.t
end
