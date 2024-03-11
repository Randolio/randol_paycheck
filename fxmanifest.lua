fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Paycheck System'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'bridge/client/**.lua',
    'cl_paycheck.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/**.lua',
    'sv_paycheck.lua'
}

lua54 'yes'
