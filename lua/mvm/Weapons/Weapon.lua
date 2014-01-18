

Script.Load("lua/PostLoadMod.lua")


//-----------------------------------------------------------------------------


//local orgWeaponRender = Weapon.OnUpdateRender
function Weapon:OnUpdateRender()	//Overrides
	
    local parent = self:GetParent()
    local settings = self:GetUIDisplaySettings()
    if parent and parent:GetIsLocalPlayer() and settings then
    
        local ammoDisplayUI = self.ammoDisplayUI
        if not ammoDisplayUI then
        
            ammoDisplayUI = Client.CreateGUIView(settings.xSize, settings.ySize)
            ammoDisplayUI:Load(settings.script)
            ammoDisplayUI:SetTargetTexture("*ammo_display" .. (settings.textureNameOverride or self:GetMapName()))
            self.ammoDisplayUI = ammoDisplayUI
            
        end
        
        ammoDisplayUI:SetGlobal("teamNumber", parent:GetTeamNumber() )
        
        ammoDisplayUI:SetGlobal("weaponClip", parent:GetWeaponClip() )
        ammoDisplayUI:SetGlobal("weaponAmmo", parent:GetWeaponAmmo() )
        ammoDisplayUI:SetGlobal("weaponAuxClip", parent:GetAuxWeaponClip() )
        
    elseif self.ammoDisplayUI then
    
        Client.DestroyGUIView(self.ammoDisplayUI)
        self.ammoDisplayUI = nil
        
    end
    
end


//-----------------------------------------------------------------------------


Class_Reload("Weapon", {})
