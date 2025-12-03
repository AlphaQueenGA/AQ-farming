fx_version 'cerulean'
game 'gta5'

lua54 'yes'

dependencies {
  'ox_lib',
  'qb-inventory'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config/main_config.lua',
  'config/locations/*.lua',
  'config/animal_config.lua',
  'config/locations/init.lua'
}

client_scripts {
  'client/init.lua',
  'client/locations.lua',
  'client/props.lua',
  'client/collection.lua',
  'client/animals.lua',
  'client/store.lua',
  'client/*.lua'
}

server_scripts {
  'server/init.lua',
  'server/sync.lua',
  'server/inventory.lua',
  'server/sales.lua',
  'server/*.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}