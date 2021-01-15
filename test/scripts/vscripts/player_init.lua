function playerAndMonsterInit()
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
    math.randomseed(tonumber(timeTxt))
    playerStatus = {}
    for i =0,9 do
        playerStatus[i] = {}
        -- playerStatus[i]["steamid"] = Game.GetPlayerInfo(Players.GetLocalPlayer()).player_steamid
        playerStatus[i]["len"] = 0
    end

    createPet("niu")
	createPet("niu")
	createPet("niu")
	createPet("yang")
	createPet("yang")
	createPet("yang")
	createPet("yang")
	createPet("yang")
	createPet("huoren")
end

function Maps()
	local zuoshang = Entities:FindByName(nil, "zuoshang"):GetAbsOrigin()
	local youxia = Entities:FindByName(nil, "youxia"):GetAbsOrigin()
	local location = zuoshang - Vector(math.random()*(zuoshang.x-youxia.x),math.random()*(zuoshang.y-youxia.y),0)
	return location
end

function createPet(unitname)
	location = Maps()
	CreateUnitByName(unitname, location, true, nil, nil, DOTA_TEAM_BADGUYS)
end

function createzuoji(playerid)
    local followedUnit = playerStatus[playerid]["she"][playerStatus[playerid]["shePoint"]]
    local location = followedUnit:GetAbsOrigin()
	local chaoxiang = followedUnit:GetForwardVector()
    
    local newLocation = location - chaoxiang * 100
    local newUnit = CreateUnitByName("zuoji", newLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    newUnit:SetForwardVector(chaoxiang)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("follow"),
                                                function () 
                                                    newUnit:MoveToNPC(followedUnit)
                                                    return 0.5
                                                end, 0)
    playerStatus[playerid]["shePoint"] =playerStatus[playerid]["shePoint"] + 1
    playerStatus[playerid]["she"][playerStatus[playerid]["shePoint"]] = newUnit


end


