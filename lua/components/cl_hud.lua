local component = {}
component.namespace = "hud"
component.dependencies = {"theme", "anchor"}
component.title = "HUD"

component.fpssmooth = 0
component.iconLicense 	= Material("galactic_hud/license.png", "smooth")
component.iconWanted 	= Material("galactic_hud/wanted.png", "smooth")

component.gamemodes = {darkrp = true, sandbox = true}
component.shouldNotDraw = {}

function component:Constructor()
	if self.gamemodes[engine.ActiveGamemode()] then
		galactic.anchor:RegisterAnchor(self, self.DrawLeft, false, true)
		galactic.anchor:RegisterAnchor(self, self.DrawRight, false, false)
		if engine.ActiveGamemode() == "darkrp" then
			galactic.anchor:RegisterAnchor(self, self.DrawTopLeft, true, true)
		end
		self.shouldNotDraw = {CHudHealth = true, CHudBattery = true, CHudAmmo = true, CHudSecondaryAmmo = true, DarkRP_HUD = true, DarkRP_Hungermod = true}
	end
end

function component:HUDShouldDraw(name)
	if self.shouldNotDraw[name] then
		return false
	end
end

function component:DrawTopLeft(anchorX, anchorY)
	local spacing = galactic.theme.rem * .5
	local totalW = galactic.theme.rem * 24
	local totalH = galactic.theme.rem * 12

	local anchorX = anchorX + galactic.theme.rem
	local anchorY = anchorY + galactic.theme.rem

	anchorX = math.Round(anchorX)
	anchorY = math.Round(anchorY)

	if LocalPlayer():getAgendaTable() then
		local x = anchorX
		local y = anchorY
		local w = galactic.theme.rem * 24
		local h = galactic.theme.rem * 12

		draw.RoundedBox(galactic.theme.round, x, y, w, h, galactic.theme.colors.blockFaint)
		draw.RoundedBox(galactic.theme.round, x, y, w, galactic.theme.rem * 2.5, galactic.theme.colors.block)
		draw.SimpleText(
						LocalPlayer():getAgendaTable().Title,
						"GalacticDefault",
						x + w/2,
						y + galactic.theme.rem * 1.25,
						galactic.theme.colors.text,
						TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER)
		local agendaText = DarkRP.textWrap((LocalPlayer():getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "GalacticDefault", w - galactic.theme.rem)
		draw.DrawText(agendaText, "GalacticDefault", x + galactic.theme.rem * .5, y + galactic.theme.rem * 3, galactic.theme.colors.text)
	end

	return totalW + galactic.theme.rem, totalH + galactic.theme.rem
end

function component:DrawLeft(anchorX, anchorY)
	local spacing = galactic.theme.rem * .5
	local totalW = galactic.theme.rem * 20
	local totalH = galactic.theme.rem * 7

	local anchorX = anchorX + galactic.theme.rem
	local anchorY = anchorY - totalH - galactic.theme.rem

	// Damage taken shake
	if (self.oldHealth or 0) > LocalPlayer():Health() then
		self.LeftShake = (self.LeftShake or 0) + spacing * 2
	end
	self.oldHealth = LocalPlayer():Health()
	if self.LeftShake then
		anchorX = anchorX + math.Rand(-self.LeftShake, self.LeftShake)
		anchorY = anchorY + math.Rand(-self.LeftShake, self.LeftShake)
		self.LeftShake = galactic.theme:PredictNextMove(self.LeftShake, 0)
	end

	anchorX = math.Round(anchorX)
	anchorY = math.Round(anchorY)

	// DarkRP
	if engine.ActiveGamemode() == "darkrp" then
		local x = anchorX
		local y = anchorY - galactic.theme.rem * 2.5
		local w = totalW
		local h = galactic.theme.rem * 2.5

		draw.RoundedBox(galactic.theme.round, x, y, w, h, galactic.theme.colors.block)

		if self.currentJob != LocalPlayer():getDarkRPVar("job") then
			self.currentJob = LocalPlayer():getDarkRPVar("job")
			timer.Create(LocalPlayer():SteamID() .. "jobtimer", GAMEMODE.Config.paydelay, 0, function() end)
			timer.Create(LocalPlayer():SteamID() .. "changetimer", GAMEMODE.Config.changejobtime, 0, function()
				timer.Remove(LocalPlayer():SteamID() .. "changetimer")
			end)
		end

		local changeJobTime = 1
		local changeJobTimeMax = 1
		if timer.Exists(LocalPlayer():SteamID() .. "changetimer") then
			changeJobTime = GAMEMODE.Config.changejobtime - timer.TimeLeft(LocalPlayer():SteamID() .. "changetimer")
			changeJobTimeMax = GAMEMODE.Config.changejobtime
		end


		x = x + galactic.theme.rem * .5
		y = y + galactic.theme.rem * .5
		w = galactic.theme.rem * 10
		h = h - galactic.theme.rem

		self:DrawProcentBar(x, y, w, h,
							galactic.theme.colors.green,
							changeJobTime,
							changeJobTimeMax,
							LocalPlayer():getDarkRPVar("job"),
							DarkRP.formatMoney(LocalPlayer():getDarkRPVar("salary")),
							galactic.theme.colors.greenFaint)

		x = x + w + galactic.theme.rem * .5
		w = galactic.theme.rem * 4.5

		self:DrawProcentBar(x, y, w, h,
							galactic.theme.colors.green,
							GAMEMODE.Config.paydelay - timer.TimeLeft(LocalPlayer():SteamID() .. "jobtimer"),
							GAMEMODE.Config.paydelay,
							"",
							"",
							galactic.theme.colors.greenFaint,
							DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money")))

		x = x + w + galactic.theme.rem * .5
		w = galactic.theme.rem * 1.5

		surface.SetDrawColor(galactic.theme.colors.blockFaint)
		if LocalPlayer():getDarkRPVar("HasGunlicense") then
			surface.SetDrawColor(galactic.theme.colors.yellow)
		end
		surface.SetMaterial(self.iconLicense)
		surface.DrawTexturedRect(x, y, w, w)

		x = x + w + galactic.theme.rem * .5
		w = galactic.theme.rem * 1.5

		surface.SetDrawColor(galactic.theme.colors.blockFaint)
		if LocalPlayer():getDarkRPVar("wanted") then
			surface.SetDrawColor(galactic.theme.colors.red)
		end
		surface.SetMaterial(self.iconWanted)
		surface.DrawTexturedRect(x, y, w, w)

		if LocalPlayer():getDarkRPVar("Energy") then
			local x = anchorX + totalW
			local y = anchorY - galactic.theme.rem * 2.5
			local w = galactic.theme.rem * 2.5
			local h = totalH + galactic.theme.rem * 2.5

			draw.RoundedBox(galactic.theme.round, x, y, w, h, galactic.theme.colors.blockFaint)

			x = x + galactic.theme.rem * .5
			y = y + galactic.theme.rem * .5
			w = w - galactic.theme.rem
			h = h - galactic.theme.rem

			draw.RoundedBox(galactic.theme.round, x, y, w, h, galactic.theme.colors.yellowFaint)

			local hunger = LocalPlayer():getDarkRPVar("Energy")
			if hunger > 100 then
				hunger = 100
			end

			draw.RoundedBox(galactic.theme.round, x, y + h - h * hunger / 100, w, h * hunger / 100, galactic.theme.colors.yellow)
		end

	end

	if not LocalPlayer():Alive() then
		return totalW, totalH
	end

	// Backgrounds
	local x = anchorX
	local y = anchorY
	local w = totalW
	local h = totalH - galactic.theme.rem * 2.5

	draw.RoundedBoxEx(galactic.theme.round, x, y, w, h, galactic.theme.colors.blockFaint, true, true)

	y = y + h
	h = 2.5 * galactic.theme.rem

	draw.RoundedBoxEx(galactic.theme.round, x, y, w, h, galactic.theme.colors.block, _, _, true, true)

	// Top Information
	// // Velocity
	x = anchorX + spacing
	y = anchorY + spacing
	w = totalW - spacing * 2
	h = galactic.theme.rem * 1.5
	local velocity = math.Round(self:GetRootParentOfEntity(LocalPlayer()):GetVelocity():Length())
	local velocityKPH = math.Round(velocity*3600*0.0000254*0.75)
	local velocityMPH = math.Round(velocity*3600/63360*0.75)
	self:DrawProcentBar(x, y, w, h, galactic.theme.colors.green, velocity, 1500, "KPH: " .. velocityKPH, "MPH: " .. velocityMPH, galactic.theme.colors.greenFaint)

	// // FPS
	y = y + h + spacing
	w = totalW / 2 - spacing * 1.5
	local fps = 1 / RealFrameTime()
	self.fpssmooth = self.fpssmooth + (fps - self.fpssmooth)/(fps/4)
	if self.fpssmooth ~= self.fpssmooth then self.fpssmooth = 0 end
	self:DrawProcentBar(x, y, w, h, galactic.theme.colors.green, math.Round(self.fpssmooth), 144, "FPS", math.Round(self.fpssmooth), galactic.theme.colors.greenFaint)

	// // Latency
	x = x + w + spacing
	local fps = 1 / RealFrameTime()
	self.fpssmooth = self.fpssmooth + (fps - self.fpssmooth)/(fps/4)
	self:DrawProcentBar(x, y, w, h, galactic.theme.colors.green, LocalPlayer():Ping(), 150, "Latency", LocalPlayer():Ping(), galactic.theme.colors.greenFaint)

	// Bottom Information
	x = anchorX + spacing
	y = y + h + spacing * 2
	w = totalW - spacing * 2
	local healthInfo = LocalPlayer():Health()

	// // Armor
	if LocalPlayer():Armor() > 0 then
		x = x - galactic.theme.rem / 8
		y = y - galactic.theme.rem / 8
		w = w + galactic.theme.rem / 4
		h = h + galactic.theme.rem / 4
		self:DrawProcentBar(x, y, w, h, galactic.theme.colors.blue, LocalPlayer():Armor(), 100, "", "", Color(0, 0, 0, 0))
		healthInfo = healthInfo .. " / " .. LocalPlayer():Armor()
		x = x + galactic.theme.rem / 8
		y = y + galactic.theme.rem / 8
		w = w - galactic.theme.rem / 4
		h = h - galactic.theme.rem / 4
	end

	// // Health
	self:DrawProcentBar(x, y, w, h, galactic.theme.colors.red, LocalPlayer():Health(), LocalPlayer():GetMaxHealth(), "Health", healthInfo, galactic.theme.colors.redFaint)


	if engine.ActiveGamemode() == "darkrp" then
		return totalW + galactic.theme.rem, totalH + galactic.theme.rem
	end

	return totalW + galactic.theme.rem, totalH + galactic.theme.rem
end

function component:DrawRight(anchorX, anchorY)
	local spacing = galactic.theme.rem * .5
	local totalW = galactic.theme.rem * 20
	local totalH = galactic.theme.rem * 2.5

	if not LocalPlayer():Alive() then
		return totalW, totalH
	end

	local anchorX = anchorX - totalW - galactic.theme.rem
	local anchorY = anchorY - totalH - galactic.theme.rem



	// Weapon fire shake
	if LocalPlayer():GetActiveWeapon():IsWeapon() then
		if self.oldWeapon == LocalPlayer():GetActiveWeapon() && self.oldWeaponClipSize > LocalPlayer():GetActiveWeapon():Clip1() then
			self.xPush = (self.xPush or 0) + math.Rand(0, spacing * 2)
			self.yPush = (self.yPush or 0) + math.Rand(0, spacing * 2)
		end
		self.oldWeapon = LocalPlayer():GetActiveWeapon()
		self.oldWeaponClipSize = LocalPlayer():GetActiveWeapon():Clip1()
	end
	if self.xPush then
		anchorX = anchorX + self.xPush
		self.xPush = galactic.theme:PredictNextMove(self.xPush, 0)
	end
	if self.yPush then
		anchorY = anchorY + self.yPush
		self.yPush = galactic.theme:PredictNextMove(self.yPush, 0)
	end

	
	anchorX = math.Round(anchorX)
	anchorY = math.Round(anchorY)


	// Backgrounds
	local x = anchorX
	local y = anchorY
	local w = totalW
	local h = totalH

	draw.RoundedBox(galactic.theme.round, x, y, w, h, galactic.theme.colors.blockFaint, _, _, true, true)

	// Clip1
	x = x + spacing
	y = y + spacing
	w = w - galactic.theme.rem * 7
	h = h - galactic.theme.rem
	if LocalPlayer():GetActiveWeapon():IsWeapon() then
		local clip = LocalPlayer():GetActiveWeapon():Clip1()
		local clipMax = LocalPlayer():GetActiveWeapon():GetMaxClip1()
		local clipAmmo = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
		if clip >= 0 then
			self:DrawProcentBar(x, y, w, h, galactic.theme.colors.blue, clip, clipMax, LocalPlayer():GetActiveWeapon():GetPrintName(), clip .. " (+" .. clipAmmo .. ")", galactic.theme.colors.blueFaint)
		elseif clipAmmo > 0 then
			self:DrawProcentBar(x, y, w, h, galactic.theme.colors.blue, clipAmmo, clipAmmo, LocalPlayer():GetActiveWeapon():GetPrintName(), "", galactic.theme.colors.blueFaint)
		else
			self:DrawProcentBar(x, y, w, h, galactic.theme.colors.blue, 0, 0, LocalPlayer():GetActiveWeapon():GetPrintName(), "", galactic.theme.colors.blueFaint)
		end
	end

	// Clip2
	x = x + w + spacing
	w = totalW - w - galactic.theme.rem * 1.5
	if LocalPlayer():GetActiveWeapon():IsWeapon() then
		local clip = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())
		if clip > 0 then
			self:DrawProcentBar(x, y, w, h, galactic.theme.colors.yellow, clip, clip, "ALT", clip, galactic.theme.colors.yellowFaint)
		else
			self:DrawProcentBar(x, y, w, h, galactic.theme.colors.yellow, 0, 0, "", "", galactic.theme.colors.yellowFaint)
		end
	end

	return totalW + galactic.theme.rem, totalH + galactic.theme.rem
end

function component:GetRootParentOfEntity(entity)
	if entity:GetParent():IsValid() then
		return self:GetRootParentOfEntity(entity:GetParent())
	end
	return entity
end

function component:DrawProcentBar(x, y, w, h, colour, value, max, leftString, rightString, bgColour, centerString)
	if bgColour then
		draw.RoundedBox(galactic.theme.round, x, y, w, h, bgColour)
	else
		draw.RoundedBox(galactic.theme.round, x, y, w, h, ColorAlpha(colour, .1*colour.a))
	end

	local limitedValue = (value >= max and max) or value

	if w / max * limitedValue >= 1 then
		draw.RoundedBox(galactic.theme.round, x, y, w / max * limitedValue, h, colour)
	end

	if centerString then
		draw.SimpleText(centerString, "GalacticP", x + w / 2, y + h / 2, galactic.theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if leftString then
		draw.SimpleText(leftString, "GalacticP", x + h / 4, y + h / 2, galactic.theme.colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	if not rightString then
		rightString = value
	end

	if rightString then
		draw.SimpleText(rightString, "GalacticPBold", x + w - h / 4, y + h / 2, galactic.theme.colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

galactic:Register(component)
