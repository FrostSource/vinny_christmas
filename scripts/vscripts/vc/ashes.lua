if thisEntity then if thisEntity:GetPrivateScriptScope().__load then return else thisEntity:GetPrivateScriptScope().__load = true end else return end

local FADE_AFTER_SPAWN = true

thisEntity:SetHealth(9999)
local enabled = false
local broken = false

local function Enable()
	enabled = true
end
Expose(Enable)
local function Disable()
	enabled = false
end
Expose(Disable)

---Breaks the urn with effects
local function Break()
	broken = true
	print("Urn: Creating ashes", 9999 - thisEntity:GetHealth())

	local startVector = thisEntity:GetCenter()

	---@type TraceTableLine
	local traceTable = {
		startpos = startVector,
		endpos = startVector - Vector(0, 0, 1024),
		ignore = thisEntity,
		mask = 0
	}
	TraceLine(traceTable)

	local ashes

	if traceTable.hit then
		local name = DoUniqueString("spawned_ashes")
		ashes = SpawnEntityFromTableSynchronous("prop_dynamic", {
			origin = Vector(traceTable.pos.x, traceTable.pos.y, (traceTable.pos.z - 0.4)),
			-- to do this I need to change model angle
			-- angles = VectorToAngles(traceTable.normal),
			model = "models/vinny_house/ashes.vmdl",
			solid = false,
			disableshadows = true,
			rendercolor = "195 195 195 255",
			targetname = name
		})
		if FADE_AFTER_SPAWN then
			local fader = SpawnEntityFromTableSynchronous("point_entity_fader", {
				target = name,
				curve = "<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->\n{\n\tm_spline = \n\t[\n\t\t{\n\t\t\tx = 0.0\n\t\t\ty = 1.0\n\t\t\tm_flSlopeIncoming = -1.0\n\t\t\tm_flSlopeOutgoing = -1.0\n\t\t},\n\t\t{\n\t\t\tx = 1.0\n\t\t\ty = 0.0\n\t\t\tm_flSlopeIncoming = -1.0\n\t\t\tm_flSlopeOutgoing = -1.0\n\t\t},\n\t]\n\tm_tangents = \n\t[\n\t\t{\n\t\t\tm_nIncomingTangent = \"CURVE_TANGENT_SPLINE\"\n\t\t\tm_nOutgoingTangent = \"CURVE_TANGENT_SPLINE\"\n\t\t},\n\t\t{\n\t\t\tm_nIncomingTangent = \"CURVE_TANGENT_SPLINE\"\n\t\t\tm_nOutgoingTangent = \"CURVE_TANGENT_SPLINE\"\n\t\t},\n\t]\n\tm_vDomainMins = [ 0.0, 0.0 ]\n\tm_vDomainMaxs = [ 1.0, 1.0 ]\n}"
			})
			local fade_start = 9
			fader:EntFire("Start", nil, fade_start)
			ashes:EntFire("Kill", nil, fade_start + 1.1)
		end
	else
		print("Urn: Trace failed")
	end

	local pt_pos = startVector
	if ashes then pt_pos = ashes:GetOrigin() end
	local p = ParticleManager:CreateParticle("particles/generic_fx/fx_dust.vpcf", 0, ashes or Player)
	ParticleManager:SetParticleControl(p, 0, pt_pos)
	p = ParticleManager:CreateParticle("particles/urn_ghost.vpcf", 0, ashes or Player)
	ParticleManager:SetParticleControl(p, 0, pt_pos)

	-- DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, nil, nil)
	thisEntity:EntFire("FireUser1")
	thisEntity:EntFire("Break")
end
Expose(Break)

---Tests if enough damage has occured to break
local function TestDamage()
	if not enabled or broken then
		print("Urn: Not enabled or broken")
		thisEntity:SetHealth(9999)
		return
	elseif (9999 - thisEntity:GetHealth()) < 50 then
		print("Urn: Not enough damage", 9999 - thisEntity:GetHealth())
		thisEntity:SetHealth(9999)
		return
	end
	Break()
end
Expose(TestDamage)

---@param spawnkeys CScriptKeyValues
function Spawn(spawnkeys)
	thisEntity:RedirectOutput("OnTakeDamage", "TestDamage", thisEntity)
end

---@param context CScriptPrecacheContext
function Precache(context)
	PrecacheModel("models/vinny_house/ashes.vmdl", context)
	PrecacheResource("particle", "particles/generic_fx/fx_dust.vpcf", context)
	PrecacheResource("particle", "particles/urn_ghost.vpcf", context)
end
