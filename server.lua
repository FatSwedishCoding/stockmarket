local ESX = nil
-- ESX
local sid = 0
local smangd = 0
local ppmangd = 0
local spris = 0
-- Config saker --
-- Syntheria total aktier
stotalaaktier = 400000 -- höj/sänk denna för att sätta max aktier.
-- Päron och Äpple total aktier
ptotalaaktier = 20000 -- höj/sänk denna för att sätta max aktier.
--CONFIG END
--END---
local ssidentifier = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- kollar tiden om börsen är uppe.
ESX.RegisterServerCallback('esx_aktier:kollatid', function(source,cb)
local xPlayer    = ESX.GetPlayerFromId(source)
local date = os.date('*t')

	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
	
	-- --[[
if (date.hour >= 16) and (date.hour <= 24) or (date.hour >= 00) and (date.hour <= 9) then -- Slut till
cb(true)
return
else
TriggerClientEvent('esx:showNotification', source, 'ColoursNet Börsen är öppet mellan 16:00pm - 2:00am')
cb(false)
return
end
end)

RegisterServerEvent("esx_aktier:flyttapengar")
AddEventHandler("esx_aktier:flyttapengar", function()
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
local identifier = GetPlayerIdentifiers(_source)[1]

local result = MySQL.Sync.fetchScalar("SELECT bank FROM aktiebank WHERE identifier = @identifier", {['@identifier'] = identifier})
if not result or result == 0 then
TriggerClientEvent('esx:showNotification', _source, 'Du har inga pengar på ditt aktiekonto.')
return
end
MySQL.Async.execute("UPDATE aktiebank SET bank =@carthiefv2 WHERE identifier=@identifier", {['@identifier'] = identifier, ['@carthiefv2'] = 0})
xPlayer.addAccountMoney('bank', tonumber(result))
TriggerClientEvent('bank:result', _source, "success", "Du flyttade " .. result .. '/kr till ditt bank Konto.' )
return
end)

RegisterServerEvent("esx_aktier:tbxaktier")
AddEventHandler("esx_aktier:tbxaktier", function()
end)

RegisterServerEvent("esx_aktier:kopaktier")
AddEventHandler("esx_aktier:kopaktier", function(pmangd, fnamn)
local _source = source
local xPlayer = ESX.GetPlayerFromId(source)

local identifier = GetPlayerIdentifiers(source)[1]
local result12 = MySQL.Sync.fetchAll("SELECT * FROM aktiesalj WHERE mangd >= @mangd and foretag = @foretag and pris = (SELECT MIN(pris))", {
      ['@mangd'] = pmangd,
	  ['@foretag'] = fnamn
    })
	-- om error/ej hittar vad vi söker i databasen.
	if not result12 then
	TriggerClientEvent('esx:showNotification', _source, 'Finns ej ' .. pmangd .. '/st aktier för det nuvrande aktiepriset. testa att köpa aktier i omgångar. 1')
	return
	end
	-- om error/ej hittar vad vi söker i databasen.
	local user12 = result12[1]
	if user12 == nil then
	TriggerClientEvent('esx:showNotification', _source, 'Finns ej ' .. pmangd .. '/st aktier för det nuvrande aktiepriset. testa att köpa aktier i omgångar. 2')
	return
	end
	local id = user12['id']
	local sidentifier = user12['sidentifier']
	local mangd = user12['mangd']
    local pris = user12['pris']
	local saljarnamn = user12['saljarnamn']
	
    local data = {
	id = id,
	mangd  = mangd,
    pris   = pris,
	saljarnamn = saljarnamn
    }
	local realpris = pris * pmangd
	-- om säljare och köpare e samma person.
	if sidentifier == identifier then
	TriggerClientEvent('esx:showNotification', _source, 'Du kan inte köpa dina egna aktier för att höja den, ta på din försäljning om du vill köpa mer aktier.')	
	return
	end
	local pbank = xPlayer.getAccount('bank').money
	if pbank < realpris then
	TriggerClientEvent('esx:showNotification', _source, 'Du har inte råd att köpa ' .. pmangd .. '/st aktier för ' .. realpris .. 'kr')
return
end
TriggerClientEvent('esx_aktier:bekreftelse',_source, pmangd, realpris)
sid = id
smangd = mangd
ppmangd = pmangd
spris = realpris
ssidentifier = sidentifier
end)

RegisterServerEvent("esx_aktier:slutfor")
AddEventHandler("esx_aktier:slutfor", function(foretag)
local _source = source
local xPlayer = ESX.GetPlayerFromId(source)

local identifier = GetPlayerIdentifiers(source)[1]
TriggerClientEvent('esx:showNotification', _source, 'Du köpte ' .. ppmangd .. 'st/aktier för ' .. spris .. 'kr')

local result110 = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
      ['@identifier'] = identifier
    })

    local user      = result110[1]
    local firstname     = user['firstname']
    local lastname      = user['lastname']

    local data = {
      firstname   = firstname,
      lastname    = lastname
    }
	
local aname = firstname .. ' ' .. lastname
local tmangd = smangd - ppmangd
-- datbas kod för ändring av aktier. mangd = mängd från databasen / pmangd = spelarinput.
-- kollar och mängden i databasen = köpet.
if smangd == ppmangd then
MySQL.Async.execute('DELETE FROM aktiesalj WHERE sidentifier = @identifier and id = @sid',{["@identifier"] = ssidentifier,['@sid'] = sid})
else
-- tar bort aktier från aktiesälj i databasen.
MySQL.Async.execute("UPDATE aktiesalj SET mangd=@carthiefv2 WHERE sidentifier=@identifier and id = @sid", {['@identifier'] = ssidentifier,['@sid'] = sid, ['@carthiefv2'] = tmangd})
end
-- hämtar köparen's aktier.
local result = MySQL.Sync.fetchScalar("SELECT aktier FROM aktieagare WHERE identifier = @identifier and foretag = @foretag", {['@identifier'] = identifier, ['@foretag'] = foretag})
if not result then
--KÖPAREN
-- lägger in aktier på köparens aktiekonto om han inte har aktier tidigare.
MySQL.Sync.execute("INSERT INTO aktieagare (`identifier`, `namn`,`aktier`,`foretag` ) VALUES (@identifier, @namn, @aktier, @foretag)",{['@identifier'] = identifier, ['@namn'] = aname,['@aktier'] = ppmangd,['@foretag'] = foretag})
return
end
local amangd = result + ppmangd
-- Lägger in aktier på köparens aktiekonto om han han har aktiekonto.   
MySQL.Async.execute("UPDATE aktieagare SET aktier =@carthiefv2 WHERE identifier=@identifier and foretag = @foretag", {['@identifier'] = identifier, ['@carthiefv2'] = amangd, ['@foretag'] = foretag})
-- tar bort pengar från spelaren som köper.
xPlayer.removeAccountMoney('bank', spris)

-- SÄLJAREN Trigger
TriggerEvent('esx_aktier:setsbank')
end)
-- Sätter in pengar på Säljaren Aktiekonto.
RegisterServerEvent("esx_aktier:setsbank")
AddEventHandler("esx_aktier:setsbank", function()
-- Ägaren av aktier.
	local result = MySQL.Sync.fetchScalar("SELECT bank FROM aktiebank WHERE identifier = @identifier", {
      ['@identifier'] = ssidentifier
    })
-- om aktiekonto inte finns.
if not result then
MySQL.Sync.execute("INSERT INTO aktiebank (`identifier`, `bank` ) VALUES (@identifier, @bank)",{['@identifier'] = ssidentifier, ['@bank'] = spris})
sid = 0
smangd = 0
ppmangd = 0
spris = 0
ssidentifier = nil
return
end
-- Om aktiekonto finns.
-- räknar bank pengar.
local sbank = result + spris
-- lägger in pengarna på aktiekontot.
MySQL.Async.execute("UPDATE aktiebank SET bank =@carthiefv2 WHERE identifier=@identifier", {['@identifier'] = ssidentifier, ['@carthiefv2'] = sbank})
sid = 0
smangd = 0
ppmangd = 0
spris = 0
ssidentifier = nil
end)
-- function för sälj
RegisterServerEvent("esx_aktier:saljaktier")
AddEventHandler("esx_aktier:saljaktier", function(mangd,pris,foretag)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
local identifier = GetPlayerIdentifiers(_source)[1]

local result1 = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
      ['@identifier'] = identifier
    })

    local user      = result1[1]
    local firstname     = user['firstname']
    local lastname      = user['lastname']

    local data = {
      firstname   = firstname,
      lastname    = lastname
    }
local aname = firstname .. ' ' .. lastname
local ftitle = nil
if foretag == 'syntheria' then
ftitle = 'Syntheria Bank AB'
elseif foretag == 'paron' then
ftitle = 'Päron och Äpple AB'
end

	local result = MySQL.Sync.fetchScalar("SELECT aktier FROM aktieagare WHERE identifier = @identifier and foretag = @foretag", {['@identifier'] = identifier, ['@foretag'] = foretag})
	-- Om ej ägare av aktier
	if not result then
	TriggerClientEvent('esx:showNotification', _source, 'Du har inga aktier hos ' .. ftitle)
	-- Om ägare av aktier
	else
	-- fattas just nu mängd.
	if result < mangd then
	TriggerClientEvent('esx:showNotification', _source, 'Du har inte så mycket aktier.')
	return
	end
	local total = result - mangd
	TriggerClientEvent('esx:showNotification', _source, 'Du har lagt upp ' .. mangd ..  'st aktier ' .. 'för ' .. pris ..  'kr/st för försäljning.')
	MySQL.Sync.execute("INSERT INTO aktiesalj (`sidentifier`, `saljarnamn`,`mangd`,`pris`, `foretag` ) VALUES (@sidentifier, @saljarnamn,@mangd, @pris ,@foretag)",{['@sidentifier'] = identifier, ['@saljarnamn'] = aname,['@mangd'] = mangd,['@pris'] = pris ,['@foretag'] = foretag})
    MySQL.Async.execute("UPDATE aktieagare SET aktier =@carthiefv2 WHERE identifier=@identifier", {['@identifier'] = identifier, ['@carthiefv2'] = total})
	end
	ftitle = nil
end)
-- Kolla sina Aktier
RegisterServerEvent("esx_aktier:kollaaktier")
AddEventHandler("esx_aktier:kollaaktier", function(foretag)
local ftitle = nil
if foretag == 'syntheria' then
ftitle = 'Syntheria Bank AB'
totalaaktier = stotalaaktier
elseif foretag == 'paron' then
ftitle = 'Päron och Äpple AB'
totalaaktier = ptotalaaktier
end
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
local identifier = GetPlayerIdentifiers(_source)[1]
-- Kollar i databasen efter aktier.
	local result = MySQL.Sync.fetchScalar("SELECT aktier FROM aktieagare WHERE identifier = @identifier and foretag = @foretag", {['@identifier'] = identifier, ['@foretag'] = foretag})
	if not result or result == 0 then
	TriggerClientEvent('esx:showNotification', _source, 'Du har inga aktier.')
	else
	local procent = result / totalaaktier -- För att få ut det i decimal
	TriggerClientEvent('esx:showNotification', _source, 'Du äger ' .. result .. 'st aktier i ' .. ftitle)
	TriggerClientEvent('esx:showNotification', _source, 'Du äger ' .. procent * 100 .. '% aktier i ' .. ftitle) -- procent * 100 är för att få ut det i % och inte decimal.
    end
	ftitle = nil
end)

function sendNotification(xSource, message, messageType, messageTimeout)
TriggerClientEvent('mythic_notify:client:SendAlert', xSource, { 
text = message,
type = messageType,
queue = "qalle",
timeout = messageTimeout,
layout = "bottomCenter"
})
end