dofile "Libraries/sglib"

--hacky fix because jisk wants me to use it
local fakeV = {
	__width = 320,
	__height = 200,
	__dupx = 1,
	__dupy = 1
}
function fakeV.width()
	return fakeV.__width
end
function fakeV.height()
	return fakeV.__height
end
function fakeV.dupx()
	return fakeV.__dupx
end
function fakeV.dupy()
	return fakeV.__dupy
end

local MAX_TICS = TICRATE
local GO_TO_X = 60*FU
local GO_TO_Y = 25*FU
local GO_TO_S = FU/5

function PTSR.add_wts_score(player, mobj, score)
	local x = 0
	local y = 0
	local s = FU
	local spr = score or 100

	if player == displayplayer then
		local wts = SG_ObjectTracking(fakeV,player,camera,mobj)

		if wts.onScreen then
			x = wts.x
			y = wts.y
			s = wts.scale/2
		end
	end

	player.ptsr.score_objects[#player.ptsr.score_objects+1] = {
		x = x,
		y = y,
		s = GO_TO_S,
		score = score,
		tics = 0
	}
end

addHook("PlayerThink", function(p)
	if not (p and p.ptsr) then return end

	for k,data in pairs(p.ptsr.score_objects) do
		data.tics = $+1
		if data.tics > MAX_TICS then
			table.remove(p.ptsr.score_objects, k)
			p.ptsr.current_score = p.score
			p.ptsr.score_shakeTime = FU
		end
	end
end)

local score_hud = function(v, player)
	local x = 0
	local y = 0

	fakeV.__width = v.width()
	fakeV.__height = v.height()
	fakeV.__dupx = v.dupx()
	fakeV.__dupy = v.dupy()

	if player.ptsr
	and player.ptsr.score_shakeTime then
		local shakeTime = player.ptsr.score_shakeTime
		local maxTime = player.ptsr.score_shakeDrainTime

		local shakeX = v.RandomRange(-5, 5)*shakeTime
		local shakeY = v.RandomRange(-5, 5)*shakeTime

		x = $+shakeX
		y = $+shakeY
	end

	v.drawScaled((24*FU)+x, (15*FU)+y, FU/3, v.cachePatch("SCOREOFPIZZA"..(leveltime/2)%12), (V_SNAPTOLEFT|V_SNAPTOTOP))
	customhud.CustomFontString(v, (58*FU)+x, (11*FU)+y, tostring(player.ptsr and player.ptsr.current_score or 0), "SCRPT", (V_SNAPTOLEFT|V_SNAPTOTOP), "center", FRACUNIT/3)
	
	if player == displayplayer
	and player.ptsr then
		for k,data in pairs(player.ptsr.score_objects) do
			local t = FixedDiv(data.tics, MAX_TICS)
			local drawX = ease.incubic(t, data.x, GO_TO_X)
			local drawY = ease.incubic(t, data.y, GO_TO_Y)

			customhud.CustomFontString(v,
				drawX,
				drawY,
				tostring(data.score),
				"PTFNT",
				V_PERPLAYER|V_SNAPTOBOTTOM,
				"center",
				data.s,
				SKINCOLOR_WHITE)
		end
	end
end

customhud.SetupItem("score", ptsr_hudmodname, score_hud, "game", 0) -- override score hud
