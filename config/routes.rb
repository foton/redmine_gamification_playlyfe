  get   'gamification' => 'gamification#index' 
  get   'gamification/my_scores' => 'gamification#my_scores'
  get   'gamification/player/:player_id' => 'gamification#player', as: :gamification_player
  get   'gamification/actions' => 'gamification#actions'
  post  'gamification/actions/:action_id/play' => 'gamification#play_action', as: :gamification_action_play
  get   'gamification/configuration' => 'gamification#configuration'
  put   'gamification/configuration' => 'gamification#configuration_update', as: :gamification_configuration_update
  #post  'gamification/configuration' => 'gamification#configuration_update'


