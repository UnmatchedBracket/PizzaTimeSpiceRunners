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

freeslot("SPR_CONA", "S_CONEBALL_PINK", "S_CONEBALL_TRANSFORM", "S_CONEBALL_ATTACK", "S_CONEBALL_DETRANSFORM")
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
states[S_CONEBALL_DETRANSFORM] = {
    sprite = SPR_CONA,
    frame = FF_ANIMATE|FF_FULLBRIGHT|(Z+2),
    tics = 18,
    var1 = 9,
    var2 = 2,
    nextstate = S_CONEBALL
}

local PHASE = {
    STARTUP = -1,
    TRANSFORM = 0,
    HAIL = 1,
    DETRANSFORM = 2,
    STAB = 3
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
                tics = 0,
                phase = PHASE.STARTUP,
                hoverdist = 0
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
    if CV_PTSR.nuhuh.value then return end
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
        if cone.phase == PHASE.STARTUP then
            cone.phase = PHASE.TRANSFORM
            if PTSR.timeover and P_RandomChance(FU/2) then
                -- jump to stabbing
                cone.phase = PHASE.DETRANSFORM
            end
        end
        cone.tics = $ + 1
        -- print(cone.phase)
        if cone.phase == PHASE.TRANSFORM then
            if pizza.state == S_CONEBALL_PINK then
                cone.phase = PHASE.HAIL
                cone.tics = 0
            elseif pizza.state ~= S_CONEBALL_TRANSFORM then
                pizza.state = S_CONEBALL_TRANSFORM
            end
        elseif cone.phase == PHASE.HAIL then
            local modulo = 3
            if PTSR.timeover then
                modulo = 2
            end
            if cone.tics % modulo == 0 then
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
            if cone.tics >= TICRATE*3 then
                cone.phase = PHASE.DETRANSFORM
            end
        elseif cone.phase == PHASE.DETRANSFORM then
            if pizza.state == S_CONEBALL then
                cone.phase = PHASE.STAB
                cone.tics = 0
                pizza.momx = target.momx
                pizza.momy = target.momy
                pizza.momz = target.momz
            elseif pizza.state ~= S_CONEBALL_DETRANSFORM then
                pizza.state = S_CONEBALL_DETRANSFORM
            end
        elseif cone.phase == PHASE.STAB then
            if pizza.state ~= S_CONEBALL_ATTACK then
                if cone.tics >= (18*STABSPEED) then
                    target.gettingConeballedOn = nil
                    if not PTSR.timeover then
                        PTSR.DoParry(target, pizza)
                        -- pizza.momx = $*2
                        -- pizza.momy = $*2
                        -- pizza.momz = $*3
                    end
                else
                    pizza.state = S_CONEBALL_ATTACK
                end
            end
            if cone.tics >= (9*STABSPEED) and cone.tics < (18*STABSPEED) then
                stabby(pizza)
            end
        end


        if cone.phase ~= PHASE.STAB then
            local dist_mul = max(0, min(cone.hoverdist, 75))
            if cone.phase == PHASE.DETRANSFORM then
                cone.hoverdist = max($-4, 0)
            else
                cone.hoverdist = min($+4, 75)
            end
            P_MoveOrigin(
                pizza,
                target.x + sin(leveltime*ANG2*2)*dist_mul,
                target.y + cos(leveltime*ANG2*2)*dist_mul,
                target.z
            )
            pizza.momx = 0
            pizza.momy = 0
            pizza.momz = 0
        else
            if PTSR.timeover then
                pizza.momx = 95*$/100
                pizza.momy = 95*$/100
                pizza.momz = 95*$/100
            else
                pizza.momx = 9*$/10
                pizza.momy = 9*$/10
                pizza.momz = 9*$/10
            end
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
    local add = 2
    if not special.hailLanded then
        add = $ * 5
    elseif PTSR.timeover then
        add = 3 * $/2
    end
    toucher.coneballIcecreamed = min(($ or 0)+add, MAXICECREAM)
    -- if toucher.player and toucher.player.valid
    --     and not special.hailLanded
    --     and not P_PlayerInPain(toucher.player)
    -- then
    --     P_DamageMobj(toucher, special, special)
    -- end
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
        -- print(p.mo.coneballIcecreamed .. " icecream")
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

local dots = {}
local dotplayer = nil

local hudf = function (v, p)
    if not #dots then return end
    --[[@type videolib]]
    local vv = v
    for _,dot in ipairs(dots) do
        local dotpatch = vv.getSpritePatch(SPR_CONB, Z+11+G, 0, dot.a)
        local dist = R_PointToDist2(dot.x, dot.y, 160*FU, 100*FU)
        local flags = 0
        if dist < 40*FU then
            flags = V_70TRANS
        elseif dist < 75*FU then
            flags = V_50TRANS
        elseif dist < 110*FU then
            flags = V_20TRANS
        end
        vv.drawScaled(dot.x, dot.y, FU, dotpatch, flags)
    end
end
customhud.SetupItem("PTSR_coneball_icecream", ptsr_hudmodname, hudf, "game", 3)

addHook("ThinkFrame", function ()
    if displayplayer ~= dotplayer then
        dots = {}
        dotplayer = displayplayer
    end
    local dotcount = 2*displayplayer.mo.coneballIcecreamed/3
    local keepdots = {}
    for _,dot in ipairs(dots) do
        dot.y = $ + dot.vy
        dot.time = $ - 1
        if dotcount > #dots then
            dot.time = $ - 1
        end
        if dot.time < 0 then
            dot.y = $ - dot.time*2*dot.vy
        end
        if dot.y < 205*FU then
            table.insert(keepdots, dot)
        end
    end
    dots = keepdots
    if #dots < dotcount then
        for i=#dots,dotcount-1 do
            local newdot = {
                x = P_RandomRange(0, 320)*FU,
                y = P_RandomRange(0, 100)*FU,
                vy = P_RandomRange(70, 160)*FU/100,
                time = P_RandomRange(TICRATE, TICRATE*2),
                a = P_RandomRange(-35, 35)*ANG1
            }
            table.insert(dots, newdot)
        end
    end
end)