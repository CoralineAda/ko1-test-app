Ko1TestApp::Application.routes.draw do
  devise_for :users
  resources :members
  resources :groups do
    resources :members
  end
  root :to => "home#index"
end
