Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope :lottery do
    resources :tickets, only: %i[create index], controller: :lottery_tickets
    resources :draws, only: :create, controller: :lottery_draws
  end
end
