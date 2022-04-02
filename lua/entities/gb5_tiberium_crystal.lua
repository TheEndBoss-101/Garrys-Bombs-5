AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  false        
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Tiberium Crystal"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  ""

ENT.Model                            =  "models/rogue/tibe.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  300        
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  100
ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 self.EntList={}
	 self.EntCount = 0
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 local ent = ents.Create("gb5_base_radiation_draw_ent_fl")
	 ent:SetPos( self:GetPos() ) 
	 ent:Spawn()
	 ent:Activate()
	 ent.radowner = self
	 ent.RadRadius = 500
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
		
	 self:SetMaterial("models/rogue/tibe/tibe_0"..tostring(math.random(1,5)))
	 self.Exploded = false
	 self:SetMoveType(MOVETYPE_NONE)
	 self:SetPersistent( true )
	 
	 
	 timer.Simple(math.random(1,122), function()
		if not self:IsValid() then return end
		self:Remove()
	 end)
	end
end

function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 130,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 130,1)
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

if (CLIENT) then
	function Radiation()
		surface.SetDrawColor(Color(255,255,255,50))
		draw.NoTexture()
		surface.DrawRect(0,0,ScrW(),ScrH())
		LocalPlayer():SetAngles(Angle(-90,0,0)) 
		hook.Add( "HUDPaint", "Radiation", Radiation )
	    timer.Simple(0.1, function()
			hook.Remove( "HUDPaint", "Radiation", Radiation )
		end)
	end
	concommand.Add( "Rad", Radiation )
end

function ENT:SpawnCrystal()
	local crystals = 0
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass()=="gb5_tiberium_crystal" then
			crystals = crystals + 1
		end
	end

	if crystals < 100 then
	
		local offset = Vector(math.random(-1400,1400),math.random(-1400,1400),0)
		local tr = util.TraceLine( {
			start = self:GetPos()+Vector(0,0,1000)+offset, 
			endpos = self:GetPos()-Vector(0,0,1500)+offset
		} )
		local ent = ents.Create("gb5_tiberium_crystal" )
		ent:SetPos( tr.HitPos )  
		ent:Spawn()
		ent:Activate()
		ent:EmitSound("npc/stalker/breathing3.wav", 80, 100)
	end


end


function ENT:Spread()
	if math.random(1,2)==2 then
		self:SpawnCrystal()
	end
	
end

function ENT:Think(ply) 
	self.spawned = true
    if (SERVER) then 
	if not self.spawned then return end
	local pos = self:GetPos()
	local dmg = DamageInfo()
	self:Spread()
	for k, v in pairs(ents.FindInSphere(pos,530)) do
		if (v:IsPlayer() or v:IsNPC()) and v.hazsuited==false and self:IsValid() then
		
			if not v:IsValid() then return end
			dmg:SetDamage(math.random(11,23))
			dmg:SetDamageType(DMG_RADIATION)
			if self.GBOWNER == nil then
				self.GBOWNER = table.Random(player.GetAll())
			end
			dmg:SetAttacker(self.GBOWNER)
			v:EmitSound("player/geiger3.wav", 100, 100)
			v:TakeDamageInfo(dmg)
			if not v:IsNPC() then
				v:ConCommand("Rad")
			end
		end
	end
	
	self:NextThink((CurTime() + math.random(1,3)))
	return true
	end
end
