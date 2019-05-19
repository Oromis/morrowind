Rails.application.routes.draw do

  get 'password_resets/new'
  get 'password_resets/edit'

  get 'sessions/new'

  root              'static_pages#home'
  get 'contact' =>  'static_pages#contact'
  get 'signup' =>   'users#new'

  resources :users do
    resources :characters
  end
  resources :characters, only: [:show, :update, :destroy] do
    put 'skill' => 'characters#skill', on: :member
    put 'items' => 'characters#items', on: :member
    put 'slot' => 'characters#slot_changed', on: :member
    put 'spell' => 'characters#spell', on: :member
    post 'level_up' => 'characters#level_up', on: :member
    get 'export' => 'characters#export', on: :member
    post 'clone' => 'characters#clone', on: :member
  end
  get 'characters' => 'characters#all_index'

  resources :rule_sets do
    resources :races do
      get 'modifiers' => 'races#modifiers', on: :member
      get 'abilities' => 'races#abilities', on: :member
    end
    resources :birthsigns do
      get 'modifiers' => 'birthsigns#modifiers', on: :member
    end
    resources :specializations
    resources :attributes, except: [:show]
    resources :skills, except: [:show]
    resources :resistances, except: [:show]
    resources :item_prototypes, except: [:show] do
      collection { post :import }
    end
    resources :spells, except: [:show]
    get 'spells/:school' => 'spells#school_index'
    get 'properties' => 'rule_sets#properties', on: :member
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]

  get 'login' =>    'sessions#new'
  post 'login' =>   'sessions#create'
  get 'logout' => 'sessions#destroy'
  post 'auth' => 'sessions#auth'
  post 'verify' => 'sessions#verify'

  get 'templates/property_modifier_config' => 'static_pages#property_modifier_config'
  get 'templates/ability_config' => 'static_pages#ability_config'
  get 'templates/charsheet_item' => 'static_pages#charsheet_item'
  get 'templates/char_equip_slot' => 'static_pages#char_equip_slot'
end
