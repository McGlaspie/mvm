

Script.Load("lua/WeaponOwnerMixin.lua")



local function UpdateWeaponsWeight(self)

    // Loop through all weapons, getting weight of each one
    local totalWeight = 0
    
    local activeWeapon = self:GetActiveWeapon()
    for i = 0, self:GetNumChildren() - 1 do
    
        local child = self:GetChildAtIndex(i)
        if child:isa("Weapon") then
        
            // Active items count full, count less when stowed.
            local weaponIsActive = activeWeapon and (child:GetId() == activeWeapon:GetId())
            local weaponWeight = (weaponIsActive and child:GetWeight()) or (child:GetWeight() * self:GetMixinConstants().kStowedWeaponWeightScalar)
            totalWeight = totalWeight + weaponWeight
            
        end
    
    end
    
    self.weaponsWeight = Clamp(totalWeight, 0, 1)

end


// Returns true if we switched to weapon or if weapon is already active. Returns false if we 
// don't have that weapon.
function WeaponOwnerMixin:SetActiveWeapon(weaponMapName, keepQuickSwitchSlot)

    local foundWeapon = nil
    for i = 0, self:GetNumChildren() - 1 do
    
        local child = self:GetChildAtIndex(i)
        if child:isa("Weapon") and child:GetMapName() == weaponMapName then
        
            foundWeapon = child
            break
            
        end
        
    end
    
    if foundWeapon then
        
        local newWeapon = foundWeapon
        
        if newWeapon.OnSetActive then
            newWeapon:OnSetActive()
        end
        
        local activeWeapon = self:GetActiveWeapon()
        
        if activeWeapon == nil or activeWeapon:GetMapName() ~= weaponMapName then
        
            local previousWeaponName = ""
            
            if activeWeapon then
            
                activeWeapon:OnHolster(self)
                activeWeapon:SetIsVisible(false)
                previousWeaponName = activeWeapon:GetMapName()
                local hudSlot = activeWeapon:GetHUDSlot()

                if keepQuickSwitchSlot == nil then
                    keepQuickSwitchSlot = false
                end

                if hudSlot > 0 and not keepQuickSwitchSlot then
                    //DebugPrint("setting prev hud slot to %d, %s", hudSlot, Script.CallStack())
                    self.quickSwitchSlot = hudSlot
                end
                
            end
            
            // Set active first so proper anim plays
            self.activeWeaponId = newWeapon:GetId()
            
            newWeapon:OnDraw(self, previousWeaponName)
            
            self.timeOfLastWeaponSwitch = Shared.GetTime()
            
            UpdateWeaponsWeight(self)
            
            return true
            
        end
        
    end
    
    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon ~= nil and activeWeapon:GetMapName() == weaponMapName then
    
        UpdateWeaponsWeight(self)
        return true
        
    end
    
    Print("%s:SetActiveWeapon(%s) failed", self:GetClassName(), weaponMapName or "No Weapon")
    
    UpdateWeaponsWeight(self)
    
    return false

end


