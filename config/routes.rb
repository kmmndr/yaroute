Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'login'     => 'sessions#new'
  post 'login'    => 'sessions#create'
  get 'logout' => 'sessions#destroy'
  delete 'logout' => 'sessions#destroy'

  resources :accounts

  resources :games do
    put 'next_question'
    put 'reset'
    get 'play'
  end
  resources :players do
    resources :answers, only: [:create]
  end

  resources :questions, only: [:edit, :update, :destroy] do
    member do
      put 'move_up'
      put 'move_down'
    end
  end
  resources :quizzes do
    resources :questions, only: [:new, :create]
    resources :games, only: [:create]
  end
  resources :responses, only: [:destroy] do
    member do
      put 'move_up'
      put 'move_down'
    end
  end

  mount Yaroute::API => '/'

  root to: redirect('/quizzes')
end
