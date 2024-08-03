fx_version 'cerulean'
game 'gta5'

author 'PlexScripts'
description 'PS_Lottery'
version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'



client_scripts {
'config.lua',
'locales/*',
'client/client.lua',
'client/client_target.lua',
'client/client_functions.lua',

}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/server.lua',
    'server/server_functions.lua',
    'locales/*',
    
}


escrow_ignore {
    'config.lua',
    'locales/*',
    'client/client_target.lua',
    'client/client_functions.lua',
    'server/server_functions.lua',
}
