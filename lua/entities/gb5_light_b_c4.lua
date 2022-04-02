AddCSLuaFile()
if (SERVER) then
	util.AddNetworkString("c4_diagbox")
	util.AddNetworkString("c4_datastream")
end

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/light_bomb/small_explosion_1.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/light_bomb/small_explosion_2.mp3"
ExploSnds[3]                         =  "gbombs_5/explosions/light_bomb/small_explosion_3.mp3"
ExploSnds[4]                         =  "gbombs_5/explosions/light_bomb/small_explosion_4.mp3"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "C4"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Light Bombs"

ENT.Model                            =  "models/weapons/w_c4_planted.mdl"                      
ENT.Effect                           =  "c4"                  
ENT.EffectAir                        =  "c4_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/ex_2.mp3"
 
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  true

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  500
ENT.ExplosionRadius                  =  500
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  2500                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  155
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  1   
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 1000 
ENT.Decal                            = "scorch_big"

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	 self.AllowDetonate = true
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
	if not self.Exploded then return end
	if self.Exploding then return end

	local pos = self:LocalToWorld(self:OBBCenter())


	constraint.RemoveAll(self)
	local physo = self:GetPhysicsObject()
	physo:Wake()	

	self.Exploding = true
	if not self:IsValid() then return end 
	self:StopParticles()
	local pos = self:LocalToWorld(self:OBBCenter())

	local ent = ents.Create("gb5_shockwave_ent")
	ent:SetPos( pos ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	ent:SetVar("SHOCKWAVE_INCREMENT",100)
	ent:SetVar("DELAY",0.01)
	ent.trace=self.TraceLength
	ent.decal=self.Decal


	local ent = ents.Create("gb5_shockwave_sound_lowsh")
	ent:SetPos( pos ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",50000)
	if GetConVar("gb5_sound_speed"):GetInt() == 0 then
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",300)
	elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",400)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",100)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",50)
	else
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	end
	ent:SetVar("DELAY",0.01)
	ent:SetVar("SOUND", table.Random(ExploSnds))
	ent:SetVar("Shocktime", self.Shocktime)

	local pos = self:GetPos()
	if(self:WaterLevel() >= 1) then
	local trdata   = {}
	local trlength = Vector(0,0,9000)

	trdata.start   = pos
	trdata.endpos  = trdata.start + trlength
	trdata.filter  = self
	local tr = util.TraceLine(trdata) 

	local trdat2   = {}
	trdat2.start   = tr.HitPos
	trdat2.endpos  = trdata.start - trlength
	trdat2.filter  = self
	trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT

	local tr2 = util.TraceLine(trdat2)

	if tr2.Hit then
	ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)

	end
	else
	local tracedata    = {}
	tracedata.start    = pos
	tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
	tracedata.filter   = self.Entity

	local trace = util.TraceLine(tracedata)

	if trace.HitWorld then
	ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
	else 
	ParticleEffect(self.EffectAir,self:GetPos(),Angle(0,0,0),nil) 
	end
	end
	self:Remove()
end
net.Receive("c4_datastream",function()
	local entity 		= net.ReadEntity()
	local c4_timer  	= net.ReadFloat()
	entity.AllowDetonate=false
	
	timer.Simple(c4_timer, function()
		if not entity:IsValid() then return end
		entity.Exploded=true
		
		entity:Explode()
	end)

end)
net.Receive("c4_diagbox",function()

	local self=net.ReadEntity()
	local win=vgui.Create("DFrame")
	win:SetSize(200,200)
	win:Center()
	win:SetVisible(true)
	win:SetTitle("C4")
	
	
	local c4_w=vgui.Create("DLabel", win)
	c4_w:SetPos(25,60)
	c4_w:SetText("Explosion Timer (1-60 seconds):")
	c4_w:SizeToContents()
		
	local c4_t=vgui.Create("DTextEntry",win)
	c4_t:SetPos(50,90)
	c4_t:SetWide(100)
	c4_t:SetTall(15)
	c4_t:SetEnterAllowed(false)
	
	
	local DButton = vgui.Create( "DImageButton", win )
	DButton:SetPos( 70, 120 )
	DButton:SetText( "" )
	DButton:SetImage("icon16/cross.png")
	DButton:SetSize( 60, 60 )
	DButton.DoClick = function()
		if (not (not tonumber(c4_t:GetValue())))then 
			if tonumber(c4_t:GetValue())>=1 and tonumber(c4_t:GetValue())<=60 then
				surface.PlaySound("items/suitchargeok1.wav")
				net.Start("c4_datastream")
				net.WriteEntity(self)
				net.WriteFloat(c4_t:GetValue())
				net.SendToServer()
				
				win:SetVisible(false)
			
				
				
			end
		else
			surface.PlaySound("vo/npc/male01/answer11.wav")		
		end
		
	end

	c4_t.OnTextChanged=function()
		if (not (not tonumber(c4_t:GetValue())))then 
			if tonumber(c4_t:GetValue())>=1 and tonumber(c4_t:GetValue())<=60 then
				DButton:SetImage("icon16/tick.png")
			else
				DButton:SetImage("icon16/cross.png")			
			end
		else
			DButton:SetImage("icon16/cross.png")
		end
		
	end
	
	win:SetDeleteOnClose(true)
	win:MakePopup()
end)

function ENT:Use(activator,caller)
	if(not activator:IsPlayer())then return end
	if activator:KeyDown(IN_WALK) and self.AllowDetonate==true then
		net.Start("c4_diagbox")
		net.WriteEntity(self)
		net.Send(activator)
		self:EmitSound("buttons/button8.wav",100,100)
	end
end

function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end

function ENT:Think()
	if SERVER then
		if not self:IsValid() then return end
		for k, v in pairs(ents.FindInSphere(self:GetPos(),5)) do
			local phys = v:GetPhysicsObject()
			if v:GetClass() == "prop_door_rotating" or v:GetClass() == "func_door" or v:GetClass() == "func_door_rotating" or phys:IsValid() then
				constraint.Weld( self, v, 0, 0, 5000, true, false )
			end
		end
		self:NextThink(CurTime() + 0.1)
		return true
	end
end