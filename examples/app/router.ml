open Mesa
open Router
open Controllers

let router =
  scope "/"
    [
      resource "/photos" (module Photo_controller);
      resource "/albums" (module Album_controller);
      resource "/likes" (module Like_controller);
      scope "/user"
        [
          get "/" User_controller.index;
          post "/" User_controller.create;
          get "/:id" User_controller.get;
          post "/:id/update" User_controller.update;
          post "/:id/delete" User_controller.delete;
          post "/:id/resend_confirmation" User_controller.resend_confirmation;
        ];
    ]
