freeslot("TOL_PTSR")
freeslot("sfx_pizzah", "sfx_pizzao", "sfx_coneba", "sfx_pepdie", "sfx_lap2", "sfx_pzprry",
		 "sfx_prepr1", "sfx_prepr2", "sfx_prepr3", "MT_PT_PARRY", "S_PT_PARRY", "SPR_PRRY")
for i = 0, 2
	sfxinfo[sfx_prepr1 + i].caption = "Boink"
end

sfxinfo[sfx_pizzah].caption = "Pizzaface laughs"
sfxinfo[sfx_coneba].caption = "Coneball laughs"
sfxinfo[sfx_pepdie].caption = "Death"
sfxinfo[sfx_lap2].caption = "New lap!"

freeslot("MT_PILLARJOHN", "S_PILLARJOHN", "S_PILLARJOHN_PAIN", "SPR_PILJ", "sfx_jpilr")

mobjinfo[MT_PILLARJOHN] = {
	doomednum = -1,
	spawnstate = S_PILLARJOHN,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_SCENERY
}

states[S_PILLARJOHN] = {
    sprite = SPR_PILJ,
    frame = FF_ANIMATE|A,
    tics = -1,
    var1 = 11,
    var2 = 3,
    nextstate = S_PILLARJOHN
}

states[S_PILLARJOHN_PAIN] = {
    sprite = SPR_PILJ,
    frame = 12,
    tics = -1,
    nextstate = S_PILLARJOHN_PAIN
}

rawset(_G, "FUNC_PTSR", {}) -- functions

freeslot("MT_PIZZAMASK", "S_PIZZAFACE", "S_CONEBALL", "S_PF_EGGMAN", "S_SUMMADAT_PF", "SPR_PZAT", "SPR_CONB", "SPR_SMAD", "sfx_smdah")

mobjinfo[MT_PIZZAMASK] = {
	doomednum = -1,
	spawnstate = S_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY
}

states[S_PIZZAFACE] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = P,
    var2 = 2,
    nextstate = S_PIZZAFACE
}

states[S_CONEBALL] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = H,
    var2 = 2,
    nextstate = S_CONEBALL
}

states[S_PF_EGGMAN] = {
    sprite = SPR_EGGM,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_PF_EGGMAN
}

states[S_SUMMADAT_PF] = {
    sprite = SPR_SMAD,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_SUMMADAT_PF
}

rawset(_G, "pfmaskData", {
	{
		name = "Pizzaface",
		state = S_PIZZAFACE,
		scale = FU/2,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":pizza:"
	},
	{
		name = "Coneball",
	    state = S_CONEBALL,
		scale = 3*FU/4,
		trails = {SKINCOLOR_SKY, SKINCOLOR_NEON},
		sound = sfx_coneba,
		emoji = ":candy:"
	},
	{
		name = "Eggman",
	    state = S_PF_EGGMAN,
		scale = FU,
		trails = {SKINCOLOR_GOLD, SKINCOLOR_FLAME},
		sound = sfx_bewar3,
		emoji = ":egg:"
	}
})

--this is UGLY.
dofile "HUD Animation/Init.lua"
dofile "HUD Animation/UpdatePerFrame.lua"

dofile "customhudlib.lua"

customhud.SetupFont("PTFNT", -1, 4)
customhud.SetupFont("SCRPT", -2, 4)

dofile "main_game.lua"

dofile "consolethings.lua"

dofile "Hooks/PlayerThinks.lua"
dofile "Hooks/PlayerDeath.lua"
dofile "Hooks/PlayerTweaks.lua"
dofile "Hooks/LineTriggerSystem.lua"

dofile "libs.lua"
dofile "exit_handle.lua"
dofile "music_handle.lua"
dofile "pizzaface.lua"
dofile "main_hud.lua"
dofile "discord_botleaderboard.lua"
dofile "name_tags.lua"
dofile "pizzaportal.lua"

dofile "intermission.lua"

dofile "Exit Signs/exitsign_init.lua"
dofile "Exit Signs/exitsign_thinkers.lua"