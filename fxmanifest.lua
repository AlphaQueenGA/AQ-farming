-- fxmanifest.lua
fx_version 'cerulean'
games { 'gta5' }

name 'AQ-Farming'
author 'AlphaQueen'
description 'QBCore Farming Resource using ox_lib and qb-inventory.'
version '1.0.0'

dependencies {
    'qb-core',
    'ox_lib',
    'qb-inventory',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'config/config.lua',
    'config/animals.lua',
    'config/locations/*.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@qb-core/shared/locale.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}