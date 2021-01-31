
function Spawn() 
	-- Registers a function to get called each time the entity updates, or "thinks"
	--thisEntity:SetContextThink(nil, MainThinkFunc, 0)
end

function Activate(activateType)
	-- Register a function to receive callbacks from the AnimGraph of this entity
	-- when Status Tags are emitted by the graph.  This must be called in Activate
	-- because the AnimGraph has not been loaded yet when Spawn is called
	thisEntity:RegisterAnimTagListener( AnimTagListener )

	if activateType == 2 then
		print('Loading MEAT attributes')
		if thisEntity:Attribute_GetIntValue('MeatFollowing', 0) == 1 then
			EnableFollow()
		end
		if thisEntity:Attribute_GetIntValue('MeatGrowling', 0) == 1 then
			EnableGrowl()
		end
		if thisEntity:Attribute_GetIntValue('MeatThinking', 0) == 1 then
			StartThinking()
		end
	end
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
local flMaxPlayerDist = 90

-- The maximum distance away from the navigation goal that a path can be considered successful
local flNavGoalTolerance = 250

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
GrowlEnabled = GrowlEnabled or false
FollowPlayer = FollowPlayer or false

function EnableGrowl()
	print('Meat: EnableGrowl')
	GrowlEnabled = true
	thisEntity:Attribute_SetIntValue('MeatGrowling', 1)
end
function DisableGrowl()
	print('Meat: DisableGrowl')
	GrowlEnabled = false
	thisEntity:Attribute_SetIntValue('MeatGrowling', 0)
end

function EnableFollow()
	print('Meat: EnableFollow')
	FollowPlayer = true
	thisEntity:Attribute_SetIntValue('MeatFollowing', 1)
end
function DisableFollow()
	print('Meat: DisableFollow')
	FollowPlayer = false
	thisEntity:NpcNavClearGoal()
	thisEntity:Attribute_SetIntValue('MeatFollowing', 0)
end

function StartThinking()
	print('Meat: StartThinking')
	thisEntity:SetThink(MainThinkFunc, 'MainThinkFunc', 0)
	thisEntity:Attribute_SetIntValue('MeatThinking', 1)
end
function StopThinking()
	print('Meat: StopThinking')
	thisEntity:StopThink('MainThinkFunc')
	thisEntity:Attribute_SetIntValue('MeatFollowing', 0)
end

function Growl()
	--print("Big meaty growl")
	-- Does this play at origin? (feet)
	--thisEntity:EmitSound("Addon.MeatGrowl")
	StartSoundEventFromPosition("Addon.MeatGrowl", thisEntity:GetOrigin() + Vector(-0.000178, 5.82063, -2.51945))
end

--=============================
-- Think function for the script, called roughly every 0.1 seconds.
--=============================
function MainThinkFunc() 

	local localPlayer = Entities:GetLocalPlayer()
	local flDistToPlayer = ( localPlayer:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Length()
	local flZDiff = abs(localPlayer:GetAbsOrigin().z - thisEntity:GetAbsOrigin().z)

	if GrowlEnabled and flDistToPlayer < GrowlDistance and flZDiff < GrowlDistanceZ and Time() - LastGrowlTime > TimeBetweenGrowls then
		Growl()
		LastGrowlTime = Time()
		TimeBetweenGrowls = RandomFloat(GrowlTimeMin,GrowlTimeMax)
	end
	
	if FollowPlayer then

		if localPlayer ~= nil then

			-- Set the look target on the AnimGraph to be the position of the players eyes.  
			thisEntity:SetGraphLookTarget( localPlayer:EyePosition() )

			-- If the entity is too close to the player and still has an active path, then
			-- cancel the path to make it stop moving
			--local flDistToPlayer = ( localPlayer:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Length()

			if ( flDistToPlayer < flMinPlayerDist ) and ( thisEntity:NpcNavGoalActive() ) then
					thisEntity:NpcNavClearGoal()
			end

			-- If the entity is too far from the player...
			if ( flDistToPlayer > flMaxPlayerDist ) then
				
				-- If the entity does not already have a path
				if ( not thisEntity:NpcNavGoalActive() ) then

					-- Create a path that ends near the player
					CreatePathToPlayer(localPlayer)
				else
					local vCurrentGoalPos = thisEntity:NpcNavGetGoalPosition()
					local flDistPlayerToGoal = ( localPlayer:GetAbsOrigin() - vCurrentGoalPos ):Length()
					local flTimeSincePath = Time() - flLastPathTime

					-- If the player has moved away from the path goal and we haven't changed the path recently
					-- then calculate a new path
					if ( flDistPlayerToGoal > flMinPlayerDist ) and ( flTimeSincePath > flRepathTime ) then
						CreatePathToPlayer(localPlayer)
					end
				end
			end
		end
	end

	-- Return the amount of time to wait before calling this function again.
	return 0.1
end


--=============================
-- Create a path to a point that is flMinPlayerDist from the player
-- Note: Always try to create a path to where you want to entity to stop, rather than cancelling the path
-- when it gets close enough.  This allows the AnimGraph to anticipate the goal and choose to play a stopping
-- animation if one is available
--=============================
function CreatePathToPlayer( localPlayer )
	--print('Meat: Creating path to player')

	-- Find the vector from this entity to the player
	local vVecToPlayerNorm = ( localPlayer:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Normalized()

	-- Then find the point along that vector that is flMinPlayerDist from the player
	local vGoalPos = localPlayer:GetAbsOrigin() - ( vVecToPlayerNorm * flMinPlayerDist );

	-- Create a path to that goal.  This will replace any existing path
	-- The path gets sent to the AnimGraph, and its up to the graph to make the character
	-- walk along the path
	thisEntity:NpcForceGoPosition( vGoalPos, bShouldRun, flNavGoalTolerance )

	flLastPathTime = Time()
end
