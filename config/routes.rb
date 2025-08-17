Rails.application.routes.draw do
  # Employee routes with slugs
  resources :employees, only: [:show], param: :slug
  
  # Secret Santa routes
  get "secret_santa/index"
  get "secret_santa/create_assignments"  # GET route for better UX
  post "secret_santa/create_assignments"
  get "secret_santa/upload_csv"
  post "secret_santa/upload_csv"
  get "secret_santa/download_csv"
  get "secret_santa/download_sample_employee_csv"
  get "secret_santa/download_sample_previous_assignments_csv"
  
  # Set root to Secret Santa index
  root "secret_santa#index"
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
