
eHandles = eHandles or {}
local vMoveVector = Vector(0,100,0)

function Activate(activateType)
	if thisEntity:GetClassname() ~= 'prop_door_rotating_physics' then return end

	local handlepos = thisEntity:GetAbsOrigin() - (thisEntity:GetRightVector() * 36) + (thisEntity:GetUpVector() * 45)
	--debugoverlay:Sphere(handlepos,8,255,255,255,255,true,10000)
	local handles
	if activateType == 2 then
		handles = Entities:FindAllByClassname('prop_animinteractable')
		--print('Num POSSIBLE door handles found after LOAD - '..#handles)
		for _,handle in ipairs(handles) do
			if handle:GetContext('belongname') == thisEntity:GetName()..'handle' then
				eHandles[#eHandles+1] = handle
			end
		end
		--print('Actually found', #eHandles)
	else
		handles = Entities:FindAllByClassnameWithin('prop_animinteractable', handlepos, 32)
		--print('Num door handles found on spawn - '..#handles)
		for _,handle in ipairs(handles) do
			eHandles[#eHandles+1] = handle
			local pos = handle:GetLocalOrigin()
			handle:SetContext('belongname', thisEntity:GetName()..'handle', 0)
			handle:Attribute_SetFloatValue('startx', pos.x)
			handle:Attribute_SetFloatValue('starty', pos.y)
			handle:Attribute_SetFloatValue('startz', pos.z)
		end
	end

end

function HideHandles()
	--for i=1,iNumHandles do
	--	eHandles[i]:SetLocalOrigin(vStartPos[i] - vMoveVector)
	--end
	for _,handle in ipairs(eHandles) do
		local x = handle:Attribute_GetFloatValue('startx', 0)
		local y = handle:Attribute_GetFloatValue('starty', 0)
		local z = handle:Attribute_GetFloatValue('startz', 0)
		local pos = Vector(x, y, z)
		handle:SetLocalOrigin(pos - vMoveVector)
	end
end

function RestoreHandles()
	--for i=1,iNumHandles do
	--	eHandles[i]:SetLocalOrigin(vStartPos[i])
	--end
	--print('Num handles on restore', #eHandles)
	for _,handle in ipairs(eHandles) do
		local x = handle:Attribute_GetFloatValue('startx', 0)
		local y = handle:Attribute_GetFloatValue('starty', 0)
		local z = handle:Attribute_GetFloatValue('startz', 0)
		local pos = Vector(x, y, z)
		--print('Restoring handle to', tostring(pos))
		handle:SetLocalOrigin(pos)
	end
end