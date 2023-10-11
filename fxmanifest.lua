fx_version 'cerulean'
game 'gta5'

description 'QBX-CityHall'
repository 'https://github.com/Qbox-project/qbx_cityhall'
version '3.0.0'

modules {
    'qbx_core:utils',
    'qbx_core:playerdata',
}

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    '@qbx_core/import.lua',
}

server_script 'server/main.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/main.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'
