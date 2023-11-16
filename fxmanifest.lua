fx_version 'cerulean'
game 'gta5'

description 'QBX_CityHall'
repository 'https://github.com/Qbox-project/qbx_cityhall'
version '1.0.0'

modules {
    'qbx_core:utils',
    'qbx_core:playerdata',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua'
}

server_script 'server/main.lua'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
