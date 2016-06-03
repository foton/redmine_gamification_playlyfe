  get   'gamification' => 'gamification#index'
  get   'gamification/my_scores' => 'gamification#my_scores'
  get   'gamification/player/:player_id' => 'gamification#player'
  get   'gamification/leaderboards' => 'gamification#leaderboards'
  get   'gamification/actions' => 'gamification#actions'
  post  'gamification/actions/:action_id/play' => 'gamification#play_action'
  get   'gamification/configuration' => 'gamification#configuration'
  put   'gamification/configuration' => 'gamification#set_configuration'


