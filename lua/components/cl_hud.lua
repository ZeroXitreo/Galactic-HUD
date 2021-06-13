local component = {}
component.namespace = "hud"
component.dependencies = {"theme", "anchor"}
component.title = "HUD"

component.fpssmooth = 0

function component:Constructor()
	galactic.anchor:RegisterAnchor(self, self.DrawLeft, false, true)
	galactic.anchor:RegisterAnchor(self, self.DrawRight, false, false)

	local iconLicense 	= Material("galactic_hud/license.png", "noclamp smooth")
	local iconWanted 	= Material("galactic_hud/wanted.png", "noclamp smooth")
end

function component:HUDShouldDraw(name)
	local hideNames = {}
	hideNames = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "DarkRP_HUD", "DarkRP_Hungermod"}
	if table.HasValue(hideNames, name) then
		return false
	end
end

function component:DrawLeft(anchorX, anchorY)
	local spacing = galactic.theme.rem * .5
	local totalW = galactic.theme.rem * 20
	local totalH = galactic.theme.rem * 7
	local anchorX = anchorX + galactic.theme.rem
	local anchorY = anchorY - totalH - galactic.theme.rem

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

	return totalW + galactic.theme.rem, totalH + galactic.theme.rem
end

function component:DrawRight(anchorX, anchorY)
	local theme = galactic.theme
	local spacing = galactic.theme.rem * .5
	local totalW = galactic.theme.rem * 20
	local totalH = galactic.theme.rem * 2.5
	local anchorX = anchorX - totalW - galactic.theme.rem
	local anchorY = anchorY - totalH - galactic.theme.rem

	if not LocalPlayer():Alive() then
		return totalW, totalH
	end

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

function component:DrawProcentBar(x, y, w, h, colour, value, max, leftString, rightString, bgColour)
	if bgColour then
		draw.RoundedBox(galactic.theme.round, x, y, w, h, bgColour)
	else
		draw.RoundedBox(galactic.theme.round, x, y, w, h, ColorAlpha(colour, .1*colour.a))
	end

	local limitedValue = (value >= max and max) or value

	if w / max * limitedValue >= 1 then
		draw.RoundedBox(galactic.theme.round, x, y, w / max * limitedValue, h, colour)
	end

	draw.SimpleText(leftString, "GalacticP", x + h / 4, y + h / 2, galactic.theme.colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if not rightString then
		rightString = value
	end

	draw.SimpleText(rightString, "GalacticPBold", x + w - h / 4, y + h / 2, galactic.theme.colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

galactic:Register(component)