//
//
//
//


decoda_name = "Client"

Script.Load("lua/PreLoadMod.lua")

Script.Load("lua/mvm_Shared.lua")

Script.Load("lua/mvm_ClientUI.lua")


Shared.PrecacheSurfaceShader("shaders/Model_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Emissive_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_emissive_Colored.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_emissive_alpha_Colored.surface_shader")


Script.Load("lua/PostLoadMod.lua")