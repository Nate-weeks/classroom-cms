Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "sessions#create"
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'
  root to: 'assignments#index'

  resources :assignments do
    resources :studentworks do
    end
  end
end
