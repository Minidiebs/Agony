--local item_YeuxRev = Isaac.GetItemIdByName("Yeux Revolver");
CollectibleType["AGONY_C_YEUX_REVOLVER"] = Isaac.GetItemIdByName("Yeux Revolver");
local yeuxRev =  {
	hasItem = nil, --used for costume
	costumeID = nil,
	TearBool = false
}
yeuxRev.costumeID = Isaac.GetCostumeIdByPath("gfx/characters/costume_yeuxrevolver.anm2")

function yeuxRev:cacheUpdate (player,cacheFlag)
	if (player:HasCollectible(CollectibleType.AGONY_C_YEUX_REVOLVER)) then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = (player.Damage + 3.42069*player:GetCollectibleNum(CollectibleType.AGONY_C_YEUX_REVOLVER))
		end
		if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
			player.ShotSpeed = (player.ShotSpeed + 1.69420*player:GetCollectibleNum(CollectibleType.AGONY_C_YEUX_REVOLVER))
		end
		if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
			yeuxRev.TearBool = true
		end
	end
end

function yeuxRev:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		yeuxRev.hasItem = false
	end
	if yeuxRev.hasItem == false and player:HasCollectible(CollectibleType.AGONY_C_YEUX_REVOLVER) then
		player:AddNullCostume(yeuxRev.costumeID)
		yeuxRev.hasItem = true
	end
end

--FireDelay workaround
function yeuxRev:updateFireDelay()
	local player = Isaac.GetPlayer(0);
	if (yeuxRev.TearBool == true) then
		player.MaxFireDelay = player.MaxFireDelay + 4*player:GetCollectibleNum(CollectibleType.AGONY_C_YEUX_REVOLVER);
		yeuxRev.TearBool = false;
	end
end

function yeuxRev:onTakeDmg(hurtEntity, dmgAmount, dmgFlags, source, countdown)
	local player = Game():GetPlayer(0)
	--player:AddKeys(1)
	if player:HasCollectible(CollectibleType.AGONY_C_YEUX_REVOLVER) and hurtEntity:IsVulnerableEnemy() then
		--player:AddBombs(1)
		local time = Isaac.GetTime()
		while time + 45 >Isaac.GetTime() do
		end
		Game():ShakeScreen(math.floor(player.Damage/3))
	end
end

Agony:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, yeuxRev.onTakeDmg)
Agony:AddCallback(ModCallbacks.MC_POST_UPDATE, yeuxRev.updateFireDelay)
Agony:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, yeuxRev.onPlayerUpdate)
Agony:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, yeuxRev.cacheUpdate)