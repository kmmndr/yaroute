Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'login'     => 'sessions#new'
  post 'login'    => 'sessions#create'
  get 'logout' => 'sessions#destroy'
  delete 'logout' => 'sessions#destroy'

  resources :games do
    resources :players, only: [:index]
    put 'next_question'
    put 'reset'
    get 'play'
  end
  resources :players do
    resources :answers, only: [:create]
  end
  resources :quizzes do
    resources :games, only: [:create]
  end

  # Defines the root path route ("/")
  # root "articles#index"
end
