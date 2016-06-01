  get   'gamification' => 'gamification#index'
  get   'gamification/player/:id' => 'gamification#player'
  get   'gamification/leaderboards' => 'gamification#leaderboards'
  get   'gamification/actions' => 'gamification#actions'
  post  'gamification/actions/:id/play' => 'gamification#play_action'
  get   'gamification/configuration' => 'gamification#configuration'
  put   'gamification/configuration' => 'gamification#set_configuration'


