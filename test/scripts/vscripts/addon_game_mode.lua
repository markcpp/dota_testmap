-- Generated from template

-- require("mob_spawner")
require("player_init")
--注册
if Worm == nil then
	Worm = class({})
end

GameRules.isInit = false
function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
    print("done loading shiping")
end

function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then 	
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end
end

--用于模型，特效，音效的预载入
function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	print("BEGIN TO PRECACHE RESOURCE")
	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")
end

-- Create the game mode when we activate
--激活某些函数
function Activate()
	GameRules.AddonTemplate = Worm()
	GameRules.AddonTemplate:InitGameMode()
end

--用于游戏的初始化
function Worm:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)					--取消锁定时间
	GameRules:SetStrategyTime(0)									--取消选完英雄后策略时间
	GameRules:SetShowcaseTime(0)									--取消策略时间之后展示时间
	GameRules:SetPreGameTime(3)										--3s后游戏时间从0开始
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)			--取消战争迷雾
	GameRules:SetStartingGold(0) 
	-- self.mob_spawner = MobSpawner()
	-- self.mob_spawner:Start()
	


	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 2)	--设置天辉最多2人
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)		--设置夜魇最多0人
	SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS,96,96,255)		--设置天辉血条颜色
	SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS,249, 158, 77)		--设置夜魇血条颜色

	ListenToGameEvent("entity_killed", Dynamic_Wrap(Worm, "OnEntityKilled"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(Worm, "OnNPCSpawned"), self)
end

-- Evaluate the state of the game
function Worm:OnThink()
	if GameRules.isInit == false then
		playerAndMonsterInit()
		GameRules.isInit = true
	end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end



function Worm:OnEntityKilled(keys)
	local	unitKilled = EntIndexToHScript(keys.entindex_killed)
	location = Maps()
	if unitKilled:GetUnitName() == "yang"	then
		CreateUnitByName("yang", location, true, nil, nil, DOTA_TEAM_BADGUYS)
	end
	if unitKilled:GetUnitName() == "niu"	then
		CreateUnitByName("niu", location, true, nil, nil, DOTA_TEAM_BADGUYS)
	end
	if unitKilled:GetUnitName() == "huoren"	then
		CreateUnitByName("huoren", location, true, nil, nil, DOTA_TEAM_BADGUYS)
	end
end

function Worm:OnNPCSpawned(keys)
	local unit = EntIndexToHScript(keys.entindex)
	if unit:IsHero() then
		local playerid = unit:GetPlayerID()
		playerStatus[playerid]["she"] ={}
		playerStatus[playerid]["shePoint"] = 1
		playerStatus[playerid]["she"][playerStatus[playerid]["shePoint"]] = unit
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("move"), 
													function()
														local location = unit:GetAbsOrigin()
														local chaoxiang = unit:GetForwardVector()
														local position = location + chaoxiang*1000
														unit:MoveToPosition(position)

														local unitsInRadius = FindUnitsInRadius(DOTA_TEAM_BADGUYS, location, nil, 100, 
														DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,false)

														for k,v in pairs(unitsInRadius) do
															if v:GetUnitName() == "yang" then
																v:ForceKill(true)
																createzuoji(playerid)
															end
															if v:GetUnitName() == "niu" then
																v:ForceKill(true)
																createzuoji(playerid)
																createzuoji(playerid)
															end
														end
														
														return 0.5
													end, 0)
	end
end





-- function Worm:OnEntityKilled(keys)
-- 	print("in deadEvent")
-- 	print(keys)
-- 	local id = keys.entindex_killed					--一个随机分配的整数
-- 	print(id)
-- 	local newUnity = EntIndexToHScript(keys.entindex_killed)
-- 	if newUnity:IsHero() == false then
-- 		return
-- 	else
-- 		print("11")
-- 	end
-- end

-- function SelectHero(){
-- 	$("heroList").style.visibility = "collapse"
-- 	$("selectHero").style.visibility = "collapse"
-- 	$("HeroInfo").style.visibility = "collapse"
-- 	GameEvents.sendcustomGameEventToSever("hero_selected",{HeroName:'npc_dota_hero_' + selectHero})
-- }


-- function Worm:select_hero(data)
-- 	print(data)
-- 	print(data.playerid)
-- 	local player = PlayerResource:GetPlayer(data.playerID)
-- 	if player == nil then
-- 		 return
-- 	end
-- 	local heroname = data.heroname or ""
-- 	if heroname == "" then
-- 		return 
-- 	end
-- 	local heroname:string = ""
-- 	player:SetSelectedHero(heroName)
-- end