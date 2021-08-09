--[[ Not Needed But Lets Keep it just incase the api is not being called
QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end) -- Just to reinforce the API if it ever becomes nil
]]
local function checkExistenceClothes(cid, cb)
    exports['ghmattimysql']:execute("SELECT cid FROM character_current WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

local function checkExistenceFace(cid, cb)
    exports['ghmattimysql']:execute("SELECT cid FROM character_face WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

RegisterServerEvent("mhrp_charCreation:insert_character_current")
AddEventHandler("mhrp_charCreation:insert_character_current",function(data)
    if not data then return end
    local src = source
    local user = QBCore.Functions.GetPlayer(source)
    local characterId = user.PlayerData.citizenid
    if not characterId then return end
    checkExistenceClothes(characterId, function(exists)
        local values = {
            ["cid"] = characterId,
            ["model"] = json.encode(data.model),
            ["drawables"] = json.encode(data.drawables),
            ["props"] = json.encode(data.props),
            ["drawtextures"] = json.encode(data.drawtextures),
            ["proptextures"] = json.encode(data.proptextures),
        }

        if not exists then
            local cols = "cid, model, drawables, props, drawtextures, proptextures"
            local vals = "@cid, @model, @drawables, @props, @drawtextures, @proptextures"

            exports['ghmattimysql']:execute("INSERT INTO character_current ("..cols..") VALUES ("..vals..")", values, function()
            end)
            return
        end

        local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
        exports['ghmattimysql']:execute("UPDATE character_current SET "..set.." WHERE cid = @cid", values)
    end)
end)


RegisterServerEvent("mhrp_charCreation:insert_character_face")
AddEventHandler("mhrp_charCreation:insert_character_face",function(data)
    if not data then return end
    local src = source

    print('[MHRP] - INSERT FACE : SERVER : CALLED', src)

    local user = QBCore.Functions.GetPlayer(src)
    local characterId = user.PlayerData.citizenid

    print('[MHRP] - INSERT FACE : SERVER : Got CID', characterId)

    if not characterId then return end

    print('[MHRP] - INSERT FACE : SERVER : Proceeded', characterId)

    checkExistenceFace(characterId, function(exists)
        local values = {
            ["cid"] = characterId,
            ["hairColor"] = json.encode(data.hairColor),
            ["headBlend"] = json.encode(data.headBlend),
            ["headOverlay"] = json.encode(data.headOverlay),
            ["headStructure"] = json.encode(data.headStructure),
        }
        local set = "hairColor = @hairColor,headBlend = @headBlend, headOverlay = @headOverlay,headStructure = @headStructure"
        if exists then 
            print('[MHRP] - INSERT FACE : SERVER : Updated Face', characterId)
            exports['ghmattimysql']:execute("UPDATE character_face SET "..set.." WHERE cid = @cid", values )
        else
            print('[MHRP] - INSERT FACE : SERVER : Created New Face', characterId)
            exports['ghmattimysql']:execute("INSERT INTO character_face (cid, hairColor, headBlend, headOverlay, headStructure) VALUES (@cid, @hairColor, @headBlend, @headOverlay, @headStructure)", {
                ["cid"] = characterId,
                ["hairColor"] = json.encode(data.hairColor),
                ["headBlend"] = json.encode(data.headBlend),
                ["headOverlay"] = json.encode(data.headOverlay),
                ["headStructure"] = json.encode(data.headStructure)
            })

        end
    end)
end)

RegisterServerEvent("mhrp_charCreation:get_character_face")
AddEventHandler("mhrp_charCreation:get_character_face",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local user = QBCore.Functions.GetPlayer(src)
    local characterId = user.PlayerData.citizenid

    if not characterId then return end

    exports['ghmattimysql']:execute("SELECT cc.model, cf.hairColor, cf.headBlend, cf.headOverlay, cf.headStructure FROM character_face cf INNER JOIN character_current cc on cc.cid = cf.cid WHERE cf.cid = @cid", {['cid'] = characterId}, function(result)
        if (result ~= nil and result[1] ~= nil) then
            local temp_data = {
                hairColor = json.decode(result[1].hairColor),
                headBlend = json.decode(result[1].headBlend),
                headOverlay = json.decode(result[1].headOverlay),
                headStructure = json.decode(result[1].headStructure),
            }
            local model = tonumber(result[1].model)
            if model == 1885233650 or model == -1667301416 then
                TriggerClientEvent("mhrp_charCreation:setpedfeatures", src, temp_data)
            end
        end
	end)
end)

RegisterServerEvent("mhrp_charCreation:get_character_current")
AddEventHandler("mhrp_charCreation:get_character_current",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local user = QBCore.Functions.GetPlayer(src)
    local characterId = user.PlayerData.citizenid

    if not characterId then return end

    exports['ghmattimysql']:execute("SELECT * FROM character_current WHERE cid = @cid", {['cid'] = characterId}, function(result)
        local temp_data = {
            model = result[1].model,
            drawables = json.decode(result[1].drawables),
            props = json.decode(result[1].props),
            drawtextures = json.decode(result[1].drawtextures),
            proptextures = json.decode(result[1].proptextures),
        }
        TriggerClientEvent("mhrp_charCreation:setclothes", src, temp_data,0)
	end)
end)

RegisterServerEvent("mhrp_charCreation:retrieve_tats")
AddEventHandler("mhrp_charCreation:retrieve_tats", function(pSrc)
    local src = (not pSrc and source or pSrc)
	local user = QBCore.Functions.GetPlayer(src)
    local char = user.PlayerData.citizenid
	exports['ghmattimysql']:execute("SELECT * FROM playersTattoos WHERE identifier = @identifier", {['identifier'] = user.PlayerData.citizenid}, function(result)
        if(#result == 1) then
			TriggerClientEvent("mhrp_charCreation:settattoos", src, json.decode(result[1].tattoos))
		else
			local tattooValue = "{}"
			exports['ghmattimysql']:execute("INSERT INTO playersTattoos (identifier, tattoos) VALUES (@identifier, @tattoo)", {['identifier'] = user.PlayerData.citizenid, ['tattoo'] = tattooValue})
			TriggerClientEvent("mhrp_charCreation:settattoos", src, {})
		end
	end)
end)

RegisterServerEvent("mhrp_charCreation:set_tats")
AddEventHandler("mhrp_charCreation:set_tats", function(tattoosList)
	local src = source
	local user = QBCore.Functions.GetPlayer(source)
    local char = user.PlayerData.citizenid
	exports['ghmattimysql']:execute("UPDATE playersTattoos SET tattoos = @tattoos WHERE identifier = @identifier", {['tattoos'] = json.encode(tattoosList), ['identifier'] = user.PlayerData.citizenid})
end)


RegisterServerEvent("mhrp_charCreation:get_outfit")
AddEventHandler("mhrp_charCreation:get_outfit",function(slot)
    if not slot then return end
    local src = source

    local user = QBCore.Functions.GetPlayer(source)
    local characterId = user.PlayerData.citizenid

    if not characterId then return end

    exports['ghmattimysql']:execute("SELECT * FROM character_outfits WHERE cid = @cid and slot = @slot", {
        ['cid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            if result[1].model == nil then
                TriggerClientEvent("notification", src, "Can not use.",2)
                return
            end

            local data = {
                model = result[1].model,
                drawables = json.decode(result[1].drawables),
                props = json.decode(result[1].props),
                drawtextures = json.decode(result[1].drawtextures),
                proptextures = json.decode(result[1].proptextures),
                hairColor = json.decode(result[1].hairColor)
            }

            TriggerClientEvent("mhrp_charCreation:setclothes", src, data,0)

            local values = {
                ["cid"] = characterId,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
            }

            local set = "model = @model, drawables = @drawables, props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
            exports['ghmattimysql']:execute("UPDATE character_current SET "..set.." WHERE cid = @cid",values)
        else
            TriggerClientEvent("notification", src, "No outfit on slot " .. slot,2)
            return
        end
	end)
end)

RegisterServerEvent("mhrp_charCreation:set_outfit")
AddEventHandler("mhrp_charCreation:set_outfit",function(slot, name, data)
    if not slot then return end
    local src = source

    local user = QBCore.Functions.GetPlayer(source)
    local characterId = user.PlayerData.citizenid

    if not characterId then return end

    exports['ghmattimysql']:execute("SELECT slot FROM character_outfits WHERE cid = @cid and slot = @slot", {
        ['cid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            local values = {
                ["cid"] = characterId,
                ["slot"] = slot,
                ["name"] = name,
                ["model"] = json.encode(data.model),
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor),
            }

            local set = "model = @model,name = @name,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures,hairColor = @hairColor"
            exports['ghmattimysql']:execute("UPDATE character_outfits SET "..set.." WHERE cid = @cid and slot = @slot",values)
        else
            local cols = "cid, model, name, slot, drawables, props, drawtextures, proptextures, hairColor"
            local vals = "@cid, @model, @name, @slot, @drawables, @props, @drawtextures, @proptextures, @hairColor"

            local values = {
                ["cid"] = characterId,
                ["name"] = name,
                ["slot"] = slot,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor)
            }

            exports['ghmattimysql']:execute("INSERT INTO character_outfits ("..cols..") VALUES ("..vals..")", values, function()
                TriggerClientEvent("notification", src, name .. " stored in slot " .. slot,1)
            end)
        end
	end)
end)


RegisterServerEvent("mhrp_charCreation:remove_outfit")
AddEventHandler("mhrp_charCreation:remove_outfit",function(slot)

    local src = source
    local user = QBCore.Functions.GetPlayer(source)
    local cid = user.PlayerData.citizenid
    local slot = slot

    if not cid then return end

    exports['ghmattimysql']:execute( "DELETE FROM character_outfits WHERE cid = @cid AND slot = @slot", { ['cid'] = cid,  ["slot"] = slot } )
    TriggerClientEvent("notification", src,"Removed slot " .. slot .. ".",1)
end)

RegisterServerEvent("mhrp_charCreation:list_outfits")
AddEventHandler("mhrp_charCreation:list_outfits",function()
    local src = source
    local user = QBCore.Functions.GetPlayer(source)
    local cid = user.PlayerData.citizenid
    local slot = slot
    local name = name

    if not cid then return end

    exports['ghmattimysql']:execute("SELECT slot, name FROM character_outfits WHERE cid = @cid", {['cid'] = cid}, function(skincheck)
    	TriggerClientEvent("hotel:list",src, skincheck)
	end)
end)

RegisterServerEvent("clothing:checkMoney")
AddEventHandler("clothing:checkMoney", function(menu,askingPrice)
    
    local src = source
	local xPlayer = QBCore.Functions.GetPlayer(source)

    TriggerClientEvent("mhrp_charCreation:hasEnough",src,menu)

    

    --[[ -- Not Yet
    if xPlayer.PlayerData.cash.money >= 0 then
        xPlayer.Functions.RemoveMoney('cash',0)
        TriggerClientEvent('notification', source, 'You paid $0' )
  
        TriggerClientEvent("mhrp_charCreation:hasEnough",src,menu)
    else

        TriggerClientEvent('notification', source, 'You dont have enough money' )
     
    end
    ]]
end)
