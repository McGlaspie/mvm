//
//	MvM Shared
//	Effectively overrides the vanila NS2 files via the mod framework.
//	This is only here to separate MvM source from other mods (lua/mvm)
//


Script.Load("lua/PreLoadMod.lua")


Script.Load("lua/mvm_Globals.lua")

Script.Load("lua/mvm/MapBlip.lua")
Script.Load("lua/mvm/SensorBlip.lua")

Script.Load("lua/mvm/Balance.lua")
Script.Load("lua/mvm/BalanceHealth.lua")
Script.Load("lua/mvm/BalanceMisc.lua")

//Below may not work as expected...
Script.Load("lua/mvm/LiveMixin.lua")
Script.Load("lua/mvm/LOSMixin.lua")
Script.Load("lua/mvm/TeamMixin.lua")
Script.Load("lua/mvm/DamageMixin.lua")
Script.Load("lua/mvm/ConstructMixin.lua")
Script.Load("lua/mvm/BuildingMixin.lua")
Script.Load("lua/mvm/FireMixin.lua")
Script.Load("lua/mvm/WeldableMixin.lua")
Script.Load("lua/mvm/GhostStructureMixin.lua")
Script.Load("lua/mvm/PickupableWeaponMixin.lua")
Script.Load("lua/mvm/WeaponOwnerMixin.lua")
Script.Load("lua/mvm/NanoShieldMixin.lua")
Script.Load("lua/mvm/MapBlipMixin.lua")

Script.Load("lua/mvm/ResourcePoint.lua")
Script.Load("lua/mvm/ResourceTower.lua")

Script.Load("lua/mvm/NS2Gamerules.lua")

Script.Load("lua/mvm/Player.lua")

Script.Load("lua/mvm/MAC.lua")
Script.Load("lua/mvm/Mine.lua")
Script.Load("lua/mvm/Extractor.lua")
Script.Load("lua/mvm/Armory.lua")
Script.Load("lua/mvm/ArmsLab.lua")
Script.Load("lua/mvm/Observatory.lua")
Script.Load("lua/mvm/PhaseGate.lua")
Script.Load("lua/mvm/RoboticsFactory.lua")
Script.Load("lua/mvm/PrototypeLab.lua")
Script.Load("lua/mvm/CommandStation.lua")
Script.Load("lua/mvm/Sentry.lua")
Script.Load("lua/mvm/ARC.lua")
Script.Load("lua/mvm/InfantryPortal.lua")
Script.Load("lua/mvm/PowerPoint.lua")
Script.Load("lua/mvm/SentryBattery.lua")


Script.Load("lua/mvm/CommAbilities/Marine/Scan.lua")

Script.Load("lua/mvm/ReadyRoomPlayer.lua")

Script.Load("lua/mvm/MarineCommander.lua")

Script.Load("lua/mvm/Marine.lua")
Script.Load("lua/mvm/JetpackMarine.lua")
Script.Load("lua/mvm/Exosuit.lua") // pickupable version
Script.Load("lua/mvm/Exo.lua")


Script.Load("lua/mvm/Weapons/Marine/Rifle.lua")
Script.Load("lua/mvm/Weapons/Marine/Flamethrower.lua")
Script.Load("lua/mvm/Weapons/Marine/LayMines.lua")
Script.Load("lua/mvm/Weapons/Marine/Welder.lua")
Script.Load("lua/mvm/Jetpack.lua")
Script.Load("lua/mvm/Weapons/Marine/Grenade.lua")


Script.Load("lua/mvm/MvMUtility.lua")

Script.Load("lua/mvm/TeamInfo.lua")

Script.Load("lua/mvm/GeneralEffects.lua")
Script.Load("lua/mvm/DamageEffects.lua")
Script.Load("lua/mvm/MarineStructureEffects.lua")
Script.Load("lua/mvm/MarineWeaponEffects.lua")


if Client then

	Script.Load("lua/mvm/GUIMarineHUDStyle.lua")
	

end


if Predict then
end


Script.Load("lua/PostLoadMod.lua")
