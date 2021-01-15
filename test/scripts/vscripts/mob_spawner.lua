local spawner_config = require("config_mob_spawn")

if MobSpawner == nil then
    MobSpawner = class({})
end

function MobSpawner:Start()
    GameRules:GetGameModeEntity():SetThink("OnThink",self)
    self.wave = 0
end

function MobSpawner:OnThink()
    local now = GameRules:GetDOTATime(false, true)
    print("now="..now)
    print("self.wave="..self.wave)
    if self.wave == 0 and now >= spawner_config.spawn_start_time then
        self:SpawnNextWave()
        return nil
    end
    return 1
end

function MobSpawner:SpawnNextWave()
    self.wave = self.wave + 1
    local wave_info = spawner_config.waves
    if wave_info then
      
        for i = 1,wave_info.num do
            self:SpawnMob(wave_info.name, wave_info.location, wave_info.level, wave_info.path)
        end
    else
        print("game over!")
    end
end

function MobSpawner:SpawnMob(name, location, level, path)
    local location_ent = Entities:FindByName(nil, location)
    local position = location_ent:GetOrigin()
    local mob = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    mob:CreatureLevelUp(level)
    if path then
        mob:SetMustReachEachGoalEntity(true)
        local path_ent = Entities:FindByName(nil, path)
        mob:SetInitialGoalEntity(path_ent)
    end
end

