Rails.application.routes.draw do
  get "card/:set/:id" => "card#show"
  get "card" => "card#index"
  get "set/:id" => "set#show"
  get "set" => "set#index"
  get "help/syntax" => "help#syntax"
  get "help/rules" => "help#rules"
  get "help/contact" => "help#contact"
  get "advanced" => "card#advanced"
  get "/" => "card#index"
end
