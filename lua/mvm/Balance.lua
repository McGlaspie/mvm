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

kRifleDamage = 12	//10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50		//Note: changing this is can break rifle animation timing
kRifleMeleeDamage = 36	//NS2 - 20
kRifleMeleeDamageType = kDamageType.Normal

kPistolDamage = 26	//NS2 - 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
kPistolAltDamage = 40

kWelderDamagePerSecond = 45	//NS2 - 30
kWelderDamageType = kDamageType.Structural
kWelderFireDelay = 0.2		//.2	Does this affect repair rates?
kWelderWeldDelay = 0.3

kAxeDamage = 35
kAxeDamageType = kDamageType.Structural

kGrenadeLauncherGrenadeDamage = 110
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4	//6
kGrenadeLifetime = 2	//2.5


kPulseGrenadeDamageRadius = 6
kPulseGrenadeEnergyDamageRadius = 10
kPulseGrenadeDamage = 125
kPulseGrenadeEnergyDamage = 50
kPulseGrenadeDamageType = kDamageType.ElectroMagnetic

kClusterGrenadeDamageRadius = 10
kClusterGrenadeDamage = 75		//55
kClusterFragmentDamageRadius = 5	//6
kClusterFragmentDamage = 25		//20
kClusterGrenadeDamageType = kDamageType.Flame

kNerveGasDamagePerSecond = 15	//50
kNerveGasDamageType = kDamageType.Gas	//I.e. Lerk Spores, HP only


kShotgunDamage = 17
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 10
kShotgunRange = 38	//NS2 - 30

kFlamethrowerDamage = 7.5
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 30

kBurnDamagePerStackPerSecond = 3
kFlamethrowerMaxStacks = 25	//20
kFlamethrowerBurnDuration = 7	//6
kFlamethrowerStackRate = 0.75	//0.4
kFlameRadius = 1.75
kFlameDamageStackWeight = 0.1	//0.2

kWhileBurningWeldEffectReduction = 0.5
kBurnDamageMarineStructureReduction = 1	//0.15
kBurnDamageExoReduction = 0.1	//.05


// affects dual minigun and dual railgun damage output
kExoDualMinigunModifier = 1
kExoDualRailgunModifier = 1

kMinigunDamage = 25
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 225	//250
kMinigunWeight = 0.15

kClawDamage = 60
kClawDamageType = kDamageType.Structural
kClawWeight = 0.05

kRailgunDamage = 30
kRailgunChargeDamage = 130
kRailgunDamageType = kDamageType.Structural
kRailgunWeight = 0.08



kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal	//Light?
kMACAttackFireDelay = 0.6


kMineDamage = 150	//NS2 - 125
kMineDamageType = kDamageType.Light


kSentryDamage = 7.75	//NS2 - 5
kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.5
kElectrifiedSentryBaseROF = 2.5


kARCDamage = 450
kARCDamageType = kDamageType.Splash // splash damage hits friendlies (that take structural dmg) as well
kARCRange = 24
kARCMinRange = 8



kWeapons1DamageScalar = 1.1
kWeapons2DamageScalar = 1.2
kWeapons3DamageScalar = 1.3

kNanoShieldDamageReductionDamage = 0.75	//0.5

kInfestationCorrodeDamagePerSecond = 15


//-----------------------------------------------------------------------------
// ECONOMY

kPlayingTeamInitialTeamRes = 50
kMaxTeamResources = 200

kPlayerInitialIndivRes = 20
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 7	//NS2 - 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.25	//0.125

kCommanderResourceBlockTime = 60

kKillRewardMin = 0
kKillRewardMax = 0

kKillTeamReward = 0

kResourceUpgradeAmount = 0.3333	 	//????: Make this apply based on leftover supply?
//for 15T makes node grant 2T per tick...worth it?
//should also boost Pres flow?


kMaxSupply = 300			//200
kSupplyPerTechpoint = 50	//100
kSupplyPerResourceNode = 10


kMACSupply = 5
kArmorySupply = 10
kAdvancedArmorySupply = 5
kARCSupply = 20
kSentrySupply = 5
kSentryBatterySupply = 5
kRoboticsFactorySupply = 5	//ARCFact?
kInfantryPortalSupply = 5
kPhaseGateSupply = 10
kArmsLabSupply = 10
kPrototypeLabSupply = 10
kObservatorySupply = 5



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
kObservatoryCost = 10
kPhaseGateCost = 15
kRoboticsFactoryCost = 15
kArmsLabCost = 20
kPrototypeLabCost = 40
kPowerNodeCost = 0

kMACCost = 5
kARCCost = 15

kSentryCost = 5
kSentryBatteryCost = 5

kWelderCost = 5

kClusterGrenadeCost = 4
kGasGrenadeCost = 4
kPulseGrenadeCost = 4

kMineCost = 10
kShotgunCost = 20
kFlamethrowerCost = 20
kGrenadeLauncherCost = 25


kJetpackCost = 15

kExosuitCost = 40
kExosuitDropCost = 50

kClawRailgunExosuitCost = 40
kDualExosuitCost = 60
kDualRailgunExosuitCost = 60

kUpgradeToDualMinigunCost = 25
kUpgradeToDualRailgunCost = 20

kDualMinigunTechResearchCost = 30
kClawRailgunTechResearchCost = 30
kDualRailgunTechResearchCost = 30

kClawRailgunExosuitCost = 50
kDualExosuitCost = 75
kDualRailgunExosuitCost = 75


kExosuitTechResearchCost = 20
kExosuitLockdownTechResearchCost = 20

kExosuitCost = 40
kExosuitDropCost = 50
kClawRailgunExosuitCost = 40
kDualExosuitCost = 60
kDualRailgunExosuitCost = 60

kUpgradeToDualMinigunCost = 20
kUpgradeToDualRailgunCost = 20

kDualMinigunTechResearchCost = 30
kClawRailgunTechResearchCost = 30
kDualRailgunTechResearchCost = 30


kMinigunCost = 30
kRailgunCost = 30
kDualMinigunCost = 25


//ABILITIES ---------------------------
kAmmoPackCost = 1
kMedPackCost = 1
kCatPackCost = 2

kNanoShieldCost = 6
kNanoShieldCooldown = 10	//12
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
kArmoryBuildTime = 15	//12

kSentryBuildTime = 4			//NS2 - 3
kSentryBatteryBuildTime = 5

kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 30		//NS2 - 20
kArmsLabBuildTime = 20			//NS2 - 17

kMACBuildTime = 5
kExtractorBuildTime = 16		//NS2 - 12

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

kGrenadeTechResearchCost = 15

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
kGrenadeTechResearchTime = 45

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

