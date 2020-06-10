fx_version 'adamant'
game 'gta5'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/sv.lua',
	'server.lua',
	'config.lua',
}

client_script {
'@es_extended/locale.lua',
'locales/sv.lua',
	'client.lua',
	'config.lua',
}