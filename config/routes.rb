Rails.application.routes.draw do
  # get 'articles/index'
  #
  # get 'articles/new'
  #
  # get 'articles/show'
  #
  # get 'articles/edit'


  resources :articles
  root 'articles#index'
  # get 'tags/:tag', to: 'articles#index', as: :tag
  get 'tags/:tag', to: 'articles#index', as: :tag, :constraints  => { :tag => /[^\/]+/ }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
