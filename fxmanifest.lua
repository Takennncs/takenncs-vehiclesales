fx_version 'cerulean'
game 'gta5'

author 'takenncs'
description 'Takenncs Vehicle Sales Contracts System'

ui_page 'web/offer.html'

files {
    'web/offer.html',
    'web/style.css',
    'web/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'

escrow_ignore {
    'config.lua',
    'client.lua',
    'server.lua'
}