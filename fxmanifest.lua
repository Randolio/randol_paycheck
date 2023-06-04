fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Paycheck System'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'cl_paycheck.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_paycheck.lua'
}

lua54 'yes'
