// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Auto-generated. Copy and paste from balance spreadsheet.
//
// Modified for MvM
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")


//-----------------------------------------------------------------------------
// MARINE DAMAGE

kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50
kRifleMeleeDamage = 35	//NS2 - 20
kRifleMeleeDamageType = kDamageType.Normal

kPistolDamage = 26	//NS2 - 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
kPistolAltDamage = 40

kWelderDamagePerSecond = 40	//NS2 - 30
kWelderDamageType = kDamageType.Structural
kWelderFireDelay = 0.2		//.2	Does this affect repair rates?
kWelderWeldDelay = 0.3

kAxeDamage = 35
kAxeDamageType = kDamageType.Structural

kGrenadeLauncherGrenadeDamage = 110
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4	//6
kGrenadeLifetime = 2.5

kShotgunDamage = 17
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 10
kShotgunRange = 36	//NS2 - 30

kFlamethrowerDamage = 7.5
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 30

kBurnDamagePerStackPerSecond = 3
kFlamethrowerMaxStacks = 20
kFlamethrowerBurnDuration = 6
kFlamethrowerStackRate = 0.4
kFlameRadius = 1.75
kFlameDamageStackWeight = 0.2

kWhileBurningWeldEffectReduction = 0.5
kBurnDamageMarineStructureReduction = 1	//0.15
kBurnDamageExoReduction = 0.1	//.05

kMinigunDamage = 25
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 225	//250
kMinigunWeight = 0.15

kClawDamage = 60
kClawDamageType = kDamageType.Structural
kClawWeight = 0.05

kRailgunDamage = 50
kRailgunChargeDamage = 150
kRailgunDamageType = kDamageType.Structural
kRailgunWeight = 0.0

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal	//Light?
kMACAttackFireDelay = 0.6

kMineDamage = 150	//NS2 - 125
kMineDamageType = kDamageType.Light

kSentryDamage = 7.5	//NS2 - 5
kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.0

kARCDamage = 450
kARCDamageType = kDamageType.Splash // splash damage hits friendlies (that take structural dmg) as well
kARCRange = 25
kARCMinRange = 7

kWeapons1DamageScalar = 1.1
kWeapons2DamageScalar = 1.2
kWeapons3DamageScalar = 1.3

kNanoShieldDamageReductionDamage = 0.5


//-----------------------------------------------------------------------------
// ECONOMY

kPlayingTeamInitialTeamRes = 50
kMaxTeamResources = 200

kPlayerInitialIndivRes = 20
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 7	//NS2 - 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.125

kKillRewardMin = 0
kKillRewardMax = 0

kKillTeamReward = 0

kResourceUpgradeAmount = 0.3333	 
//for 15T makes node grant 2T per tick...worth it?
//should also boost Pres flow?


//-----------------------------------------------------------------------------
// SPAWNING / ABILITY TIMERS

kMarineRespawnTime = 7
kNanoShieldOnSpawnLength = 2


//-----------------------------------------------------------------------------
// BUILDING / ABILITY COSTS

kCommandStationCost = 15
kExtractorCost = 10
kInfantryPortalCost = 15
kArmoryCost = 10
kObservatoryCost = 15
kPhaseGateCost = 15
kRoboticsFactoryCost = 15
kSentryCost = 5
kSentryBatteryCost = 5
kArmsLabCost = 20
kPrototypeLabCost = 40
kPowerNodeCost = 0

kMACCost = 5
kARCCost = 15

kWelderCost = 5
kMineCost = 10
kShotgunCost = 20
kFlamethrowerCost = 20
kGrenadeLauncherCost = 25

kJetpackCost = 15

kExosuitCost = 50
kClawRailgunExosuitCost = 50
kDualExosuitCost = 75
kDualRailgunExosuitCost = 75

kMinigunCost = 30
kRailgunCost = 30
kDualMinigunCost = 25


//ABILITIES ---------------------------
kAmmoPackCost = 1
kMedPackCost = 1
kCatPackCost = 2

kNanoShieldCost = 6
kNanoShieldCooldown = 12
kNanoShieldDuration = 8

kEMPCost = 2
kEMPCooldown = 8

kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10


//-----------------------------------------------------------------------------
// BUILD TIMES

// used as fallback
kDefaultBuildTime = 8

kRecycleTime = 12

kCommandStationBuildTime = 25	//NS2 - 15
kInfantryPortalBuildTime = 7
kArmoryBuildTime = 12

kSentryBuildTime = 4.5			//NS2 - 3
kSentryBatteryBuildTime = 6		//NS2 - 5

kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 25		//NS2 - 20
kArmsLabBuildTime = 20			//NS2 - 17

kMACBuildTime = 5
kExtractorBuildTime = 18		//NS2 - 12

kRoboticsFactoryBuildTime = 15	//NS2 - 13
kARCBuildTime = 16				//NS2 - 10

kObservatoryBuildTime = 14		//NS2 - 15
kPhaseGateBuildTime = 12


//-----------------------------------------------------------------------------
// RESEARCH COSTS

kMineResearchCost  = 10
kWelderTechResearchCost = 10
kShotgunTechResearchCost = 15
kGrenadeLauncherTechResearchCost = 25
kFlamethrowerTechResearchCost = 20

kAdvancedArmoryUpgradeCost = 20

kTechEMPResearchCost = 10
kTechMACSpeedResearchCost = 15

kUpgradeRoboticsFactoryCost = 15
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15

kPhaseTechResearchCost = 20

kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kCatPackTechResearchCost = 10
kRifleUpgradeTechResearchCost = 10

kExosuitTechResearchCost = 30
kExosuitLockdownTechResearchCost = 20
kExosuitUpgradeTechResearchCost = 20
kDualMinigunTechResearchCost = 25
kClawRailgunTechResearchCost = 20
kDualRailgunTechResearchCost = 30

kWeapons1ResearchCost = 15
kWeapons2ResearchCost = 25
kWeapons3ResearchCost = 35
kArmor1ResearchCost = 15
kArmor2ResearchCost = 25
kArmor3ResearchCost = 35

kResourceUpgradeResearchCost = 5


//-----------------------------------------------------------------------------
// RESEARCH TIMES

kMineResearchTime  = 20
kRifleUpgradeTechResearchTime = 20
kShotgunTechResearchTime = 30
kWelderTechResearchTime = 20				//NS2 - 15
kAdvancedArmoryResearchTime = 90
	kFlamethrowerTechResearchTime = 30
	kGrenadeLauncherTechResearchTime = 40

kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15
kUpgradeRoboticsFactoryTime = 40
	kARCSplashTechResearchTime = 30
	kARCArmorTechResearchTime = 30

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60

kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60
kDualMinigunTechResearchTime = 60

kFlamethrowerAltTechResearchTime = 60

kCatPackTechResearchTime = 15

kPhaseTechResearchTime = 60					//NS2 - 45

kWeapons1ResearchTime = 80
kWeapons2ResearchTime = 100
kWeapons3ResearchTime = 120

kArmor1ResearchTime = 80
kArmor2ResearchTime = 100
kArmor3ResearchTime = 120

kResourceUpgradeResearchTime = 30


//-----------------------------------------------------------------------------
// ENERGY COSTS

kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150		//Upgraded via AdvancedArmory?

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100

kMACInitialEnergy = 50  kMACMaxEnergy = 150

kEnergyUpdateRate = 0.5

