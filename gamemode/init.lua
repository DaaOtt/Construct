AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function GM:PlayerSpawnObject(ply, model, skin)
	print(ply, model, skin)
	return true
end