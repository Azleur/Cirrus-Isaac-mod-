local Cirrus = RegisterMod("Cirrus", 1)
local game = Game()

-- Tear flags, from the internets

local TearFlags = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_COAL = 1<<6,
	FLAG_PARASITE = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_UNK1 = 1<<11, --No noticeable effect
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_FEAR = 1<<20,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_FIRE = 1<<22,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_UNK2 = 1<<24, --Possible worm?
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_UNK3 = 1<<28, --Possible worm?
	FLAG_UNK4 = 1<<29, --Possible worm?
	FLAG_UNK5 = 1<<30, --Possible worm?
	FLAG_HOOK_WORM = 1<<31,
	FLAG_GODHEAD = 1<<32,
	FLAG_UNK6 = 1<<33, --No noticeable effect
	FLAG_UNK7 = 1<<34, --No noticeable effect
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_CONTINUUM = 1<<36,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_KEEPER_HEAD = 1<<38,
	FLAG_ENEMIES_DROP_BLACK_HEARTS = 1<<39,
	FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_UNK8 = 1<<42, --No noticeable effect
	FLAG_TOXIC_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_BOOGERS = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_UNK9 = 1<<48, --No noticeable effect
	FLAG_SPLIT = 1<<49,
	FLAG_DEADSHOT = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_JACOBS_LADDER = 1<<53,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_GHOST_PEPPER = 1<<55
}

-- An onscreen logger, from epicbob57#8905 on #themoddingofisaac discord

local eLog = {"Log:"}
function Cirrus:eLogDraw()
    for i,j in ipairs(eLog) do
        Isaac.RenderText(j, 42, 20 + i*15,255,255,255,255)
    end
end
Cirrus:AddCallback(ModCallbacks.MC_POST_RENDER, Cirrus.eLogDraw);

local function eLogWrite(str)
    table.insert(eLog,str)
    if #eLog > 10 then
        table.remove(eLog,1)
    end
end

-- Actual Cirrus content

Cirrus.COSTUME_CIRRUS_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/Cirrus_hair.anm2")
Cirrus.COLLECTIBLE_BUSTED_SWORD = Isaac.GetItemIdByName("Busted Sword")
Cirrus.TRINKET_MATERIA = Isaac.GetTrinketIdByName("Materia")

Cirrus.CacheFlag = false

local modData = { xp = 0, lvl = 1}
function modData:ToString()
    return self.lvl .. ";" .. self.xp
end
function modData:FromString(str)
    lvlString, xpString = str:match("([^;]+);([^;]+)")
    self.lvl = tonumber(lvlString)
    self.xp = tonumber(xpString)
end

if Cirrus:HasData() then modData:FromString(Cirrus:LoadData()) end

local MaxLevel = 99
local XpBase = 13
local XpIncrease = 7
local XpTable = {}
for i=1,MaxLevel do
    XpTable[i] = XpBase + XpIncrease * (i - 1)
end

local DamageBase = -0.5
local DamageIncrease = 0.35
local DelayBase = 1
local DelayIncrease = -1
local DelayEvery = 2
local ShotSpeedBase = -0.3
local ShotSpeedIncrease = 0.1
-- local RangeBase = -10
-- local RangeIncrease = 4
local SpeedBase = -0.2
local SpeedIncrease = 0.1
local LuckBase = 1
local LuckIncrease = 1

function Cirrus:OnCache(player, cacheFlag)
    if player:GetName() == "Cirrus" then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + DamageBase + (modData.lvl - 1) * DamageIncrease
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			-- NORMAL WAY DOESN'T WORK:
            -- player.MaxFireDelay = player.MaxFireDelay + DelayBase + (modData.lvl - 1) * DelayIncrease
			eLogWrite("Fire delay cache reached.")
			Cirrus.CacheFlag = true
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + ShotSpeedBase + (modData.lvl - 1) * ShotSpeedIncrease
        end
        -- if cacheFlag == CacheFlag.CACHE_RANGE then
        --     player.Range = player.Range + RangeBase + (modData.lvl - 1) * RangeIncrease
        -- end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + SpeedBase + (modData.lvl - 1) * SpeedIncrease
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + LuckBase + (modData.lvl - 1) * LuckIncrease
        end
    end
end

Cirrus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Cirrus.OnCache)

function Cirrus:OnNpcUpdate(npc)
    -- eLogWrite("NPC update triggered")
    player = Isaac.GetPlayer(0)
    if player:GetName() == "Cirrus" then
        -- eLogWrite("Cirrus found")
        if npc:IsDead() then
            -- eLogWrite("Dead NPC found")
            modData.xp = modData.xp + 1
            while modData.lvl < MaxLevel and modData.xp >= XpTable[modData.lvl] do
                modData.xp = modData.xp - XpTable[modData.lvl]
                modData.lvl = modData.lvl + 1
                -- eLogWrite("Level up! lvl." .. modData.lvl)
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
                player:QueueExtraAnimation("Happy")
            end
            Cirrus:SaveData(modData:ToString())
        end
    end
end

Cirrus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Cirrus.OnNpcUpdate)

function Cirrus:OnRender()
    player = Isaac.GetPlayer(0)
    if player:GetName() == "Cirrus" then
        Isaac.RenderText("lvl: " .. modData.lvl .. " xp: " .. modData.xp .. "/" .. XpTable[modData.lvl], 120, 5, 255, 255, 255, 255)
    end
end

Cirrus:AddCallback(ModCallbacks.MC_POST_RENDER, Cirrus.OnRender)

function Cirrus:OnPlayerInit(player)
    -- eLogWrite("OnPlayerInit called.")
    if player:GetName() == "Cirrus" then
        player:AddNullCostume(Cirrus.COSTUME_CIRRUS_HAIR)
        -- eLogWrite("Trying to add trinket (id=" .. Cirrus.TRINKET_MATERIA ..")")
        player:AddTrinket(Cirrus.TRINKET_MATERIA)
		player:AddCollectible(Cirrus.COLLECTIBLE_BUSTED_SWORD, 4, false)
    end
end

Cirrus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Cirrus.OnPlayerInit)

function Cirrus:OnGameUpdate()
	if game:GetFrameCount() == 1 then
		-- eLogWrite("First frame detected.")
		modData.lvl = 1
		modData.xp = 0
	end
    local player = Isaac.GetPlayer(0)
	if player:GetName() == "Cirrus" and Cirrus.CacheFlag then
		player.MaxFireDelay = player.MaxFireDelay + DelayBase + ((modData.lvl - 1) // DelayEvery) * DelayIncrease
		Cirrus.CacheFlag = false
	end
    if player:HasTrinket(Cirrus.TRINKET_MATERIA) then
        local rng = player:GetTrinketRNG(Cirrus.TRINKET_MATERIA)
        local entities = Isaac.GetRoomEntities()
        for i = 1, #entities do
            local tear = entities[i]:ToTear()
            if tear then
                if tear.FrameCount == 1 then -- If this is a newly fired tear
                    local p = (4 + player.Luck) / 80
                    local f = rng:RandomFloat()
                    -- eLogWrite("p: " .. p .. " f: " .. f)
                    if p > f then -- Randomly choose
                        tear:ChangeVariant(TearVariant.FIRE_MIND)
                        tear.TearFlags = tear.TearFlags | TearFlags.FLAG_FIRE
                        tear.BaseDamage = tear.BaseDamage * 2
						-- tear:ResetSpriteScale() -- Didn't work :O
						tear.Scale = tear.Scale * 2 -- TODO: Test size
                    end
                end
            end
        end
    end
end

Cirrus:AddCallback(ModCallbacks.MC_POST_UPDATE, Cirrus.OnGameUpdate)

function Cirrus:OnBustedUse(_type, rng)
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local enemies = {}
	local numEnemies = 0
	for i = 1, #entities do
		if entities[i]:IsActiveEnemy() then
			numEnemies = numEnemies + 1
			enemies[numEnemies] = entities[i]:ToNPC()
			-- eLogWrite("Enemy found: " .. entities[i].Type .. " (" .. numEnemies .. ")")
        end
	end
	if #enemies > 0 then
		enemies[1]:PlaySound(SoundEffect.SOUND_1UP, 1, 0, false, 1)
		game:ShakeScreen(10)
		for i = 1, #enemies do
			-- eLogWrite("Enemy hurt: " .. enemies[i].Type .. " (" .. i .. ")")
			enemies[i]:TakeDamage(player.Damage * 3, 0, EntityRef(player), 0)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, enemies[i].Position, Vector(0,0), enemies[i])

		end
		return true
	end
	return false
end

Cirrus:AddCallback(ModCallbacks.MC_USE_ITEM, Cirrus.OnBustedUse, Cirrus.COLLECTIBLE_BUSTED_SWORD)
