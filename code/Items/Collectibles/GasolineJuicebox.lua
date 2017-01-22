StartDebug();
local item_GasolineJuicebox = Isaac.GetItemIdByName("Gasoline Juicebox");
local gasolinejb = {
	TearBool = false;
};


function gasolinejb:cacheUpdate(player, cacheFlag)
	
	if (player:HasCollectible(item_GasolineJuicebox) == true) then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage - 1;
		end
		
		--CACHE_FIREDELAY is broken rn so we need to use workarounds
		if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
			gasolinejb.TearBool = true;
		end
		
		--Not really sure how to set range. Documentation gives me 3 different attributes for range
		if (cacheFlag == CacheFlag.CACHE_RANGE) then
			player.TearFallingSpeed = player.TearFallingSpeed - .5
		end
	end
end

function gasolinejb:TearsToFlames()
	local player = Isaac.GetPlayer(0);
	local entities = Isaac.GetRoomEntities();
	local velocity = nil;
	local pos = nil;
	local tearParent = nil;
	
	--Replace tears with fires
	if (player:HasCollectible(item_GasolineJuicebox) == true) then
		for i = 1, #entities do
			if (entities[i].Type == EntityType.ENTITY_TEAR and (entities[i].Parent.Type == 1 or (entities[i].Parent.Type == 3 and entities[i].Parent.Variant == 80))) then --player == 1.0.0, incubus == 3.80.0
				
				velocity = entities[i].Velocity;
				pos = entities[i].Position;
				tearParent = entities[i].Parent;
				
				entities[i]:Remove();
				
				local fire = Isaac.Spawn(1000, 52, 1, pos, velocity, tearParent);
				fire.CollisionDamage = player.Damage;
				if (player:HasCollectible(CollectibleType.COLLECTIBLE_CANDLE)) then --blue fires if the player has blue candle
					fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_blue.png")
					fire:GetSprite():LoadGraphics();
				end
				
				
				if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and fire.SpawnerType == 3 and fire.SpawnerVariant == 80) then --double the damage of incubus' fires if player has bffs!
					fire.CollisionDamage = player.Damage*2;
				end
				
				pos = nil;
				velocity = nil;
				tearParent = nil;
			end
			
			--Fires dissappear after time, unless isaac has the red candle
			if (entities[i].Type == 1000 and entities[i].Variant == 52 and (entities[i].SpawnerType == 1 or entities[i].SpawnerType == 3) and entities[i].SubType == 1 and not player:HasCollectible(CollectibleType.COLLECTIBLE_RED_CANDLE)) then
				if (entities[i].FrameCount % 100 == 0) then
					if (entities[i]:GetSprite():IsPlaying("FireStage00") == true) then
						entities[i]:GetSprite():Play("FireStage01");
					elseif (entities[i]:GetSprite():IsPlaying("FireStage01") == true) then
						entities[i]:GetSprite():Play("FireStage02");
					elseif (entities[i]:GetSprite():IsPlaying("FireStage02") == true) then
						entities[i]:GetSprite():Play("FireStage03");
					elseif (entities[i]:GetSprite():IsPlaying("FireStage03") == true) then
						entities[i]:Remove();
					end
				end
			end
			
			--Fires have homing effect when the player has blue candle
			if (entities[i].Type == 1000 and entities[i].Variant == 52 and (entities[i].SpawnerType == 1 or entities[i].SpawnerType == 3) and entities[i].SubType == 1 and player:HasCollectible(CollectibleType.COLLECTIBLE_CANDLE)) then
				entities[i].Velocity = entities[i].Velocity:__add(Agony:calcTearVel(entities[i].Position, (Agony:getNearestEnemy(entities[i])).Position, 0.5))
			end
		end
	end
end

--FireDelay workaround
function gasolinejb:updateFireDelay()
	local player = Isaac.GetPlayer(0);
	if (gasolinejb.TearBool == true) then
		player.MaxFireDelay = player.MaxFireDelay * 1.5 + 2;
		gasolinejb.TearBool = false;
	end
end

Agony:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, gasolinejb.cacheUpdate);
Agony:AddCallback(ModCallbacks.MC_POST_UPDATE, gasolinejb.TearsToFlames);
Agony:AddCallback(ModCallbacks.MC_POST_UPDATE, gasolinejb.updateFireDelay);