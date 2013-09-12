//
//	MvM Client
//	Any additional loads for MvM are done after normal NS2 Client loaded.
//


decoda_name = "Client"

Script.Load("lua/PreLoadMod.lua")

Script.Load("lua/Client.lua")	//Load normal NS2 Client


Script.Load("lua/mvm_Shared.lua")
Script.Load("lua/mvm_ClientUI.lua")
//ClientResources?

Shared.PrecacheSurfaceShader("shaders/Model_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Emissive_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_emissive_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_emissive_alpha_Colored.surface_shader")


Script.Load("lua/PostLoadMod.lua")