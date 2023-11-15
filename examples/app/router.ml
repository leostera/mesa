open Mesa
open Router
open Controllers

let router =
  scope "/"
    [
      resource "photo" (module Photo_controller);
      scope "user"
        [
          get "/" User_controller.index;
          post "/" User_controller.create;
          get "/:id" User_controller.get;
          post "/:id/update" User_controller.update;
          post "/:id/delete" User_controller.delete;
          post "/:id/resend_confirmation" User_controller.resend_confirmation;
        ];
    ]
