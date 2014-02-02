

Script.Load("lua/Effects.lua")


Script.Load("lua/mvm/GeneralEffects.lua")
Script.Load("lua/mvm/DamageEffects.lua")
Script.Load("lua/mvm/PlayerEffects.lua")
Script.Load("lua/mvm/MarineStructureEffects.lua")
Script.Load("lua/mvm/MarineWeaponEffects.lua")

GetEffectManager():PrecacheEffects()	//???? Won't this cause a "double" precache?

//Hackaround
PrecacheAsset("cinematics/marine/rail_death_explode.cinematic")

