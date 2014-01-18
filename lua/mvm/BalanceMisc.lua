// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BalanceMisc.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
//
//	Modified for MvM
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kWorkersPerTechpoint = 5

kArcsPerTechpoint = 3


kPoisonDamageThreshhold = 5

kInitialMACs = 0

// Construct at a slower rate than players
kMACConstructEfficacy = .3
kFlamethrowerAltTechResearchCost = 20

kDefaultFov = 90

kExoFov = 95

kResearchMod = 1

kMinSupportedRTs = 0
kRTsPerTechpoint = 3

kEMPBlastEnergyDamage = 50	//??? Use as doing damage to structure?
kElectrifiedDuration = 3
kElectrifiedMovementModifier = 0.05

kEnzymeAttackSpeed = 1.25

// set to -1 for no time limit
kParasiteDuration = 30

kSentriesPerBattery = 3		//MvM upgradable?

kDefaultStructureCost = 10
kStructureCircleRange = 4
kInfantryPortalUpgradeCost = 10
kInfantryPortalAttachRange = 10
kArmoryWeaponAttachRange = 10

// Minimum distance that initial IP spawns away from team location
kInfantryPortalMinSpawnDistance = 4

kItemStayTime = 20	//30

// For power points
kMarineRepairHealthPerSecond = 600

// The base weapons need to cost a small amount otherwise they can
// be spammed.
kRifleCost = 0
kPistolCost = 0
kAxeCost = 0

kMACSpeedAmount = .5

// How close should MACs/Drifters fly to operate on target
kCommandStationEngagementDistance = 3.5
kInfantryPortalEngagementDistance = 2
kArmoryEngagementDistance = 3
kArmsLabEngagementDistance = 3
kExtractorEngagementDistance = 2
kObservatoryEngagementDistance = 1
kPhaseGateEngagementDistance = 2
kRoboticsFactorEngagementDistance = 3.5
kARCEngagementDistance = 2
kSentryEngagementDistance = 2
kPlayerEngagementDistance = 1
kExoEngagementDistance = 1.5

// Marine buy costs
kFlamethrowerAltCost = 5

// Scanner sweep
kScanDuration = 10
kScanRadius = 20

// Distress Beacon (from NS1)
kDistressBeaconRange = 16	//15
kDistressBeaconTime = 3
kBurningObsDistressBeaconDelay = 5	//6
//EMP damage should have the same delay effect?

kEnergizeRange = 15
// per stack
kEnergizeEnergyIncrease = .25
kStructureEnergyPerEnergize = 0.15
kPlayerEnergyPerEnergize = 15
kEnergizeUpdateRate = 1

kEchoRange = 8

kSprayDouseOnFireChance = .5

// Players get energy back at this rate when on fire 
kOnFireEnergyRecuperationScalar = .6

// Infestation
kMarineInfestationSpeedScalar = .1

kDamageVelocityScalar = 2.5

// Each upgrade costs this much extra evolution time
kUpgradeGestationTime = 2

// Light shaking constants
kOnosLightDistance = 50
kOnosLightShakeDuration = .2

kLightShakeMaxYDiff = .05
kLightShakeBaseSpeed = 30
kLightShakeVariableSpeed = 30

// Jetpack
kJetpackUseFuelRate = .25
kJetpackUpgradeUseFuelRate = .15
kJetpackReplenishFuelRate = .35

// Mines
kNumMines = 3
kMineActiveTime = 3	//4
kMineAlertTime = 8
kMineDetonateRange = 4.5
kMineTriggerRange = 1.5

// Onos
kGoreMarineFallTime = 1
kDisruptTime = 5

kEncrustMaxLevel = 5
kSpitObscureTime = 8
kGorgeCreateDistance = 6.5

kMaxTimeToSprintAfterAttack = .1	//.2

// Welding variables
// Also: MAC.kRepairHealthPerSecond
// Also: Exo -> kArmorWeldRate
kWelderPowerRepairRate = 125
kBuilderPowerRepairRate = 105		//100
kWelderSentryRepairRate = 120
kPlayerWeldRate = 30				//32
kStructureWeldRate = 80				//85
kDoorWeldTime = 15

kHatchCooldown = 5
kEggsPerHatch = 2

kHealingBedStructureRegen     = 5 // Health per second

kAlienRegenerationTime = 1

kAlienInnateRegenerationPercentage  = 0.02
kAlienMinInnateRegeneration = 1
kAlienMaxInnateRegeneration = 20

// used for hive healing and regeneration upgrade
kAlienRegenerationPercentage = 0.08
kAlienMinRegeneration = 10
kAlienMaxRegeneration = 60

// when in combat self healing (innate healing or through upgrade) is multiplied with this value
kAlienRegenerationCombatModifier = 0.2

// Umbra blocks 1 out of this many bullet
kUmbraBlockRate = 2
// Carries the umbra cloud for x additional seconds
kUmbraRetainTime = .5

kBellySlideCost = 25
kLerkFlapEnergyCost = 3
kFadeShadowStepCost = 10
kChargeEnergyCost = 40 // per second

kAbilityMaxEnergy = 100
kAdrenalineAbilityMaxEnergy = 200

kOnosAcceleration = 55
kOnosBaseSpeed = 2
kOnosExtraSpeed = 7
kOnosSpeedScalar = 3
kOnosReduceSpeedScalar = 5
kOnosStompMaxVelocity = .25
kOnosActiveAmount = .75 // Cory likes .5
kOnosInactiveChangeSpeed = 2
kOnosMinActiveViewModelParam = .6
kOnosBackBackwardSpeedScalar = .2


kPistolWeight = 0.08
kRifleWeight = 0.11				//.13
kGrenadeLauncherWeight = 0.18
kFlamethrowerWeight = 0.2		//.25
kShotgunWeight = 0.14			


// set to -1 to disable or a positive number
kResourcesPerNode = -1


// 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 6

kDropStructureEnergyCost = 20

kMinWebLength = 0.5
kMaxWebLength = 8


