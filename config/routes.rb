Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  resources :users, only: %i[index show edit update destroy] do
    collection do
      post :import
    end
    member do
      get  :edit_basic_info
      patch :update_basic_info
      get :export_csv
    end
    resources :attendances, only: [:update]
  end
  resources :base_points, only: %i[index new create edit update destroy]
  resources :monthly_approval_applications, only: [:create] do
    collection do
      patch :bulk_update
    end
  end
  resources :overtime_applications, only: [:create] do
    collection do
      patch :bulk_update
    end
  end
  resources :attendance_change_applications, only: [] do
    collection do
      patch :bulk_update
    end
  end
  get "user_attendance_index", to: "users#user_attendance_index"
  root to: "home#index"
end
