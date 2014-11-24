AddCSLuaFile()

SWEP.PrintName = "Crowbar"
SWEP.Author			= ""
SWEP.Instructions		= "Left mouse to unleash your fury."

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.Base = "weapon_base" 
SWEP.HoldType 				=  "melee"

local sound_single = Sound("Weapon_Crowbar.Single")
local sound_hit = Sound("Weapon_Crowbar.Melee_HitWorld")
local function entvalid(trace)
	local ent = trace.Entity
	if trace.Hit then
		if trace.HitWorld then
			return true
		end
		if IsValid(ent) then
			if ent:GetClass() == "prop_physics" then
				return true
			end
		end
	end
end

function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end


function SWEP:PrimaryAttack()
	self.Weapon:EmitSound(sound_single)
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)	
	self.Weapon:SetNextPrimaryFire(CurTime() + .5)

	
	local trace = util.TraceLine{
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
		filter = self.Owner,
		mask = MASK_SHOT,
	}
	
	--local trace = self.Owner:GetEyeTrace()

	if trace.Hit then
	--if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		self.Weapon:EmitSound(sound_hit)
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local ent = trace.Entity
		if SERVER and ent:GetClass() == "prop_physics" then
			ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 25))

			if ent:Health() == ent:GetMaxHealth() and not ent:GetNWBool("built") then
				ent:SetNWBool("built", true)
				ent:SetMaterial("")
				ent:SetCollisionGroup(COLLISION_GROUP_NONE)
				local obj = ent:GetPhysicsObject()
				if IsValid(obj) then
					local filter = player.GetAll()
					table.insert(filter, ent)
					
					local tr1 = util.TraceEntity({
						start = ent:GetPos() + Vector(0, 0, 5), --Up/down
						endpos = ent:GetPos() - Vector(0, 0, 5), 
						filter = filter,
						mask = MASK_SHOT,
						}, 
					ent)
					local tr2 = util.TraceEntity({
						start = ent:GetPos() + Vector(5, 0, 0), --Front/back
						endpos = ent:GetPos() - Vector(5, 0, 0), 
						filter = filter,
						mask = MASK_SHOT,
						}, 
					ent)
					local tr3 = util.TraceEntity({
						start = ent:GetPos() + Vector(0, 5, 0), --Right/left
						endpos = ent:GetPos() - Vector(0, 5, 0), 
						filter = filter,
						mask = MASK_SHOT,
						}, 
					ent)
					if not (entvalid(tr1) or entvalid(tr2) or entvalid(tr3)) then
						obj:EnableMotion(true)
						obj:Wake()
					end
				end
			end
		end
	else
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end

end


function SWEP:SecondaryAttack()
end