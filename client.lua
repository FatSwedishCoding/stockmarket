local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

---esx
local ESX               = nil
local PlayerData    = {}
local fname = nil

-- Servern callback
RegisterNetEvent('jsfour-legitimation:open')
AddEventHandler('jsfour-legitimation:open', function(playerData)
    cardOpen = true
    SendNUIMessage({
        action = "open",
        array = playerData
    })
end)
-- ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)
-- TRIGGER FÖR TELEFONEN.
RegisterNetEvent('esx_aktier:starten')
AddEventHandler('esx_aktier:starten', function()
		ESX.TriggerServerCallback('esx_aktier:kollatid', function(cb)
		if cb == false then
		return
		else
		openMenu()	
		end
		end)
end)

--- meny för börsen.
function openMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'f3_menu',
        {
            title    = 'ColoursNet Börsen',
            align    = 'bottom-right',
            elements = {
                {label = 'Syntheria Bank AB', value = 'id-card'},
                {label = 'Äpple Och Päron', value = 'citizen'},
				{label = 'Flytta Pengarna från Aktiekonto till Banken', value = 'flyttapengar'},
            }
        },
        function(data, menu)
		-- FLYTTA PENGAR FRÅN AKTIEKONTO TILL BANKEN
		if data.current.value == 'flyttapengar' then
		TriggerServerEvent('esx_aktier:flyttapengar')
-- SYNTHERIA BANK AB		
            elseif data.current.value == 'id-card' then
			fname = 'syntheria'
                ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'id_card_menu',
                    {
                        title    = 'Syntheria Bank AB',
                        align    = 'bottom-right',
                        elements = {
                                            {label = 'Köp Aktier', value = 'kopaktier'},
                                            {label = 'Sälj Aktier', value = 'saljaktier'},
                                            {label = 'Kolla sina aktier', value = 'kollaaktier'},											
                        }
                    },

  function(data2, menu2)
-- Köp Aktier  
            if data2.current.value == 'kopaktier' then
			local elements = {}
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Hur många Aktier vill du köpa?'
			}, function (data2, menu2)
				local count = tonumber(data2.value)
				if count == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte köpa 0st aktier.')
				else
				TriggerServerEvent('esx_aktier:kopaktier', count, fname)
				menu2.close()
				menu.close()				
				end
			end, function (data2, menu2)
				menu2.close()
				menu.close()
			end)	
-- Sälj Aktier						
                        elseif data2.current.value == 'saljaktier' then
						
						local elements = {}
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Hur många Aktier vill du sälja?'
			}, function (data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte sälja 0st aktier.')
				else
					menu2.close()
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Vilket pris vill du sälja de för?'
			}, function (data2, menu2)
				local count1 = tonumber(data2.value)

				if count1 == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte sälja dina aktier för 0kr.')
				else
				TriggerServerEvent('esx_aktier:saljaktier',count ,count1 ,fname)
					menu2.close()
				end
			end, function (data2, menu2)
				menu2.close()
			end)
					
					
				end
			end, function (data2, menu2)
				menu2.close()
				menu.close()
			end)
			
			elseif data2.current.value == 'kollaaktier' then
			TriggerServerEvent('esx_aktier:kollaaktier', fname)							
                        end
                    end, function(data2, menu2)
                        menu2.close()
                    end)
				
-- PÄRON OCH ÄPPLE AB				
				elseif data.current.value == 'citizen' then
			fname = 'paron'
                ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'id_card_menu',
                    {
                        title    = 'Päron och Äpple AB',
                        align    = 'bottom-right',
                        elements = {
                                            {label = 'Köp Aktier', value = '1kopaktier'},
                                            {label = 'Sälj Aktier', value = '1saljaktier'},
                                            {label = 'Kolla sina aktier', value = '1kollaaktier'},										
                        }
                    },

  function(data2, menu2)
-- Köp Aktier  
            if data2.current.value == '1kopaktier' then
			local elements = {}
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Hur många Aktier vill du köpa?'
			}, function (data2, menu2)
				local count = tonumber(data2.value)
				if count == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte köpa 0st aktier.')
				else
				TriggerServerEvent('esx_aktier:kopaktier', count, fname)
				menu2.close()
				menu.close()				
				end
			end, function (data2, menu2)
				menu2.close()
				menu.close()
			end)	
-- Sälj Aktier						
                        elseif data2.current.value == '1saljaktier' then
						
						local elements = {}
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Hur många Aktier vill du sälja?'
			}, function (data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte sälja 0st aktier.')
				else
					menu2.close()
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Vilket pris vill du sälja de för?'
			}, function (data2, menu2)
				local count1 = tonumber(data2.value)

				if count1 == nil then
					TriggerEvent('esx:showNotification', 'Du kan inte sälja dina aktier för 0kr.')
				else
				TriggerServerEvent('esx_aktier:saljaktier',count ,count1 ,fname)
					menu2.close()
				end
			end, function (data2, menu2)
				menu2.close()
			end)
					
					
				end
			end, function (data2, menu2)
				menu2.close()
				menu.close()
			end)
-- Kolla sin Aktier
                               elseif data2.current.value == '1kollaaktier' then
			TriggerServerEvent('esx_aktier:kollaaktier', fname)							
                        end
                    end, function(data2, menu2)
                        menu2.close()
                    end)	
            elseif data.current.value == 'material' then
            end

        end,
        function(data, menu)
            menu.close()
        end
    )
end

RegisterNetEvent('esx_aktier:bekreftelse')
AddEventHandler('esx_aktier:bekreftelse', function(mangd, pris)
local elements = {}
ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Vill du köpa: ' .. mangd .. '/st Aktier för totalbelopp: ' .. pris .. 'kr' .. ', Tryck Bekräfta för att godkänna.'
			}, function (data2, menu2)
				TriggerServerEvent('esx_aktier:slutfor',fname)
				menu2.close()
				--menu.close()				
			end, function (data2, menu2)
				menu2.close()
				menu.close()
			end)
end)
-- notification
function sendNotification(message, messageType, messageTimeout)


    TriggerEvent("mythic_notify:client:SendAlert", {
       text = message,
       type = messageType,
        queue = "qalle",
        timeout = messageTimeout,
        layout = "bottomCenter"
    })
end

-- Key events
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlPressed(0, Keys['F7']) then
		ESX.TriggerServerCallback('esx_aktier:kollatid', function(cb)
		if cb == false then
		return
		else
		openMenu()	
		end
		end)
		end
    end
end)

function saljmeny()
		local elements = {}
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('amount')
			}, function (data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					TriggerEvent('esx:showNotification', 'Du försöker sälja ingenting')
				else
				TriggerEvent('esx:showNotification', 'Du säljer')
					menu2.close()
					menu.close()
					OpenGetStocksMenu()
				end
			end, function (data2, menu2)
				menu2.close()
			end)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function drawRct(x,y,width,height,r,g,b,a)
    DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end


