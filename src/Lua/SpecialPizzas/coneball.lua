freeslot("MT_CONEBALL_HAIL", "S_CONEBALL_HAIL", "S_CONEBALL_HAIL_LAND", "S_CONEBALL_PARTICLE")

mobjinfo[MT_CONEBALL_HAIL] = {
	spawnstate = S_CONEBALL_HAIL,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 30*FU,
	height = 30*FU,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_SPECIAL
}
states[S_CONEBALL_HAIL] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|Y,
    tics = -1,
    var1 = 5,
    var2 = 2,
    nextstate = S_CONEBALL_HAIL
}
states[S_CONEBALL_HAIL_LAND] = {
    sprite = SPR_CONB,
    frame = Z+1+4,
    tics = -1,
    nextstate = S_CONEBALL_HAIL_LAND
}
states[S_CONEBALL_PARTICLE] = {
    sprite = SPR_CONB,
    frame = Z+11+G, -- lowercase g frame
    tics = TICRATE,
    nextstate = S_NULL
}

local STABSPEED = 1

freeslot("SPR_CONA", "S_CONEBALL_PINK", "S_CONEBALL_TRANSFORM", "S_CONEBALL_ATTACK")
states[S_CONEBALL_TRANSFORM] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|FF_FULLBRIGHT|(Z+1+5),
    tics = 21,
    var1 = 10,
    var2 = 2,
    nextstate = S_CONEBALL_PINK
}
states[S_CONEBALL_PINK] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|FF_FULLBRIGHT|Q,
    tics = -1,
    var1 = 7,
    var2 = 2,
    nextstate = S_CONEBALL_PINK
}
states[S_CONEBALL_ATTACK] = {
    sprite = SPR_CONA,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = 26*STABSPEED,
    var1 = Z+1,
    var2 = STABSPEED,
    nextstate = S_CONEBALL
}


local function isConeball(pizza)
    return PTSR.PFMaskData[pizza.pizzastyle or 1].special == "coneball"
end
local function isConeballingOnSomeone(pizza)
    return (
        isConeball(pizza)
        and pizza.pizza_target
        and pizza.pizza_target.valid
        and pizza.pizza_target.player
        and pizza.pizza_target.gettingConeballedOn
        and pizza.pizza_target.gettingConeballedOn.pizza == pizza
    )
end

PTSR_AddHook("pfpredamage", function (playermo, pizza)
    if isConeball(pizza) then
        if not playermo.gettingConeballedOn then
            playermo.gettingConeballedOn = {
                pizza = pizza,
                tics = 0
            }
        elseif playermo.gettingConeballedOn.pizza != pizza then
            PTSR.DoParry(playermo, pizza)
        end
        return true
    end
end)

PTSR_AddHook("preparry", function (playermo, pizza)
    if isConeballingOnSomeone(pizza) then
        return true
    end
end)

local function stabby(pizza)
    for p in players.iterate do
        if (
            p and p.valid and p.mo and p.mo.valid
            and PTSR.PlayerIsChasable(p)
            and R_PointToDist2(
                R_PointToDist2(p.mo.x, p.mo.y, pizza.x, pizza.y), p.mo.z+p.mo.height/2,
                0, pizza.z+pizza.height/2
            ) < 92*FU
        ) then
            P_KillMobj(p.mo, pizza)
        end
    end
end

PTSR_AddHook("pfprestunthink", function (pizza)
    if isConeballingOnSomeone(pizza) then
        local target = pizza.pizza_target
        if not PTSR.PlayerIsChasable(target.player) then
            target.gettingConeballedOn = nil
            return
        end
        local cone = target.gettingConeballedOn
        cone.tics = $ + 1

        pizza.momx = 0
        pizza.momy = 0
        pizza.momz = 0

        if cone.tics < 150 then
            local dist_mul = min(cone.tics * 4, 75)
            if cone.tics > 75 then
                local inv = 150 - cone.tics
                dist_mul = min(inv * 4, 75)
            end
            P_MoveOrigin(
                pizza,
                target.x + sin(leveltime*ANG2*2)*dist_mul,
                target.y + cos(leveltime*ANG2*2)*dist_mul,
                target.z
            )
            if pizza.state != S_CONEBALL_TRANSFORM and pizza.state != S_CONEBALL_PINK then
                pizza.state = S_CONEBALL_TRANSFORM
            end
        end

        -- hail
        local modulo = 3
        if PTSR.timeover then
            modulo = 2
        end
        if cone.tics < 120 and cone.tics % modulo == 0 then
            local randr = P_RandomRange(50, 400)
            local randx = P_RandomRange(-randr, randr)*FU
            local randy = P_RandomRange(-randr, randr)*FU
            local hail = P_SpawnMobjFromMobj(
                target,
                randx,
                randy,
                1500*FU,
                MT_CONEBALL_HAIL
            )
            hail.fuse = TICRATE*5
            hail.momx = 3*target.momx/2 + -randx/80
            hail.momy = 3*target.momy/2 + -randy/80
            hail.momz = P_MobjFlip(target)*FU*-120
            -- hail.spritexscale = $*2
            -- hail.spriteyscale = $*2
            hail.target = target
        end

        -- stabby
        if cone.tics == 150 then
            pizza.state = S_CONEBALL_ATTACK
        end

        if cone.tics >= (150+9*STABSPEED) and cone.tics < (150+18*STABSPEED) then
            stabby(pizza)
        end

        if cone.tics > 155 and pizza.state != S_CONEBALL_ATTACK then
            target.gettingConeballedOn = nil
            PTSR.DoParry(target, pizza)
            pizza.momx = $*2
            pizza.momy = $*2
            pizza.momz = $*3
        end

        return true
    elseif isConeball(pizza) then
        pizza.pfspeedmulti = 5*FU/3
        if pizza.state == S_CONEBALL_ATTACK then
            pizza.momx = 0
            pizza.momy = 0
            pizza.momz = 0
            if pizza.frame >= J and pizza.frame < S then
                stabby(pizza)
            end
            return true -- finish the attack
        end
        if pizza.state != S_CONEBALL then
            pizza.state = S_CONEBALL
        end
    end
end)

addHook("MobjThinker", function (mo)
    if mo.flags & MF_NOCLIPHEIGHT and not mo.hailLanded then
        local floor = mo.floorz
        if mo.eflags & MFE_VERTICALFLIP then
            floor = mo.ceilingz
        end
        -- print(floor, mo.z, mo.momz * 2)
        if abs(floor - mo.z) < abs(mo.momz*2) then
            mo.flags = $ & ~MF_NOCLIPHEIGHT
        end
    elseif not mo.hailLanded then
        if P_IsObjectOnGround(mo) then
            mo.momx = 0
            mo.momy = 0
            mo.momz = 0
            mo.state = S_CONEBALL_HAIL_LAND
            mo.hailLanded = true
        end
    elseif mo.fuse == 20 then
        mo.flags = $ | MF_NOCLIPHEIGHT
        mo.momz = -P_MobjFlip(mo)*FU/2
    end
end, MT_CONEBALL_HAIL)

local MAXICECREAM = 75
local SOFTMAXICECREAM = 50
local MAXSLOW = 8*FU/100
addHook("TouchSpecial", function (special, toucher)
    toucher.coneballIcecreamed = min(($ or 0)+2, MAXICECREAM)
    return true
end, MT_CONEBALL_HAIL)

addHook("PlayerThink", function (p)
    if (
        p.valid and p.mo and p.mo.valid
        and p.mo.coneballIcecreamed
        and p.mo.coneballIcecreamed > 0
    ) then
        if not PTSR.PlayerIsChasable(p) then
            p.mo.coneballIcecreamed = 0
            return
        end

        local mult = FU - (p.mo.coneballIcecreamed*MAXSLOW/MAXICECREAM)
        print(p.mo.coneballIcecreamed .. " icecream")
        p.mo.momx = FixedMul($, mult)
        p.mo.momy = FixedMul($, mult)
        -- p.mo.momz = FixedMul($, mult) -- this feels weird and also breaks springs

        local c = P_RandomRange(1, p.mo.coneballIcecreamed)/5
        local rdfu = p.mo.radius/p.mo.scale
        for i = 1,c do
            local particle = P_SpawnMobjFromMobj(
                p.mo,
                P_RandomRange(-rdfu, rdfu)*FU,
                P_RandomRange(-rdfu, rdfu)*FU,
                P_RandomRange(0, p.mo.height/p.mo.scale)*FU,
                MT_THOK
            )
            particle.state = S_CONEBALL_PARTICLE
            particle.fuse = -1
            particle.flags = $ & ~MF_NOGRAVITY
        end

        if leveltime % 7 == 0 or p.mo.coneballIcecreamed > SOFTMAXICECREAM then
            p.mo.coneballIcecreamed = $ - 1
        end
    end
end)