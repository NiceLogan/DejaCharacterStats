local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local _, gdbprivate = ...
-- Decimal Check
local notinteger
local my_floor = math.floor

local function round(x)
	return my_floor(x+0.5)
end
local statformat
local multiplier
local function DCS_Decimals()
	-- Crit Chance
		--TODO: is notinteger needed? might be more efficient to set statformat and multiplier in checkboxes
		if notinteger then
			statformat = "%.2f%%"
			multiplier = 100
		else
			statformat = "%.0f%%"
			multiplier = 1
		end
		local notexactlyzero = gdbprivate.gdb.gdbdefaults.dejacharacterstatsDCSZeroChecked.SetChecked
		function PaperDollFrame_SetCritChance(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local rating;
			local spellCrit, rangedCrit, meleeCrit;
			local critChance;

			-- Start at 2 to skip physical damage
			local holySchool = 2;
			local minCrit = GetSpellCritChance(holySchool);
			statFrame.spellCrit = {};
			statFrame.spellCrit[holySchool] = minCrit;
			local spellCrit;
			for i=(holySchool+1), MAX_SPELL_SCHOOLS do
				spellCrit = GetSpellCritChance(i);
				minCrit = min(minCrit, spellCrit);
				statFrame.spellCrit[i] = spellCrit;
			end
			spellCrit = minCrit
			rangedCrit = GetRangedCritChance();
			meleeCrit = GetCritChance();

			if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
				critChance = spellCrit;
				rating = CR_CRIT_SPELL;
			elseif (rangedCrit >= meleeCrit) then
				critChance = rangedCrit;
				rating = CR_CRIT_RANGED;
			else
				critChance = meleeCrit;
				rating = CR_CRIT_MELEE;
			end
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, format(statformat, critChance), false, round(multiplier*critChance)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, format(statformat, critChance), false, critChance);
			end
			--PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, format(statformat1, critChance), true, format(statformat1, critChance)); --can't do it because PaperDollFrame_SetLabelAndText converts to integer
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2f%%", critChance)..FONT_COLOR_CODE_CLOSE;
			local extraCritChance = GetCombatRatingBonus(rating);
			local extraCritRating = GetCombatRating(rating);
			if (GetCritChanceProvidesParryEffect()) then
				statFrame.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
			else
				statFrame.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
			end
			statFrame:Show();
		end

	-- Haste Chance
		function PaperDollFrame_SetHaste(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local haste = GetHaste();
			local rating = CR_HASTE_MELEE;

			local hasteFormatString;
			if (haste < 0) then
				hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
			else
				hasteFormatString = "+%s";
			end
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format(statformat, haste)), false, round(multiplier*haste)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format(statformat, haste)), false, haste);
			end

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. format(hasteFormatString, format("%.2f%%", haste)) .. FONT_COLOR_CODE_CLOSE;

			local _, class = UnitClass(unit);
			statFrame.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
			if (not statFrame.tooltip2) then
				statFrame.tooltip2 = STAT_HASTE_TOOLTIP;
			end
			statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

			statFrame:Show();
		end

	-- Versatility
		function PaperDollFrame_SetVersatility(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
			local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
			local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
		-- PaperDollFrame_SetLabelAndText Format Change
			--local result
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_VERSATILITY, format(statformat, versatilityDamageBonus) .. " / " .. format(statformat, versatilityDamageTakenReduction), false, round(multiplier*versatilityDamageBonus)/multiplier);
				--result = round(multiplier*versatilityDamageBonus)/multiplier
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_VERSATILITY, format(statformat, versatilityDamageBonus) .. " / " .. format(statformat, versatilityDamageTakenReduction), false, versatilityDamageBonus);
				--result = versatilityDamageBonus
			end
			--print("vesratility",result)
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);

			statFrame:Show();
		end

	-- Mastery
		function PaperDollFrame_SetMastery(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end
			--if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
			--	statFrame:Hide();
			--	return;
			--end
			local color_mastery = STAT_MASTERY
			local color_format = statformat
			if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
				color_mastery = "|cff7f7f7f" .. color_mastery .. "|r"
				color_format = "|cff7f7f7f" .. color_format .. "|r"
			end
			local mastery = GetMasteryEffect();
		-- PaperDollFrame_SetLabelAndText Format Change
    
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, color_mastery, format(color_format, mastery), false, round(multiplier*mastery)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, color_mastery, format(color_format, mastery), false, mastery);
			end

			statFrame.onEnterFunc = Mastery_OnEnter;
			statFrame:Show();
		end
			

	-- Leech (Lifesteal)
		function PaperDollFrame_SetLifesteal(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local lifesteal = GetLifesteal();
		-- PaperDollFrame_SetLabelAndText Format Change
			--local result
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_LIFESTEAL, format(statformat, lifesteal), false, round(multiplier*lifesteal)/multiplier);
				--result = round(multiplier*lifesteal)/multiplier
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_LIFESTEAL, format(statformat, lifesteal), false, lifesteal);
				--result = lifesteal
			end
			--print("leech",result)
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2f%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

			statFrame.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

			statFrame:Show();
		end

	-- Avoidance
		function PaperDollFrame_SetAvoidance(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local avoidance = GetAvoidance();
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVOIDANCE, format(statformat, avoidance), false, round(multiplier*avoidance)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVOIDANCE, format(statformat, avoidance), false, avoidance);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2f%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

			statFrame.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

			statFrame:Show();
		end

	-- Dodge Chance
		function PaperDollFrame_SetDodge(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetDodgeChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, format(statformat, chance), false, round(multiplier*chance)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, format(statformat, chance), false, chance);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
			statFrame:Show();
		end

	-- Parry Chance
		function PaperDollFrame_SetParry(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetParryChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, format(statformat, chance), false, round(multiplier*chance)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, format(statformat, chance), false, chance);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
			statFrame:Show();
		end

	-- Block Chance
		function PaperDollFrame_SetBlock(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetBlockChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			if notexactlyzero then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, format(statformat, chance), false, round(multiplier*chance)/multiplier);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, format(statformat, chance), false, chance);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetShieldBlock());
			statFrame:Show();
		end
		PaperDollFrame_UpdateStats() -- needs to get called for checkbox Decimals
end
	

	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowDecimalsChecked = {
		SetChecked = true,
	}	
local DCS_DecimalCheck = CreateFrame("CheckButton", "DCS_DecimalCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DecimalCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_DecimalCheck:ClearAllPoints()
	DCS_DecimalCheck:SetPoint("TOPLEFT", 25, -60)
	DCS_DecimalCheck:SetScale(1.25)
	DCS_DecimalCheck.tooltipText = L['Displays "Enhancements" category stats to two decimal places.'] --Creates a tooltip on mouseover.
	_G[DCS_DecimalCheck:GetName() .. "Text"]:SetText(L["Decimals"])
	
	DCS_DecimalCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			notinteger= gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked
			self:SetChecked(notinteger)
			--local status = self:GetChecked(true) --???
			--DCS_Decimals(status)
			DCS_Decimals()
			--gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = status --???
		end
	end)

	DCS_DecimalCheck:SetScript("OnClick", function(self,event,arg1) 
		--local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked
		notinteger = self:GetChecked(true)
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = notinteger
		DCS_Decimals()
	end)

	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsHideatZeroChecked = {
		SetChecked = true,
	}
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsDCSZeroChecked = { 
		SetChecked = false, 
	} 

	
local dcshideatzeroFS = DejaCharacterStatsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dcshideatzeroFS:SetText("Hide at zero:")
	dcshideatzeroFS:SetPoint("TOPLEFT", 35, -145)
	dcshideatzeroFS:SetFont("Fonts\\FRIZQT__.TTF", 15)
local DCS_BlizzlikeHide = CreateFrame("CheckButton", "DCS_BlizzlikeHide", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate") 
local DCS_HideAtZero = CreateFrame("CheckButton", "DCS_HideAtZero", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate") 
DCS_HideAtZero:RegisterEvent("PLAYER_LOGIN") 
DCS_HideAtZero:ClearAllPoints() 
--DCS_HideAtZero:SetPoint("TOPLEFT", 25, -150) 
DCS_HideAtZero:SetPoint("TOPLEFT", 65, -165) 
DCS_HideAtZero:SetScale(1) 
DCS_HideAtZero.tooltipText = L['Hides enhancement stat if the displayed value would be zero. Checking "Decimals" changes the displayed value.'] --Creates a tooltip on mouseover. 
_G[DCS_HideAtZero:GetName() .. "Text"]:SetText(L["DCS hide at zero"]) 
DCS_HideAtZero:SetScript("OnEvent", function(self, event) 
	if event == "PLAYER_LOGIN" then 
		--local status = gdbprivate.gdb.gdbdefaults.dejacharacterstatsHideAtZeroChecked.SetChecked
		local DCSstatus = gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsDCSZeroChecked.SetChecked
		local hideatzero = gdbprivate.gdb.gdbdefaults.dejacharacterstatsHideAtZeroChecked.SetChecked
		if hideatzero then
			self:SetChecked(DCSstatus)
			DCS_BlizzlikeHide:SetChecked(not DCSstatus) 
		else
			self:SetChecked(false)
			DCS_BlizzlikeHide:SetChecked(false)
		end
	end
end) 
 
DCS_HideAtZero:SetScript("OnClick", function(self) 
	local status = self:GetChecked() 
	gdbprivate.gdb.gdbdefaults.dejacharacterstatsHideAtZeroChecked.SetChecked = status
	gdbprivate.gdb.gdbdefaults.dejacharacterstatsDCSZeroChecked.SetChecked = status
	if status then  
		DCS_BlizzlikeHide:SetChecked(false)  
	end 
	DCS_Decimals() 
end) 

 
 _G[DCS_BlizzlikeHide:GetName() .. "Text"]:SetText(L["Blizzlike hide at zero"] ) 

DCS_BlizzlikeHide:ClearAllPoints() 
--DCS_BlizzlikeHide:SetPoint("TOPLEFT", 50, -220) 
DCS_BlizzlikeHide:SetPoint("TOPLEFT", 65, -185) 
DCS_BlizzlikeHide:SetScale(1) 
DCS_BlizzlikeHide.tooltipText = L['Hides enchancement stat only if its numerical value is exactly zero.'] --Creates a tooltip on mouseover. 

DCS_BlizzlikeHide:SetScript("OnClick", function(self)  
	local status = self:GetChecked() 
	gdbprivate.gdb.gdbdefaults.dejacharacterstatsHideAtZeroChecked.SetChecked = status
	if status then  
		DCS_HideAtZero:SetChecked(false) 
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsDCSZeroChecked.SetChecked = false 
	end 
	DCS_Decimals() 
end) 
 		
