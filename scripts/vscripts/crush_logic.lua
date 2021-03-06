
local EntityTable = {}

function Spawn(spawnkeys)
	
end

function Activate()

end

function AddProp(data)
	--print(data.activator:GetClassname())
	--print(data.caller:GetClassname())
	-- Destroy/kill if ent is already touching one wall (squished)
	if EntityTable[data.activator] == true or data.activator:HasAttribute('static') then
		local damage = CreateDamageInfo(thisEntity, thisEntity, Vector(), Vector(), 9999, 1)
		if data.activator:IsPlayer() then
			DoEntFire('!self', 'FireUser1', '', 0, thisEntity, thisEntity)
		end
		data.activator:TakeDamage(damage)
		DestroyDamageInfo(damage)
		EntityTable[data.activator] = nil
	else
		EntityTable[data.activator] = true
	end
end

function RemoveProp(data)
	if EntityTable[data.activator] == true then
		EntityTable[data.activator] = nil
	end
end

