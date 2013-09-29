

Script.Load("lua/Weapons/BulletsMixin.lua")


//-----------------------------------------------------------------------------


// check for umbra and play local hit effects (bullets only)
function BulletsMixin:ApplyBulletGameplayEffects(player, target, endPoint, direction, damage, surface, showTracer)

    // deals damage or plays surface hit effects   
    self:DoDamage(damage, target, endPoint, direction, surface, false, showTracer)
    
end

