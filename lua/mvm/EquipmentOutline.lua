

Script.Load("lua/EquipmentOutline.lua")


local _renderMask = 0x4
local _invRenderMask = bit.bnot(_renderMask)
local _maxDistance = 38
local _maxDistance_Commander = 60
local _enabled = true


//-----------------------------------------------------------------------------


function EquipmentOutline_UpdateModel(forEntity)

    local player = Client.GetLocalPlayer()
    
    // Check if player can pickup this item.
    local visible = player ~= nil and forEntity:GetIsValidRecipient(player) and GetCanSeeEntity( player, forEntity, true )
    local model = HasMixin(forEntity, "Model") and ( forEntity:GetRenderModel() or nil )
    
    // Update the visibility status.
    if model and visible ~= model.equipmentVisible then
		
        if visible then	//TODO Color override/param for Team 2
			EquipmentOutline_AddModel(model)
        else
			EquipmentOutline_RemoveModel(model)
        end
        
        model.equipmentVisible = visible
        
    end
    
end


/** Must be called prior to rendering */
function EquipmentOutline_SyncCamera(camera, forCommander)

    local distance = ConditionalValue(forCommander, _maxDistance_Commander, _maxDistance)
    
    local team = 0
    local player = Client.GetLocalPlayer()
    if player then
		team = player:GetTeamNumber()
    end
    
    
    EquipmentOutline_camera:SetCoords(camera:GetCoords())
    EquipmentOutline_camera:SetFov(camera:GetFov())
    EquipmentOutline_camera:SetFarPlane(distance + 1)
    EquipmentOutline_screenEffect:SetParameter("time", Shared.GetTime())
    EquipmentOutline_screenEffect:SetParameter("maxDistance", distance)
    EquipmentOutline_screenEffect:SetParameter("team", team)
    
end
