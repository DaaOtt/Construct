AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function GM:PlayerSpawnObject(ply, model, skin)
	print(ply, model, skin)
	return true
end

function GM:PlayerLoadout(ply)
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	ply:Give("weapon_crowbar")

	ply:SetRunSpeed(200)
	ply:SetWalkSpeed(150)	
end

--[[---------------------------------------------------------
   Name: DoPlayerEntitySpawn
   Desc: Utility function for player entity spawning functions
-----------------------------------------------------------]]
function DoPlayerEntitySpawn( player, entity_name, model, iSkin, strBody )

	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()

	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = player
	
	local tr = util.TraceLine( trace )

	-- PrintTable( tr )

	-- Prevent spawning too close
	--if ( !tr.Hit || tr.Fraction < 0.05 ) then 
	--	return 
	--end
	
	local ent = ents.Create( entity_name )
	if not IsValid(ent) then return end
	print(ent)

	local ang = player:EyeAngles()
	ang.yaw = ang.yaw + 180 -- Rotate it 180 degrees in my favour
	ang.roll = 0
	ang.pitch = 0
	
	if (entity_name == "prop_ragdoll") then
		ang.pitch = -90
		tr.HitPos = tr.HitPos
	end
	
	ent:SetModel( model )
	ent:SetSkin( iSkin )
	ent:SetAngles( ang )
	ent:SetBodyGroups( strBody )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()
	if not IsValid(ent:GetPhysicsObject()) then
		ent:Remove()
		return
	end
	print(ent:GetPhysicsObject():GetMass())
	

	-- Attempt to move the object so it sits flush
	-- We could do a TraceEntity instead of doing all 
	-- of this - but it feels off after the old way

	local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	-- Find a point that is definitely out of the object in the direction of the floor
		vFlushPoint = ent:NearestPoint( vFlushPoint )			-- Find the nearest point inside the object to that point
		vFlushPoint = ent:GetPos() - vFlushPoint				-- Get the difference
		vFlushPoint = tr.HitPos + vFlushPoint					-- Add it to our target pos
										
	if (entity_name ~= "prop_ragdoll") then
	
		-- Set new position
		ent:SetPos( vFlushPoint )
		player:SendLua( "achievements.SpawnedProp()" )
	
	else
	
		-- With ragdolls we need to move each physobject
		local VecOffset = vFlushPoint - ent:GetPos()
		for i=0, ent:GetPhysicsObjectCount()-1 do
			local phys = ent:GetPhysicsObjectNum( i )
			phys:SetPos( phys:GetPos() + VecOffset )
		end
		
		player:SendLua( "achievements.SpawnedRagdoll()" )
		
	end

	return ent
	
end