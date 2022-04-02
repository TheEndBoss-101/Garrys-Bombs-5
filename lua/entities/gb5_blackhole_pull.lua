AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 local pos = self:GetPos()
                 self.PULLPLY = 0
                 self.PULLPROP = 0
     end
end
function ENT:Think()
     if (SERVER) then
     if not self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+self.SHOCKWAVE_INCREMENT
	 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
		 if v:IsValid() or v:IsPlayer() then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if (phys:IsValid()) then
					 local mass = phys:GetMass()
					 local F_ang = self.PULLPROP
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.PULLPROP
					 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
					 phys:AddVelocity(F_dir)
				 end
				 if (v:IsPlayer()) then
					 v:SetMoveType( MOVETYPE_WALK )
					 local mass = phys:GetMass()
					 local F_ang = self.PULLPLY
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.PULLPLY	 
					 v:SetVelocity( F_dir )		
				 end
			 i = i + 1
			 end
		 end
 	 end
	 for k, v in pairs(ents.FindInSphere(pos,100)) do
		 if v:IsValid() or v:IsPlayer() then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if (phys:IsValid() and not v:IsPlayer()) then
					v:Remove()
				 end
				 if (v:IsPlayer()) or (v:IsNPC()) then
					 local dmg = DamageInfo()
			         dmg:SetDamage(math.random(100))
			         dmg:SetDamageType(DMG_RADIATION)
			         dmg:SetAttacker(self.GBOWNER)
					 v:TakeDamageInfo(dmg)
				 end
			 i = i + 1
			 end
		 end
 	 end
	 self.PULLPLY = self.PULLPLY-25
         self.PULLPROP = self.PULLPROP-2
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DELAY)
	 return true
	 end
end

function ENT:Draw()
     return false
end