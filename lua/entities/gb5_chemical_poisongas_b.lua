AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.Plylist={}
		 self.EntList={}
		 if self.RadRadius==nil then
			self.RadRadius=500
		 end
		 if self.Burst==nil then
			self.Burst = 10
		 end
		 
     end
end
function ENT:ConfigureRadius()
	self:SetNWFloat("Radius", self.RadRadius)
	self.RadRadius=(1240/30)*self.Bursts
end
function ENT:DoTraces(trg_ent)
	local entity = nil
	for i=0,11 do	
		local tr = util.TraceLine( {
			start = self:GetPos(), 
			endpos = trg_ent:GetPos()+Vector(0,0,10*i)
		} )
		if tr.Entity==trg_ent then 
			entity = trg_ent 
			break
		end
		
	end
	
	if entity==nil then return false end
	if entity~=nil then return true end
end

function ENT:Think()
	if (CLIENT) then
		function PoisonGas()
			DrawMotionBlur( LocalPlayer():GetNWFloat("addalpha", 0), LocalPlayer():GetNWFloat("drawalpha", 0), LocalPlayer():GetNWFloat("delay", 0) )
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0 
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0 
			tab[ "$pp_colour_brightness" ] = LocalPlayer():GetNWFloat("contrast", 0)
			tab[ "$pp_colour_contrast" ] = 1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0 
			DrawColorModify( tab )
			
		end
		hook.Add( "RenderScreenspaceEffects", "PoisonGas", PoisonGas)
	end
	if (SERVER) then
	if not self:IsValid() then return end
	local pos = self:GetPos()
	
	self:ConfigureRadius()
	
	
	
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(pos,self.RadRadius)) do
		if v:IsPlayer() and not v:IsNPC() and v.gasmasked==false then
			

			
			
			if self:DoTraces(v)==true then
				
				if v.accumilation == nil then 
					v.accumilation = 1
				end
				
				v.accumilation = v.accumilation+1
				if v.accumilation/1000 >= 1 then
					v.accumilation = 1000
				end
				v:SetRunSpeed(500-(v.accumilation/2.1))
				v:SetWalkSpeed(500-(v.accumilation/2.1))
				v:SetNWFloat("delay", v.accumilation/2000  )
				v:SetNWFloat("addalpha", v.accumilation/20000 )
				v:SetNWFloat("drawalpha", v.accumilation/1100 )
				v:SetNWFloat("contrast", v.accumilation/1000 )
				v:SetNWFloat("Affected", 1)
				

				table.insert(self.Plylist,v)
				table.insert(self.TotalList, v )
			end
		end
	end

	for k, v in pairs(self.TotalList) do
		if v:IsValid() then 
			if not table.HasValue(self.EntList,v) then
				if v:IsPlayer() then
					table.insert(self.EntList, v )
				end
			end
		end
	end
	for index, entlist_ply in pairs(self.EntList) do
		if entlist_ply:IsValid() then
			if not table.HasValue(self.TotalList, entlist_ply ) then
				if entlist_ply:IsValid() then
					table.remove(self.EntList, index)
					entlist_ply.accumilation=0
					entlist_ply:SetNWFloat("drawalpha", 0  )
					entlist_ply:SetNWFloat("delay", 0  )
					entlist_ply:SetNWFloat("Affected", 0)
					entlist_ply:SetNWFloat("contrast", 0 )
					entlist_ply:SetRunSpeed(500)
					entlist_ply:SetWalkSpeed(250)
				end
			end
		end
	end
	self.Bursts = self.Bursts + 0.01
	if (self.Bursts >= self.Burst) then
		self:Remove()
	end
	self:NextThink(CurTime() + 0.01)
	return true
	end
end
function ENT:OnRemove()
	if (CLIENT) then
		if (LocalPlayer():GetNWFloat("Affected")) then
		end
	end
	if (SERVER) then
		for k, v in pairs(self.Plylist) do
			if v:IsValid() then
				if v:GetNWFloat("Affected", 0) then
					v:SetNWFloat("contrast", 0 )
					v:SetNWFloat("delay", 0)
					v.accumilation=0
					v:SetNWFloat("drawalpha",0)
					v:SetRunSpeed(500)
					v:SetWalkSpeed(250)
				end
			end
		end
	end
end
local laser = Material( "cable/redlaser" )
 
function ENT:Draw()
	return true
end
