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

//40% reduction
kNanoShieldDamageReductionDamage = 0.6	//0.75	ns2-0.68

kInfestationCorrodeDamagePerSecond = 15

kEmpDamageEffectsDuration = 3


kRifleDamage = 12	//10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50		//Note: changing this is can break rifle animation timing
kRifleMeleeDamage = 30	//NS2 - 20
kRifleMeleeDamageType = kDamageType.Melee

kPistolDamage = 26	//NS2 - 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
kPistolAltDamage = 40

kWelderDamagePerSecond = 40	//NS2 - 30
kWelderDamageType = kDamageType.Structural
kWelderWeldDelay = 0.3
kSelfWeldAmount = 0		//Why was this ever added? Confusing as hell...
kPlayerArmorWeldRate = 20

kAxeDamage = 35		//25 - orgMvM: 35 
kAxeDamageType = kDamageType.Puncture	//Structural

kHandGrenadeWeight = 0.05	//0.1

kPulseGrenadeDamageRadius = 7
kPulseGrenadeEnergyDamageRadius = 10
kPulseGrenadeDamage = 90	//125
kPulseGrenadeEnergyDamage = 50
kPulseGrenadeDamageType = kDamageType.ElectroMagnetic

kClusterGrenadeDamage = 85	//v3.2 75
kClusterGrenadeDamageRadius = 10
kClusterFragmentDamage = 25		//20
kClusterFragmentDamageRadius = 6
kClusterGrenadeDamageType = kDamageType.Structural		//kDamageType.Flame

kNerveGasDamagePerSecond = 12	//50
kNerveGasDamageType = kDamageType.Gas	//I.e. Lerk Spores, HP only

kShotgunFireRate = 0.88	//Dead, doesn't Actually do anything
kShotgunDamage = 16
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 12	//ns2-10
kShotgunBulletsPerShotUpgrade = 16
kShotgunRange = 75	//v3.2 60 	NS2 - 30

kGrenadeLauncherGrenadeDamage = 130	//120
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4	 //ns2-4.8
kGrenadeLifetime = 1.5	//2  ns2 2.5
kGrenadeUpgradedLifetime = 1.5

kFlamethrowerDamage = 20
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 40
kFlamethrowerRange = 12				//NS2-9
kFlamethrowerUpgradedRange = 15		//11.5
kBurnDamagePerSecond = 10			//2
kFlamethrowerBurnDuration = 3	//6
kFlameRadius = 1.75					//1.8
kFlameDamageStackWeight = 0.005		//0.5

kWhileBurningWeldEffectReduction = 0.5
kBurnDamageMarineStructureReduction = 1	//0.15
kBurnDamageExoReduction = 0.1	//.05


// affects dual minigun and dual railgun damage output
kExoDualMinigunModifier = 1
kExoDualRailgunModifier = 1

kMinigunDamage = 20
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 175	//bv3-225   ns2-250		//unused..apparently...
kMinigunWeight = 0.11
//TODO Move heatUpRate setting to here, ref global as local in Minigun class

kClawDamage = 50		//60
kClawDamageType = kDamageType.Structural
kClawWeight = 0.05	//0.01

kRailgunDamage = 30
kRailgunChargeDamage = 120		//ns2-130
kRailgunDamageType = kDamageType.Structural
kRailgunWeight = 0.11	//.08

kMACAttackDamage = 5
kMACEMPBlastDamage = 25
kMACAttackDamageType = kDamageType.Light	//Normal
kMACAttackFireDelay = 0.6
kMACEMPCooldown = kEmpDamageEffectsDuration

kMineDamage = 160	//NS2 - 125
kMineDamageType = kDamageType.Structural	//Light
kDemoMinesWeight = 0.12	//v3.2-0.1		NS2-0.19

kSentryDamage = 7.75	//NS2 - 5
kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.5
kElectrifiedSentryBaseROF = 2.5
kSentryWeight = 0.65


kARCDamage = 450
kARCDamageType = kDamageType.Splash // splash damage hits friendlies (that take structural dmg) as well
kARCRange = 25	//v3.2 - 24
kARCMinRange = 7	//v3.2 - 8


local kDamagePerUpgradeScalar = 0.075		//0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar	//+7.5%
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2	//+15%
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3	//+22.5%
kWeapons4DamageScalar = 1 + kDamagePerUpgradeScalar * 4	//+30%



//-----------------------------------------------------------------------------
// ECONOMY

kPlayingTeamInitialTeamRes = 50	//Lower?
kMaxTeamResources = 200

kPlayerInitialIndivRes = 20	//Lower?
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1
kPlayerResPerInterval = 0.1

kCommanderResourceBlockTime = 0

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
kARCSupply = 10
kSentrySupply = 5
kSentryBatterySupply = 5
kRoboticsFactorySupply = 5
kARCRoboticsFactorySupply = 5
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

kWelderCost = 3

kClusterGrenadeCost = 5
kGasGrenadeCost = 5
kPulseGrenadeCost = 5

kMineCost = 10
kShotgunCost = 15
kFlamethrowerCost = 20
kGrenadeLauncherCost = 35

kJetpackCost = 15

kExosuitCost = 50
kExosuitDropCost = 50	//Unused
kDualMinigunExosuitCost = 80	//Unused
kClawRailgunExosuitCost = 50
kDualRailgunExosuitCost = 80	//Unused

kUpgradeToDualMinigunCost = 25
kUpgradeToDualRailgunCost = 25


kGrenadeLauncherDropCost = 35
kFlamethrowerDropCost = 20
kShotgunDropCost = 15
kDropMineCost = 10
kWelderDropCost = 5
kJetpackDropCost = 15
kExosuitDropCost = 50


//ABILITIES ---------------------------

kAmmoPackCost = 1
kMedPackCost = 1
kCatPackCost = 2

kNanoShieldCost = 6
kNanoShieldCooldown = 10	//12
kNanoShieldDuration = 8

kEMPCost = 2
kEMPCooldown = 8

kObservatoryScanCost = 5
kObservatoryDistressBeaconCost = 10


//-----------------------------------------------------------------------------
// BUILD TIMES

// used as fallback
kDefaultBuildTime = 8

kRecycleTime = 12

kCommandStationBuildTime = 25	//NS2 - 15
kInfantryPortalBuildTime = 7
kArmoryBuildTime = 14	//v3.2 15		NS2-12

kSentryBuildTime = 4			//NS2 - 3
kSentryBatteryBuildTime = 5

kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 35		//NS2 - 20
kArmsLabBuildTime = 25			//NS2 - 17

kMACBuildTime = 4
kExtractorBuildTime = 15		//NS2 - 12

kRoboticsFactoryBuildTime = 15	//NS2 - 13
kARCBuildTime = 12				//v3.2 15  NS2 - 10

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
kWeapons4ResearchCost = 45

kArmor1ResearchCost = 15
kArmor2ResearchCost = 25
kArmor3ResearchCost = 35
kArmor4ResearchCost = 45

kResourceUpgradeResearchCost = 5


//-----------------------------------------------------------------------------
// RESEARCH TIMES

kMineResearchTime  = 20
kRifleUpgradeTechResearchTime = 20
kShotgunTechResearchTime = 30
kWelderTechResearchTime = 20				//NS2 - 15
kAdvancedArmoryResearchTime = 90
kFlamethrowerTechResearchTime = 30
kGrenadeLauncherTechResearchTime = 60
kGrenadeTechResearchTime = 45

kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15
kUpgradeRoboticsFactoryTime = 40
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kJetpackTechResearchTime = 80
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60

kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60
kDualMinigunTechResearchTime = 60

kFlamethrowerAltTechResearchTime = 60

kCatPackTechResearchTime = 20	//15

kPhaseTechResearchTime = 45

kWeapons1ResearchTime = 60
kWeapons2ResearchTime = 80
kWeapons3ResearchTime = 100
kWeapons4ResearchTime = 120

kArmor1ResearchTime = 60
kArmor2ResearchTime = 80
kArmor3ResearchTime = 100
kArmor4ResearchTime = 120

kResourceUpgradeResearchTime = 30


//-----------------------------------------------------------------------------
// ENERGY COSTS

kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150		//Upgraded via AdvancedArmory?

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100

kMACInitialEnergy = 50  kMACMaxEnergy = 150

kEnergyUpdateRate = 0.5

