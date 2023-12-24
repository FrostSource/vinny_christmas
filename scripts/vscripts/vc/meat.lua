
-- This script is a customized version of Valve's template NPC script.
-- Their comments left here for clarity sake.

---@class Meat : EntityClass
local base, self = entity("Meat")
if self.Initiated then return end

base.FollowPlayer = false
base.GrowlEnabled = false
base.IsWandering = false
base.WanderEnabled = false
-- self.MeatThinking = false

function base:OnReady(loaded)
end

--=============================
-- Script configuration parameters
--=============================
-- How long to wait between calls to create a new path. 
-- Creating a path can be expensive because it performs a lot of traces to check 
-- for collisions with other objects and characters.  So this code puts a time 
-- limit on how frequently a new path can be calculated to help prevent spamming 
-- the path system
local flRepathTime = 1.0

-- The last game time a new path was created
local flLastPathTime = 0.0

-- The closest that the entity should get to the player
local flMinPlayerDist = 40

-- The farthest the entity should get to the player
local flMaxPlayerDist = 100

-- The maximum distance away from the navigation goal that a path can be considered successful
local flNavGoalTolerance = 250

-- If meat is this far away for long enough he will wander the house
local distToWander = 50
-- If meat is far away for this many seconds he will wander the house
local timeToWander = 5--40
-- How long to stay at a point of interest
local timeAtWanderPosition = 5--60

---@type number|nil
local lastWanderTime = nil


-- Whether the player should walk or run when following a path.  
-- This choice affects the target speed that is passed to the AnimGraph,
-- and how much curve the pathing system should use when creating corners.
-- The walk and run speeds of characters are defined in the Movement Settings
-- node on the model in ModelDoc
local bShouldRun = true

local TimeBetweenGrowls = 13
local GrowlTimeMin = 10
local GrowlTimeMax = 25
local GrowlDistance = 120
local GrowlDistanceZ = 20
local LastGrowlTime = 0.0
local MeatMouthScoreDistance = 70
local MeatMouthScoreLastTime = 0

function base:EnableGrowl()
	print('Meat: EnableGrowl')
	self.GrowlEnabled = true
	self:Save()
end
function base:DisableGrowl()
	print('Meat: DisableGrowl')
	self.GrowlEnabled = false
	self:Save()
end

function base:EnableFollow()
	print('Meat: EnableFollow')
	self.FollowPlayer = true
	self.IsWandering = false
	self:Save()
end
function base:DisableFollow()
	print('Meat: DisableFollow')
	self.FollowPlayer = false
	self.IsWandering = false
	self:NpcNavClearGoal()
	self:Save()
end
function base:EnableWander()
	print('Meat: EnableWander')
	self.WanderEnabled = true
	self.IsWandering = false
	self:Save()
end
function base:DisableWander()
	print('Meat: DisableWander')
	self.WanderEnabled = false
	self.IsWandering = false
	self:Save()
end

-- Only exists for the print
function base:StartThinking()
	print('Meat: StartThinking')
	self:ResumeThink()
end
-- Only exists for the print
function base:StopThinking()
	print('Meat: StopThinking')
	self:PauseThink()
end

function base:CancelWander()
	self.IsWandering = false
	self:Save()
end

function base:Growl()
	--print("Big meaty growl")
	StartSoundEventFromPosition("meat.growl", self:GetOrigin() + Vector(-0.000178, 5.82063, -2.51945))
end

function base:TestMouthScore()
	local player = Player
	local dist = VectorDistance(player:GetOrigin(), self:GetOrigin())

	-- print('meat mouth score')
	if dist >= MeatMouthScoreDistance and Time() - MeatMouthScoreLastTime > 5 then
		-- print('meat mouth score done')
		StartSoundEvent('vinny.meat_thrown_food', player)
		MeatMouthScoreLastTime = Time()
		self:FireOutput("OnUser1", self, self, nil, 0)
	end
end

--=============================
-- Create a path to a point that is flMinPlayerDist from the player
-- Note: Always try to create a path to where you want to entity to stop, rather than cancelling the path
-- when it gets close enough.  This allows the AnimGraph to anticipate the goal and choose to play a stopping
-- animation if one is available
--=============================
---@param ent EntityHandle
function base:CreatePathToEntity( ent )
	--print('Meat: Creating path to player')

	-- Find the vector from this entity to the player
	local vVecToPlayerNorm = ( ent:GetAbsOrigin() - self:GetAbsOrigin() ):Normalized()

	-- Then find the point along that vector that is flMinPlayerDist from the player
	local vGoalPos = ent:GetAbsOrigin() - ( vVecToPlayerNorm * flMinPlayerDist );

	-- Create a path to that goal.  This will replace any existing path
	-- The path gets sent to the AnimGraph, and its up to the graph to make the character
	-- walk along the path
	self:NpcForceGoPosition( vGoalPos, bShouldRun, flNavGoalTolerance )

	flLastPathTime = Time()
end

---Last place Meat went, doesn't need to be saved
---@type EntityHandle
local lastPointOfInterest

function base:GoToPointOfInterest()
	local points = Entities:FindAllByName("meat_poi")
	if lastPointOfInterest ~= nil then
		Util.RemoveFromTable(points, lastPointOfInterest)
	end
	local point = ArrayRandom(points)

	if IsValidEntity(point) then
		self:CreatePathToEntity(point)
	end
end

function OnEntText()
	
	-- Return the string to display on entity
	return "\nIsWandering: "..tostring(self.IsWandering)
			.."\nWanderEnabled: "..tostring(self.WanderEnabled)
			.."\nWanderTime: "..tostring(lastWanderTime ~= nil and (Time() - lastWanderTime) or "nil").." > "..timeToWander
			.."\nTimeAtWanderPos: "..tostring(Time() - flLastPathTime).." > "..timeAtWanderPosition
end

--=============================
-- Think function for the script, called roughly every 0.1 seconds.
--=============================
function base:Think()

	local player = Player
	local dist_to_player = ( player:GetAbsOrigin() - self:GetAbsOrigin() ):Length()
	local z_diff = abs(player:GetAbsOrigin().z - self:GetAbsOrigin().z)

	-- Meat will only growl if close enough and on same level as player
	if self.GrowlEnabled
	and dist_to_player < GrowlDistance
	and z_diff < GrowlDistanceZ
	and (Time() - LastGrowlTime) > TimeBetweenGrowls
	then
		-- print("Meat: Growl")
		self:Growl()
		LastGrowlTime = Time()
		TimeBetweenGrowls = RandomFloat(GrowlTimeMin, GrowlTimeMax)
	end

	if self.FollowPlayer then

		if player ~= nil then

			if self.IsWandering then

				local vCurrentGoalPos = self:NpcNavGetGoalPosition()
				local flDistToGoal = ( self:GetAbsOrigin() - vCurrentGoalPos ):Length()
				local flTimeSincePath = Time() - flLastPathTime

				if dist_to_player <= flMinPlayerDist then
					LastGrowlTime = 0
					self.IsWandering = false
					print("Meat: Ending wander")
					return 0.1
				end

				if (flDistToGoal <= flMinPlayerDist or not self:NpcNavGoalActive()) and flTimeSincePath >= timeAtWanderPosition then
					self:GoToPointOfInterest()
				end

			else

				-- Set the look target on the AnimGraph to be the position of the players eyes.  
				self:SetGraphLookTarget( player:EyePosition() )

				-- If the entity is too close to the player and still has an active path, then
				-- cancel the path to make it stop moving
				--local flDistToPlayer = ( localPlayer:GetAbsOrigin() - self:GetAbsOrigin() ):Length()

				if ( dist_to_player < flMinPlayerDist ) and ( self:NpcNavGoalActive() ) then
					self:NpcNavClearGoal()
				end

				-- If the entity is too far from the player...
				if ( dist_to_player > flMaxPlayerDist ) then

					-- Check if meat should wander
					if self.WanderEnabled and dist_to_player > distToWander then
						if lastWanderTime == nil then
							lastWanderTime = Time()
						end
						if Time() - lastWanderTime > timeToWander then
							lastWanderTime = nil
							self.IsWandering = true
							self:GoToPointOfInterest()
							print("Meat: Starting wander")
							return 0.1
						end
					end

					-- If the entity does not already have a path
					if ( not self:NpcNavGoalActive() ) then

						-- Create a path that ends near the player
						self:CreatePathToEntity(player)
					else
						local vCurrentGoalPos = self:NpcNavGetGoalPosition()
						local flDistPlayerToGoal = ( player:GetAbsOrigin() - vCurrentGoalPos ):Length()
						local flTimeSincePath = Time() - flLastPathTime

						-- If the player has moved away from the path goal and we haven't changed the path recently
						-- then calculate a new path
						if ( flDistPlayerToGoal > flMinPlayerDist ) and ( flTimeSincePath > flRepathTime ) then
							self:CreatePathToEntity(player)
						end
					end
				end

			end
		end
	end

	-- Return the amount of time to wait before calling this function again.
	return 0.1
end

