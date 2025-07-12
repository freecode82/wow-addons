

AjaeMyCustomActionBarDB = AjaeMyCustomActionBarDB or {}
AjaeMyCustomActionBarDBData = AjaeMyCustomActionBarDBData or {}

DEFAULT_BUTTON_CNT = 3
DEFAULT_BUTTON_SIZE = 36

NUM_ACTION_BUTTONS = nil
BUTTON_SIZE = nil
BUTTONS_PER_ROW = 12
BUTTON_SPACING = 6
BUTTON_LIMIT_CNT = 30
ACTIONBAR_NAME = "AjaeButton"

isLocked = false
isVisible = true
buttons = {}

firstActioonNum = 20000
actionID = firstActioonNum


function setButtonSize()
    for i, btn in ipairs(buttons) do
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn.WNormalTexture:SetSize(BUTTON_SIZE + 7,BUTTON_SIZE + 7) -- 이정도가 적당
        btn.PushedTexture:SetSize(BUTTON_SIZE + 4,BUTTON_SIZE + 4) -- 이정도가 적당
        btn.HighlightTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.CheckedTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.SlotBackground:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        
        AjaeMyCustomActionBarDB.buttonSize = BUTTON_SIZE
        --print("new size: ", AjaeMyCustomActionBarDB.buttonSize)
	end
end


function RemoveButton(index)
    local btn = buttons[index]
    if btn then
        btn:Hide()
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:SetScript("OnMouseDown", nil)
        btn:SetScript("OnEvent", nil)
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
        btn:SetScript("OnReceiveDrag", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        -- wrapper:SetFrameRef("mybtn" .. btn.myIndex, nil)
        btn:UnregisterAllEvents()
        btn.WIcon:SetTexture(nil)
        btn = nil
        --Delete a button from the buttons object
        table.remove(buttons, index)
        table.remove(AjaeMyCustomActionBarDBData, index)
        --print("❌ 버튼 " .. index .. " 제거 완료")
    end
end


function clearButton()
    for _, btn in ipairs(buttons) do
        btn:Hide()
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:SetScript("OnMouseDown", nil)
        btn:SetScript("OnEvent", nil)
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
        btn:SetScript("OnReceiveDrag", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        -- wrapper:SetFrameRef("mybtn" .. btn.myIndex, nil)
        btn:UnregisterAllEvents()
        btn.WIcon:SetTexture(nil)
        btn = nil
    end
    buttons = {}
    AjaeMyCustomActionBarDBData = {}
    AjaeMyCustomActionBarDB = {}
    NUM_ACTION_BUTTONS = 0
    AjaeMyCustomActionBarDB.buttonCnt = 0
end






function MoveInfoSave(self)
    self:StopMovingOrSizing()
    AjaeMyCustomActionBarDBData[i] = AjaeMyCustomActionBarDBData[i] or {}
    local x, y = self:GetLeft(), self:GetTop()
    AjaeMyCustomActionBarDBData[i].pos = { x = x, y = y }
end


function ShowMyTooltip(self)
	local type = self:GetAttribute("type")
	local tooltipInfoId

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -30, 80)
	if type == "spell" then
		-- tooltipInfoId = self:GetAttribute("spell")
        GameTooltip:SetSpellByID(self.spellIDInfo)
	elseif type == "item" then
		tooltipInfoId = self:GetAttribute("item")
		--GameTooltip:SetItemByID(tooltipInfoId) 
		GameTooltip:SetHyperlink(tooltipInfoId);
	elseif type == "macro" then
		tooltipInfoId = self:GetAttribute("macro")
		GameTooltip:SetText(self.MacroName, 1, 1, 1, 1);
	else
		return
	end
		
	if tooltipInfoId == nil then return end

    GameTooltip:Show()
end





function GetFullSpellName(self, Name, Subtext)
	if (Subtext) then
		Subtext = "("..Subtext..")";
	else
		Subtext = "";
	end
	if (Name) then
		return Name..Subtext;
	end
end



function UpdateTextCountSpell(self)
	local count = C_Spell.GetSpellCastCount(self.SpellNameRank);
	if (count ~= 0 or IsConsumableSpell(self.SpellNameRank)) then
		self.WCount:SetText(count);
		return;
	end
	local chargesInfo = C_Spell.GetSpellCharges(self.SpellNameRank);
	if chargesInfo and chargesInfo.maxCharges ~= 1 then
		self.WCount:SetText(chargesInfo.currentCharges);
		return;
	end
	self.WCount:SetText("")
end


function UpdateTextCountItem(self)
	local ItemCount = C_Item.GetItemCount(self.ItemId, nil, true);
	if (C_Item.IsConsumableItem(self.ItemId) or ItemCount > 1) then
		self.WCount:SetText(ItemCount);
	else
		self.WCount:SetText("")
	end
end




function UpdateTextCountMacro(self)
	if (self.MacroMode == "spell") then
		self:UpdateTextCountSpell()
	elseif (self.MacroMode == "item") then
		self:UpdateTextCountItem()
	else
		self.WCount:SetText("")
	end
	
	if (self.WCount:GetText() == nil and self.MacroTextEnabled) then
		self.WName:SetText(self.MacroName)
	else
		self.WName:SetText("")
	end
end


function UpdateTextCountBonusAction(self)
	local action = self.Widget:CalculateAction()
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and (IsConsumableAction(action) or IsStackableAction(action))) then
		self.WCount:SetText(GetActionCount(action))
	else
		self.WCount:SetText("")
	end
end




function ChangeAttribute(self, key)
	if key == "spell" then
		self:SetAttribute("item", nil)
		self:SetAttribute("macro", nil)
	elseif key == "item" then
		self:SetAttribute("spell", nil)
		self:SetAttribute("macro", nil)
		self.spellIDInfo = nil
	elseif key == "macro" then
		self:SetAttribute("item", nil)
		self:SetAttribute("spell", nil)
		self.spellIDInfo = nil
	else
		print("알수 없는 키 전달 됨")
	end
end
	



function SpellRegisterProcess(self, actionID, spellID)
	if spellID == nil then return end
        
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local Name = spellInfo and spellInfo.name
        local Subtext = C_Spell.GetSpellSubtext(spellID)
        self.SpellName = Name;
        self.SpellNameRank = self:GetFullSpellName(Name, Subtext)
        
        self.mode = "skill"
        self:ChangeAttribute("spell")
        self:SetAttribute("type", "spell")
        if actionID ~= 0 then
            self:SetAttribute("spell", spellID)
		else
            self:SetAttribute("spell", self.SpellNameRank)
        end
		self.spellIDInfo = spellID
        self:SetAttribute("skipNextClick", true)
        self.WIcon:SetTexture(C_Spell.GetSpellTexture(spellID)) -- 아이콘 표시
        self.WIcon:SetAllPoints()
end

function ItemRegisterProcess(self, actionID, info2)
    self.mode = "item"
    self.ItemId = actionID
    self:ChangeAttribute("item")
    self:SetAttribute("type", "item")
    self:SetAttribute("item", info2) -- 아이템의 경우 아이템 링크를 설정 해야 한다.
    self:SetAttribute("itemId", actionID)
    self:SetAttribute("skipNextClick", true)
    self.WIcon:SetTexture(GetItemIcon(actionID)) -- 아이템 아이콘 표시
end

function MacroRegisterProcess(self, actionID)
    self.mode = "macro"
    self.MacroName = select(1, GetMacroInfo(actionID))
    -- self.macroSkillInfo = select(3, GetMacroInfo(actionID))
    self:ChangeAttribute("macro")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macro", actionID)
    self:SetAttribute("skipNextClick", true)
    self.WIcon:SetTexture(select(2, GetMacroInfo(actionID))) -- 매크로 아이콘 표시
end

function CoolTimeMySet(self, event)
    if self.mode == "skill" then
        local spelltestId = self:GetAttribute("spell")
    	
    	if spelltestId == nil then return end
    	
        local cooldownInfo = C_Spell.GetSpellCooldown(spelltestId)
    
    	if (cooldownInfo ~= nil) then
    	    --local chargesInfo = C_Spell.GetSpellCharges(self.SpellNameRank);
    		local chargesInfo = C_Spell.GetSpellCharges(spelltestId)
    		local start = cooldownInfo.startTime
    		local duration = cooldownInfo.duration
    		local enable = cooldownInfo.isEnabled
    		local modRate = cooldownInfo.modRate
    		local currentCharges, maxCharges
    		if chargesInfo and chargesInfo.currentCharges ~= chargesInfo.maxCharges then
    		    start = chargesInfo.cooldownStartTime;
    		  	duration = chargesInfo.cooldownDuration;
    		  	currentCharges = chargesInfo.currentCharges;
    		  	maxCharges = chargesInfo.maxCharges;
    		end
    		--self.cooldown:SetDrawEdge(true);
    		--self.cooldown:SetDrawBling(true);
            CooldownFrame_Set(self.cooldown, start, duration, true, false, modRate)
    		self:UpdateTextCountSpell()
    	else
    		CooldownFrame_Set(self.cooldown, 0, 0, 0)
    		self.cooldown:Hide()
    	end
    elseif self.mode == "item" then
    	CooldownFrame_Set(self.cooldown, C_Item.GetItemCooldown(self.ItemId))
    	self:UpdateTextCountItem()
    elseif self.mode == "macro" then
    	CooldownFrame_Set(self.cooldown, 0, 0, 0)
    	self.cooldown:Hide()
    else
		--
    end
end