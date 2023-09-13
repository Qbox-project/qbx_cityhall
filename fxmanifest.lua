fx_version 'cerulean'
game 'gta5'

description 'QB-CityHall'
version '3.0.0'

modules {
    'qbx-core:utils',
    'qbx-core:core',
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    '@qb-core/import.lua',
}

server_script 'server/main.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/main.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'