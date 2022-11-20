---@class FireworksRocket : EntityClass
local base, self = entity("FireworksRocket")
if self.Initiated then return end

---Seconds before explosion
base.launch_time = 1.6

---Server time that the rocket launched
base.release_time = 0

local PARTICLES = {
    "particles/fireworks_blue.vpcf",
    "particles/fireworks_green.vpcf",
    "particles/fireworks_orange.vpcf",
    "particles/fireworks_purple.vpcf",
}

---Called automatically on spawn.
---@param spawnkeys CScriptKeyValues
function base:OnSpawn(spawnkeys)
end

---Called automatically on activate.
---Any self values set here are automatically saved.
---@param loaded boolean
function base:OnReady(loaded)
end

---Launches the rocket into the air.
function base:Launch()
    self:ResumeThink()
    self.release_time = Time()
    self:EmitSound("vinny.rocket")
    self:Drop()
    self:DisablePickup()
end

---Main entity think function. Think state is saved between loads.
function base:Think()
    if (Time() - self.release_time) >= self.launch_time then
        ParticleManager:SetParticleControl(
            ParticleManager:CreateParticle(RandomFromArray(PARTICLES), 0, Player),
            0,
            self:GetOrigin()
        )

        self:EmitSound("vinny.firework_explosion")
        self:Kill()
        return
    end
    self:ApplyAbsVelocityImpulse(self:GetUpVector() * 12)
    return 0
end

---@param context CScriptPrecacheContext
function Precache(context)
    PrecacheResource("sound", "vinny.rocket", context)
    PrecacheResource("sound", "vinny.firework_explosion", context)
    for _, pt in ipairs(PARTICLES) do
        PrecacheResource("particle", pt, context)
    end
end
