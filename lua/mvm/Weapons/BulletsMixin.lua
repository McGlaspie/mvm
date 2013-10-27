

Script.Load("lua/Weapons/BulletsMixin.lua")


//-----------------------------------------------------------------------------


//????: Could potentiall make bullet ricochet if hitting nano'd surface. Make it a
//randomized thing. Say, 10% chance. Unless damage type heavy or something. Options...


// check for umbra and play local hit effects (bullets only)
function BulletsMixin:ApplyBulletGameplayEffects(player, target, endPoint, direction, damage, surface, showTracer)

    // deals damage or plays surface hit effects   
    self:DoDamage(damage, target, endPoint, direction, surface, false, showTracer)
    
end

