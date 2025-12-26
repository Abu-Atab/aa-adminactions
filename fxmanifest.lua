fx_version 'cerulean'
game 'gta5'
author '@abu.atb'
description 'Made By: Abu Atab DEV Team'
version '1.0.0'
lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'settings.lua',
  'aa_lang.lua'
}

server_scripts {
  'server/sv_logs.lua',
  'server/main.lua',
  'server/Updates.lua'
}

client_scripts {
  'client.lua'
}

dependencies {
  'qb-core',
  'ox_lib'
}
