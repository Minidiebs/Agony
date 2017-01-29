local item_D3 = Isaac.GetItemIdByName("D3")
local dthree =  {}

function dthree:rerollColl()
	local player = Game():GetPlayer(0)
	if player:GetCollectibleCount() >= 1 then --If the player has collectibles
	    local colletibles = {}
        for i=1, CollectibleType.NUM_COLLECTIBLES do --Iterate over all collectibles to see if the player has it, as far as I know you can't get the current collectible list
   	        if player:HasCollectible(i) then --If they have it add it to the table
                table.insert(colletibles, i)
            end
        end
        player:RemoveCollectible(colletibles[math.random(#colletibles)])
        player:AddCollectible(math.random(CollectibleType.NUM_COLLECTIBLES), 0, true)
    end
end

Agony:AddCallback(ModCallbacks.MC_USE_ITEM, dthree.rerollColl, item_D3)