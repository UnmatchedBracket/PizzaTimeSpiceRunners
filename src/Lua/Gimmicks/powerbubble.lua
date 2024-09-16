PTSR.BubblePowers = {}

function PTSR:AddBubblePower(input_table)
	table.insert(self.BubblePowers, input_table)
	
	return #self.BubblePowers
end

freeslot("MT_PT_BUBBLE", "S_PT_BUBBLE", "SPR_PBBL", "sfx_bblpop")
freeslot("MT_PT_BUBBLEEFFECT", "S_PT_BUBBLE2") -- effect
freeslot("MT_PT_BUBBLEPOWER", "S_PT_BUBBLE3") -- display power

freeslot("SPR_50BI", "sfx_bb_50r") -- 50 ring sprite

mobjinfo[MT_PT_BUBBLE] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE,
	spawnhealth = 1000,
	radius = 64*FU,
	height = 32*FU,
	dispoffset = 0,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

mobjinfo[MT_PT_BUBBLEEFFECT] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE2,
	spawnhealth = 1000,
	radius = 16*FU,
	height = 24*FU,
	dispoffset = 1,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

mobjinfo[MT_PT_BUBBLEPOWER] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE3,
	spawnhealth = 1000,
	radius = 16*FU,
	height = 24*FU,
	dispoffset = 2,
	flags = MF_SLIDEME|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
}

states[S_PT_BUBBLE] = {
    sprite = SPR_PBBL,
    frame = A|FF_ANIMATE|FF_FULLBRIGHT,
    tics = -1,
	var1 = 3,
	var2 = 2,
    nextstate = S_PT_BUBBLE,
}

states[S_PT_BUBBLE2] = {
    sprite = SPR_THOK,
    frame = A|FF_FULLBRIGHT,
    tics = -1,
	--frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	--var1 = 3,
	--var2 = 1,
    nextstate = S_PT_BUBBLE2,
}

states[S_PT_BUBBLE3] = {
    sprite = SPR_THOK,
    frame = A|FF_FULLBRIGHT,
    tics = -1,
	--frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	--var1 = 3,
	--var2 = 1,
    nextstate = S_PT_BUBBLE3,
}

PTSR:AddBubblePower({
	name = "10 Rings",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_GivePlayerRings(player, 10)
			S_StartSound(toucher, sfx_itemup)
		end
	end,
	sprite = SPR_TVRI,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_YELLOW
})

PTSR:AddBubblePower({
	name = "50 Rings",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_GivePlayerRings(player, 50)
			S_StartSound(toucher, sfx_bb_50r)
		end
	end,
	sprite = SPR_50BI,
	frame = A,
	--disable_popsound = true,
	pop_color = SKINCOLOR_ORANGE
})

/*
PTSR:AddBubblePower({
	name = "1 Up",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_GivePlayerRings(player, 100)
			S_StartSound(toucher, sfx_cdpcm4)
		end
	end,
	sprite = SPR_TV1U,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_BLUE
})
*/

PTSR:AddBubblePower({
	name = "Pity Shield",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_SwitchShield(player, SH_PITY)
			P_SpawnShieldOrb(player)
			S_StartSound(toucher, sfx_shield)
		end
	end,
	sprite = SPR_TVPI,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_MOSS
})

PTSR:AddBubblePower({
	name = "Whirlwind Shield",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_SwitchShield(player, SH_WHIRLWIND)
			P_SpawnShieldOrb(player)
			S_StartSound(toucher, sfx_wirlsg)
		end
	end,
	sprite = SPR_TVWW,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_WHITE
})

PTSR:AddBubblePower({
	name = "Force Shield",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_SwitchShield(player, SH_FORCE|1)
			P_SpawnShieldOrb(player)
			S_StartSound(toucher, sfx_forcsg)
		end
	end,
	sprite = SPR_TVFO,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_GALAXY
})

/*
PTSR:AddBubblePower({
	name = "Attraction Shield",
	pickup_func = function(toucher)
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			P_SwitchShield(player, SH_ATTRACT)
			P_SpawnShieldOrb(player)
			S_StartSound(toucher, sfx_attrsg)
		end
	end,
	sprite = SPR_TVAT,
	frame = C,
	--disable_popsound = true,
	pop_color = SKINCOLOR_YELLOW
})
*/

function A_PT_BubbleFloatAnim(actor, var1) -- var1: color
	local angles = 6
	
	for i = 0, angles do
		local div = FixedAngle((360*FRACUNIT)/angles)*i
		
		for ii = 0, angles do
			local div2 = FixedAngle((360*FRACUNIT)/angles)*ii
			
			local b_mo = P_SpawnMobj(actor.x , actor.y, actor.z+(actor.height/2), MT_PT_BUBBLEEFFECT)
			b_mo.divrem3 = FU/3
			b_mo.color = var1 or SKINCOLOR_GREEN
			
			b_mo.momx = P_RandomRange(-60,60)*FU
			b_mo.momy = P_RandomRange(-60,60)*FU
			b_mo.momz = P_RandomRange(-60,60)*FU
		end
	end
end

addHook("TouchSpecial", function(special, toucher)
	local popcolor = SKINCOLOR_AZURE
	
	if special.displaypower and special.displaypower.valid then
		P_SpawnGhostMobj(special.displaypower)
		P_RemoveMobj(special.displaypower)
	end
	
	if special.bubblepower and PTSR.BubblePowers[special.bubblepower] then
		if PTSR.BubblePowers[special.bubblepower].pickup_func then
			PTSR.BubblePowers[special.bubblepower].pickup_func(toucher)
		end
		
		if not PTSR.BubblePowers[special.bubblepower].disable_popsound then
			S_StartSound(toucher, sfx_pop)
		end
		
		if PTSR.BubblePowers[special.bubblepower].pop_color then
			popcolor = PTSR.BubblePowers[special.bubblepower].pop_color
		end
	end
	
	if toucher.player and toucher.player.valid then
		local player = toucher.player
		PTSR:AddComboTime(player, player.ptsr.combo_maxtime)
	end
	
	A_PT_BubbleFloatAnim(special, popcolor)
end, MT_PT_BUBBLE)

addHook("MobjSpawn", function(bubble)
	bubble.bubblepower = P_RandomRange(1, #PTSR.BubblePowers)
	bubble.displaypower = P_SpawnMobj(bubble.x, bubble.y, bubble.z+24*FU, MT_PT_BUBBLEPOWER)
	
	local powerdef = PTSR.BubblePowers[bubble.bubblepower] or PTSR.BubblePowers[1] or error("No bubbledefs exist.")
	
	if powerdef.offset_z then
		P_SetOrigin(bubble.displaypower, bubble.x, bubble.y, bubble.z+powerdef.offset_z)
	end
	
	if powerdef.sprite == nil then
		bubble.displaypower.sprite = SPR_TVRI 
	else
		bubble.displaypower.sprite = powerdef.sprite
	end
	
	if powerdef.frame == nil then
		bubble.displaypower.frame = C
	else
		bubble.displaypower.frame = powerdef.frame
	end
end, MT_PT_BUBBLE)

addHook("MapThingSpawn", function(mobj)
	if not multiplayer then return end
	
	local monitor_range = {400,452} -- range of thingnum
	
	if (mobj.info.doomednum >= monitor_range[1] and mobj.info.doomednum <= monitor_range[2]) 
		or (mobj.flags & MF_MONITOR) then
		local bubble = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_PT_BUBBLE)
		
		P_RemoveMobj(mobj)
		return true
	end
end)

addHook("MobjSpawn", function(mobj)
	mobj.spritexscale = $/4
	mobj.spriteyscale = $/4

	mobj.spawntime = leveltime
end, MT_PT_BUBBLEEFFECT)

addHook("MobjThinker", function(mobj)
	if mobj and mobj.valid and mobj.divrem3 then
		mobj.momx = FixedMul($, mobj.divrem3)
		mobj.momy = FixedMul($, mobj.divrem3)
		mobj.momz = FixedMul($, mobj.divrem3)
		mobj.scale = ease.incubic(FixedDiv(leveltime-mobj.spawntime, TICRATE),
			FU, 0)

		if leveltime-mobj.spawntime >= TICRATE then
			P_RemoveMobj(mobj)
			return; end

		local transtween = ease.incubic(
			FixedDiv(leveltime-mobj.spawntime, TICRATE),
			2, 9)

		mobj.frame = $|(transtween*FF_TRANS10)
	end
end, MT_PT_BUBBLEEFFECT)