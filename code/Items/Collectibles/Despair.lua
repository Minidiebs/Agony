CollectibleType["AGONY_C_DESPAIR"] = Isaac.GetItemIdByName("Despair");

local despair =  {
	hasItem = nil, --used for costume
	costumeID = nil,
	TearBool = false,
	stage = nil
}
despair.costumeID = Isaac.GetCostumeIdByPath("gfx/characters/costume_despair.anm2")

function despair:cacheUpdate (player,cacheFlag)
	if (player:HasCollectible(CollectibleType.AGONY_C_DESPAIR)) then
		if despair.stage == nil then 
			despair.stage = Game():GetLevel():GetStage()
		end
		if (cacheFlag == CacheFlag.CACHE_LUCK) then
			player.Luck = player.Luck - 2
			if despair.stage ~= nil then
				player.Luck = player.Luck + Game():GetLevel():GetStage() - despair.stage
			end
		end
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage - 2
			if despair.stage ~= nil then
				player.Damage = player.Damage + (Game():GetLevel():GetStage() - despair.stage)*3
			end
		end
		if (cacheFlag == CacheFlag.CACHE_SPEED) then
			player.MoveSpeed = player.MoveSpeed - 0.5
			if despair.stage ~= nil then
				player.MoveSpeed = player.MoveSpeed + (Game():GetLevel():GetStage() - despair.stage)*0.2
			end
		end
		if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
			despair.TearBool = true
		end
	end
end

function despair:onUpdate(player)
	if Game():GetFrameCount() == 1 then
		despair.hasItem = false
	end
	if despair.hasItem == false and player:HasCollectible(CollectibleType.AGONY_C_DESPAIR) then
		--player:AddNullCostume(despair.costumeID)
		despair.hasItem = true
	end

	if despair.stage ~= nil and despair.stage ~= Game():GetLevel():GetStage() then
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end
end

--FireDelay workaround
function despair:updateFireDelay(player)
	if (despair.TearBool == true) then
		player.MaxFireDelay = player.MaxFireDelay + 5
		if despair.stage ~= nil then
			player.MaxFireDelay = player.MaxFireDelay - (Game():GetLevel():GetStage() - despair.stage)*3
		end
		despair.TearBool = false;
	end
end

Agony:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, despair.onUpdate)
Agony:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, despair.updateFireDelay)
Agony:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, despair.cacheUpdate)