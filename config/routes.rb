Rails.application.routes.draw do
  resources :merchants do
    resources :dashboards, only: [:index, :create]
    resources :items, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoices, only: [:index]
  end

  #get '/merchants/:id/items/:id', to: 'items#edit'
  resources :admin, only: [:index]
  namespace :admin do
    resources :invoices, only: [:index, :show]
    resources :merchants, only: [:index, :show, :edit, :update]
  end
end
