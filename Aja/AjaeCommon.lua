

function ShowStatus()
    print("AjaeMyCustomActionBarDB.isLocked: ", AjaeMyCustomActionBarDB.isLocked)
    print("AjaeMyCustomActionBarDB.isVisible: ", AjaeMyCustomActionBarDB.isVisible)
    print("AjaeMyCustomActionBarDB.buttonCnt: ", AjaeMyCustomActionBarDB.buttonCnt)
    print("AjaeMyCustomActionBarDB.buttonSize: ", AjaeMyCustomActionBarDB.buttonSize)
    for i = 1, AjaeMyCustomActionBarDB.buttonCnt do
        print(AjaeMyCustomActionBarDBData[i])
    end
end


function RefreshButton()
    for i, btn in ipairs(buttons) do
	    local saved = AjaeMyCustomActionBarDBData[i]
        --print("저장된 데이터: ", saved)
        if saved then
            if saved.pos then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
            end
		end
	end
end

function AjaeSetButtonSize()
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


function AjaeRemoveButton(index)
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


function AjaeClearButton()
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
    AjaeMyCustomActionBarDBData[self.myIndex] = AjaeMyCustomActionBarDBData[self.myIndex] or {}
    local x, y = self:GetLeft(), self:GetTop()
    AjaeMyCustomActionBarDBData[self.myIndex].pos = { x = x, y = y }
end


function ShowMyTooltip(self)
	--local type = self:GetAttribute("type")
	local tooltipInfoId

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -30, 80)
	if self.mode == "skill" then
		-- tooltipInfoId = self:GetAttribute("spell")
        GameTooltip:SetSpellByID(self.spellIDInfo)
	elseif self.mode == "item" then
		tooltipInfoId = self:GetAttribute("item")
		--GameTooltip:SetItemByID(tooltipInfoId) 
		GameTooltip:SetHyperlink(tooltipInfoId);
	elseif self.mode == "macro" then
		tooltipInfoId = self:GetAttribute("macro")
		GameTooltip:SetText(self.MacroName, 1, 1, 1, 1);
	elseif self.mode == "mount" then
		GameTooltip:SetMountBySpellID(self.MountSpellID)
	else
		-- print("알 수 없는 타입")
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

-- not use function
function UpdateTextCountBonusAction(self)
	local action = self:CalculateAction()
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and (IsConsumableAction(action) or IsStackableAction(action))) then
		self.WCount:SetText(GetActionCount(action))
	else
		self.WCount:SetText("")
	end
end


function ChangeAttribute(self)
    -- 기본 속성 제거
    self:SetAttribute("type", nil)
    self:SetAttribute("spell", nil)
    self:SetAttribute("item", nil)
    self:SetAttribute("macro", nil)
    self:SetAttribute("macrotext", nil)
    self:SetAttribute("ItemId", nil)
    self:SetAttribute("typerelease", nil)
    self:SetAttribute("skipNextClick", nil)

    -- 내부 모드 관련 변수 초기화
    self.mode = nil
    self.SpellName = nil
    self.SpellNameRank = nil
    self.spellIDInfo = nil
    self.ItemId = nil
    self.MacroName = nil
end
	

function SpellRegisterProcess(self, actionID, spellID)
	if spellID == nil then return end
        
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local Name = spellInfo and spellInfo.name
        local Subtext = C_Spell.GetSpellSubtext(spellID)
        self.SpellName = Name
        self.SpellNameRank = self:GetFullSpellName(Name, Subtext)

        self.mode = "skill"
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

        -- 버튼 정보 저장
        AjaeMyCustomActionBarDBData[self.myIndex] = AjaeMyCustomActionBarDBData[self.myIndex] or {}
        AjaeMyCustomActionBarDBData[self.myIndex].mode = "skill"
        AjaeMyCustomActionBarDBData[self.myIndex].type = "spell"
        if actionID ~= 0 then
            AjaeMyCustomActionBarDBData[self.myIndex].spell = spellID
		else
            AjaeMyCustomActionBarDBData[self.myIndex].spell = self.SpellNameRank
        end
        AjaeMyCustomActionBarDBData[self.myIndex].SpellName = Name
        AjaeMyCustomActionBarDBData[self.myIndex].SpellNameRank = self.SpellNameRank
        AjaeMyCustomActionBarDBData[self.myIndex].spellIDInfo = spellID
end


function SpellLoadProcess(self)
    self:ChangeAttribute()

    self.SpellName = AjaeMyCustomActionBarDBData[self.myIndex].SpellName
    self.SpellNameRank = AjaeMyCustomActionBarDBData[self.myIndex].SpellNameRank
    self.mode = AjaeMyCustomActionBarDBData[self.myIndex].mode
    self:SetAttribute("type", AjaeMyCustomActionBarDBData[self.myIndex].type)
    self:SetAttribute("spell", AjaeMyCustomActionBarDBData[self.myIndex].spell)
    self.spellIDInfo = AjaeMyCustomActionBarDBData[self.myIndex].spellIDInfo
    self:SetAttribute("skipNextClick", nil)
    self.WIcon:SetTexture(C_Spell.GetSpellTexture(AjaeMyCustomActionBarDBData[self.myIndex].spellIDInfo)) -- 아이콘 표시
    self.WIcon:SetAllPoints()
end


function ItemRegisterProcess(self, actionID, info2)
    self.mode = "item"
    self.ItemId = actionID
    self:SetAttribute("type", "item")
    self:SetAttribute("item", info2) -- 아이템의 경우 아이템 링크를 설정 해야 한다.
    self:SetAttribute("ItemId", actionID)
    self:SetAttribute("skipNextClick", true)
    self.WIcon:SetTexture(GetItemIcon(actionID)) -- 아이템 아이콘 표시

    -- 버튼 정보 저장
    AjaeMyCustomActionBarDBData[self.myIndex] = AjaeMyCustomActionBarDBData[self.myIndex] or {}
    AjaeMyCustomActionBarDBData[self.myIndex].mode = self.mode
    AjaeMyCustomActionBarDBData[self.myIndex].ItemId = actionID
    AjaeMyCustomActionBarDBData[self.myIndex].type = "item"
    AjaeMyCustomActionBarDBData[self.myIndex].item = info2
end

function ItemLoadProcess(self)
    self:ChangeAttribute()

    self.mode = AjaeMyCustomActionBarDBData[self.myIndex].mode
    self.ItemId = AjaeMyCustomActionBarDBData[self.myIndex].ItemId
    self:SetAttribute("type", AjaeMyCustomActionBarDBData[self.myIndex].mode)
    self:SetAttribute("item", AjaeMyCustomActionBarDBData[self.myIndex].item) -- 아이템의 경우 아이템 링크를 설정 해야 한다.
    self:SetAttribute("ItemId", AjaeMyCustomActionBarDBData[self.myIndex].ItemId)
    self:SetAttribute("skipNextClick", nil)
    self.WIcon:SetTexture(GetItemIcon(AjaeMyCustomActionBarDBData[self.myIndex].ItemId)) -- 아이템 아이콘 표시
end

function MacroRegisterProcess(self, actionID)

    self.mode = "macro"
    self.MacroName = select(1, GetMacroInfo(actionID))
    -- self.macroSkillInfo = select(3, GetMacroInfo(actionID))
    self:SetAttribute("type", "macro")
    self:SetAttribute("macro", actionID)
    self:SetAttribute("skipNextClick", true)
    self.WIcon:SetTexture(select(2, GetMacroInfo(actionID))) -- 매크로 아이콘 표시

    -- 버튼 정보 저장
    AjaeMyCustomActionBarDBData[self.myIndex] = AjaeMyCustomActionBarDBData[self.myIndex] or {}
    AjaeMyCustomActionBarDBData[self.myIndex].mode = self.mode
    AjaeMyCustomActionBarDBData[self.myIndex].MacroName = self.MacroName
    AjaeMyCustomActionBarDBData[self.myIndex].type = self.mode
    AjaeMyCustomActionBarDBData[self.myIndex].actionid = actionID
end

function MacroLoadProcess(self)
    self:ChangeAttribute()

    self.mode = AjaeMyCustomActionBarDBData[self.myIndex].mode
    self.MacroName = AjaeMyCustomActionBarDBData[self.myIndex].MacroName
    -- self.macroSkillInfo = select(3, GetMacroInfo(actionID))
    self:SetAttribute("type", AjaeMyCustomActionBarDBData[self.myIndex].mode)
    self:SetAttribute("macro", AjaeMyCustomActionBarDBData[self.myIndex].actionid)
    self:SetAttribute("skipNextClick", nil)
    self.WIcon:SetTexture(select(2, GetMacroInfo(AjaeMyCustomActionBarDBData[self.myIndex].actionid))) -- 매크로 아이콘 표시
end

function MountRegisterProcess(self, actionID)
    self.mode = "mount"
    self.MountName		= C_MountJournal.GetMountInfoByID(actionID)
    self.MountSpellID	= select(2, C_MountJournal.GetMountInfoByID(actionID))
    local spellInfo = C_Spell.GetSpellInfo(self.MountSpellID)
    self.MountSpellName	= spellInfo and spellInfo.name or ""
    self:SetAttribute("skipNextClick", true)
    self:SetAttribute("type", "macro")
    -- self:SetAttribute("typerelease", "macro")
    self:SetAttribute("macrotext", "/cast "..self.MountSpellName)
    self.WIcon:SetTexture(C_Spell.GetSpellTexture(self.MountSpellID))

    -- 버튼 정보 저장
    AjaeMyCustomActionBarDBData[self.myIndex] = AjaeMyCustomActionBarDBData[self.myIndex] or {}
    AjaeMyCustomActionBarDBData[self.myIndex].mode = self.mode
    AjaeMyCustomActionBarDBData[self.myIndex].MountName = self.MountName
    AjaeMyCustomActionBarDBData[self.myIndex].MountSpellID = self.MountSpellID
    AjaeMyCustomActionBarDBData[self.myIndex].MountSpellName = self.MountSpellName
    AjaeMyCustomActionBarDBData[self.myIndex].type = "macro"
	AjaeMyCustomActionBarDBData[self.myIndex].typerelease = "macro"
	AjaeMyCustomActionBarDBData[self.myIndex].macrotext = "/cast "..self.MountSpellName
end


function MountLoadProcess(self)
    self:ChangeAttribute()

    self.mode = AjaeMyCustomActionBarDBData[self.myIndex].mode
    self.MountName		= AjaeMyCustomActionBarDBData[self.myIndex].MountName
    self.MountSpellID	= AjaeMyCustomActionBarDBData[self.myIndex].MountSpellID
    self.MountSpellName	= AjaeMyCustomActionBarDBData[self.myIndex].MountSpellName
    self:SetAttribute("skipNextClick", nil)
    self:SetAttribute("type", AjaeMyCustomActionBarDBData[self.myIndex].type);
    -- self:SetAttribute("typerelease", AjaeMyCustomActionBarDBData[self.myIndex].typerelease);
    self:SetAttribute("macrotext", AjaeMyCustomActionBarDBData[self.myIndex].macrotext);
    self.WIcon:SetTexture(C_Spell.GetSpellTexture(AjaeMyCustomActionBarDBData[self.myIndex].MountSpellID))
end

function SpellUpdateUsable(self)
    -- 사용 불가면 회색 (0.4, 0.4, 0.4)
    -- 마나 부족이면 파란빛 (0.5, 0.5, 1)
    -- 사용할 수 있으면 정상 색 (icon:SetVertexColor(1,1,1))
    if not self.WIcon or not self.SpellNameRank then return end

    if self.mode == "skill" then
        --local spellLink = C_Spell.GetSpellLinkFromSpellID(46968)
        local actionType, id, subType = GetActionInfo(self.action)
        print(actionType, id, subType)
        local IsUsable, NotEnoughMana = C_Spell.IsSpellUsable(self.spellIDInfo or self.SpellName or self.SpellNameRank)
        
        if isUsable then
            self.WIcon:SetVertexColor(1.0, 1.0, 1.0)
        elseif notEnoughMana then
            self.WIcon:SetVertexColor(0.5, 0.5, 1.0);
		    self.WNormalTexture:SetVertexColor(0.5, 0.5, 1.0);
        else
            self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		    self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
        end
	end
end


function CoolTimeMySet(self)
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
    	else
    		CooldownFrame_Set(self.cooldown, 0, 0, 0)
    		self.cooldown:Hide()
    	end
        self:UpdateTextCountSpell()
    elseif self.mode == "item" then
    	CooldownFrame_Set(self.cooldown, C_Item.GetItemCooldown(self.ItemId))
    	self:UpdateTextCountItem()
    elseif self.mode == "macro" then
    	CooldownFrame_Set(self.cooldown, 0, 0, 0)
        self:UpdateTextCountMacro()
    	self.cooldown:Hide()
    elseif self.mode == "mount" then
        CooldownFrame_Set(self.cooldown, 0, 0, 0)
        self:UpdateTextCountMacro()
    	self.cooldown:Hide()
    else
		--
    end
end