-- 최종 커스텀 액션 버튼 + 저장/복원 + 잠금/숨김 + 설정창 기능 포함
-- SavedVariables: MyCustomActionBarDB
-- maker: kcw2020@naver.com
-- This addon is based on Blizzard's ActionButton.lua. Some functions conflict with the game's default action bar, so they have been redefined and assigned.
MyCustomActionBarDB = MyCustomActionBarDB or {}
MyCustomActionBarDbData = MyCustomActionBarDbData or {}

DEFAULT_BUTTON_CNT = 3
DEFAULT_BUTTON_SIZE = 40

NUM_ACTION_BUTTONS = nil
BUTTON_SIZE = nil
BUTTONS_PER_ROW = 12
BUTTON_SPACING = 6
BUTTON_LIMIT_CNT = 200
ACTIONBAR_NAME = "AjaeButton"

isLocked = false
isVisible = true
buttons = {}
firstActioonNum = 160
actionID = firstActioonNum



local function setButtonSize()
    for i, btn in ipairs(buttons) do
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetNormalTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetPushedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetHighlightTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetCheckedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        
        MyCustomActionBarDB.buttonSize = BUTTON_SIZE
        --print("new size: ", MyCustomActionBarDB.buttonSize)
	end
end


local function RemoveButton(index)
    local btn = buttons[index]
    if btn then
        btn:Hide()
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
        btn:SetScript("OnReceiveDrag", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        btn:UnregisterAllEvents()
        --btn.icon:SetTexture(nil)
        btn = nil
        --Delete a button from the buttons object
        table.remove(buttons, index)
        table.remove(MyCustomActionBarDbData, index)
        --print("❌ 버튼 " .. index .. " 제거 완료")
    end
end


local function clearButton()
    for _, btn in ipairs(buttons) do
        btn:Hide()
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
        btn:SetScript("OnReceiveDrag", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        btn:UnregisterAllEvents()
        btn = nil
    end
    buttons = {}
    MyCustomActionBarDbData = {}
    MyCustomActionBarDB = {}
end

local function updateButton()
    for _, btn in ipairs(buttons) do
        btn:Update()
    end
end

local function buttonVisable()
    for _, btn in ipairs(buttons) do btn:Show() end
    isVisible = true
	MyCustomActionBarDB.isVisible = true
end

local function buttonUnVisable()
    for _, btn in ipairs(buttons) do btn:Hide() end
    isVisible = false
	MyCustomActionBarDB.isVisible = false
end

-- I redefined the function for the following reasons
-- original function name: UpdateUsable
-- error; 
-- Message: non-fatal assertion failed
-- Time: Mon May 19 23:59:29 2025
-- Count: 28
-- Stack:
-- [Interface/AddOns/Blizzard_ActionBar/Mainline/ActionButton.lua]:665: in function 'UpdateUsable'
local function MyUpdateUsable(self)
	local icon = self.icon;

	assertsafe(action == nil or action == self.action);
	if isUsable == nil or notEnoughMana == nil then
		isUsable, notEnoughMana = IsUsableAction(self.action);
	end
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
	end

	local isLevelLinkLocked = C_LevelLink.IsActionLocked(self.action);
	if not icon:IsDesaturated() then
		icon:SetDesaturated(isLevelLinkLocked);
	end

	if self.LevelLinkLockIcon then
		self.LevelLinkLockIcon:SetShown(isLevelLinkLocked);
	end
	self:EvaluateState(); 
end


-- I rewrite the function for the following reasons
-- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'AjaeButton6:SetAttribute()' 호출을 시도했습니다.
-- [Blizzard_ActionBar/Mainline/ActionButton.lua]:1588: in function <Blizzard_ActionBar/Mainline/ActionButton.lua:1586>
-- below source code is in https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_ActionBar/Mainline/ActionButton.lua
function ActionButton_UpdateCooldown(self)
	local locStart, locDuration;
	local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration;
	local modRate = 1.0;
	local chargeModRate = 1.0;
	local actionType, actionID = nil; 
	if (self.action) then 
		actionType, actionID = GetActionInfo(self.action);
	end 
	local auraData = nil;
	local passiveCooldownSpellID = nil;
	local onEquipPassiveSpellID = nil;

	if(actionID) then 
		onEquipPassiveSpellID = C_ActionBar.GetItemActionOnEquipSpellID(self.action);
	end

	if (onEquipPassiveSpellID) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(onEquipPassiveSpellID);
	elseif ((actionType and actionType == "spell") and actionID ) then 
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(actionID);
	elseif(self.spellID) then 
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(self.spellID);
	end

	if(passiveCooldownSpellID and passiveCooldownSpellID ~= 0) then 
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

	if(auraData) then
		local currentTime = GetTime();
		local timeUntilExpire = auraData.expirationTime - currentTime;
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire; 

		locStart =  currentTime - howMuchTimeHasPassed;
		locDuration = auraData.expirationTime - currentTime;
		start = currentTime - howMuchTimeHasPassed;
		duration =  auraData.duration
		modRate = auraData.timeMod; 
		charges = auraData.charges; 
		maxCharges = auraData.maxCharges; 
		chargeStart = currentTime * 0.001; 
		chargeDuration = duration * 0.001;
		chargeModRate = modRate; 
		enable = 1; 
	elseif (self.spellID) then
		locStart, locDuration = C_Spell.GetSpellLossOfControlCooldown(self.spellID);
		
		local spellCooldownInfo = C_Spell.GetSpellCooldown(self.spellID) or {startTime = 0, duration = 0, isEnabled = false, modRate = 0};
		start, duration, enable, modRate = spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;

		local chargeInfo = C_Spell.GetSpellCharges(self.spellID) or {currentCharges = 0, maxCharges = 0, cooldownStartTime = 0, cooldownDuration = 0, chargeModRate = 0};
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = chargeInfo.currentCharges, chargeInfo.maxCharges, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate;
	else
		locStart, locDuration = GetActionLossOfControlCooldown(self.action);
		start, duration, enable, modRate = GetActionCooldown(self.action);
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(self.action);
	end

	if ( (locStart + locDuration) > (start + duration) ) then
		if ( self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-LoC");
			self.cooldown:SetSwipeColor(0.17, 0, 0);
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_LOSS_OF_CONTROL;
			ActionButton_UpdateCooldownNumberHidden(self);
		end

		CooldownFrame_Set(self.cooldown, locStart, locDuration, true, true, modRate);
		self.cooldown:SetScript("OnCooldownDone", ActionButtonCooldown_OnCooldownDone, false);
		ClearChargeCooldown(self);
	else
		if ( self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_NORMAL ) then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-SecondaryCooldown");
			self.cooldown:SetSwipeColor(0, 0, 0);
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL;
			ActionButton_UpdateCooldownNumberHidden(self);
		end

		self.cooldown:SetScript("OnCooldownDone", ActionButtonCooldown_OnCooldownDone, locStart > 0);

		if ( charges and maxCharges and maxCharges > 1 and charges < maxCharges ) then
			StartChargeCooldown(self, chargeStart, chargeDuration, chargeModRate);
		else
			ClearChargeCooldown(self);
		end

		CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
	end
end



-- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceBar:ClearAllPointsBase()' 호출을 시도했습니다.
-- [C]: ?
function ActionBarController_UpdateAll(force)
	PossessActionBar:Update();
	StanceBar:Update();
	CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_MAIN;

	-- If we have a skinned vehicle bar or skinned override bar, display the OverrideActionBar
	if ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
		or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= 0)) then
		OverrideActionBar:UpdateSkin();
		CURRENT_ACTION_BAR_STATE = LE_ACTIONBAR_STATE_OVERRIDE;
	-- If we have a non-skinned override bar of some sort, use the MainMenuBar
	elseif ( HasBonusActionBar() or HasOverrideActionBar() or HasVehicleActionBar() or HasTempShapeshiftActionBar() or C_PetBattles.IsInBattle() ) then
		if (HasVehicleActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetVehicleBarIndex());
		elseif (HasOverrideActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetOverrideBarIndex());
		elseif (HasTempShapeshiftActionBar()) then
			MainMenuBar:SetAttribute("actionpage", GetTempShapeshiftBarIndex());
		elseif (HasBonusActionBar() and GetActionBarPage() == 1) then
			MainMenuBar:SetAttribute("actionpage", GetBonusBarIndex());
		else
			MainMenuBar:SetAttribute("actionpage", GetActionBarPage());
		end

		for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
			frame:UpdateAction(force);
		end
	else
		-- Otherwise, display the normal action bar
		ActionBarController_ResetToDefault(force);
	end

	ValidateActionBarTransition();
end



--
-- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceButton1:SetShown()' 호출을 시도했습니다.
-- [C]: ?
function MyShouldShow(self)
	--if self.numForms == nil then self.numForms = 1 end
	--local val = IsPossessBarVisible()
	--print("self.numForms: ", self.numForms)
	--print("possible; ", val)
	--print("state: ", ActionBarController_GetCurrentActionBarState() ~= LE_ACTIONBAR_STATE_OVERRIDE)
	--return self.numForms > 0 and not val and ActionBarController_GetCurrentActionBarState() ~= LE_ACTIONBAR_STATE_OVERRIDE
end

function MySetShown(self)
	--local val = self:ShouldShow()
	--self:SetShown(val)
end




-- 버튼 생성
local function makeButton(startN, endN)
    print("ajaebutton makeButton called")
    local j = endN or NUM_ACTION_BUTTONS

    for i = startN or 1, j do
        local btn = CreateFrame("CheckButton", ACTIONBAR_NAME .. i, UIParent, "ActionBarButtonTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetNormalTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetPushedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetHighlightTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetCheckedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)


        local row = math.floor((i - 1) / BUTTONS_PER_ROW)
        local col = (i - 1) % BUTTONS_PER_ROW

        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            100 + col * (BUTTON_SIZE + BUTTON_SPACING),
            -100 - row * (BUTTON_SIZE + BUTTON_SPACING)
        )

        btn:SetID(actionID + i)
        btn.action = actionID + i

        -- 아이콘 수동 생성
        -- 버튼이 생성될 때 텍스쳐를 아무 것도 안나타나게 해야 하는데 아직 그렇게는 못했다
        btn.icon:ClearAllPoints()
        btn.icon:SetPoint("TOPLEFT", 2, -2)
        btn.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        btn.icon:Hide()
        --btn.icon:SetTexture(nil)

        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:RegisterForDrag("LeftButton")
        
        btn:SetScript("OnDragStart", function(self)
            if not isLocked then self:StartMoving() end
        end)
	
        btn:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            MyCustomActionBarDbData[i] = MyCustomActionBarDbData[i] or {}
            local x, y = self:GetLeft(), self:GetTop()
            MyCustomActionBarDbData[i].pos = { x = x, y = y }
        end)

        -- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceButton1:SetShown()' 호출을 시도했습니다.
		-- [C]: ?
		local stanceButton = _G["StanceButton" .. i]
		if stanceButton then
			stanceButton.SetShown = MySetShown
			stanceButton.ShouldShow = MyShouldShow
			print("❌ StanceBar" .. i .. " 숨김 처리 완료!")
		end


        -- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceBarButtonContainer1:SetShown()' 호출을 시도했습니다.
        -- [C]: ?
		local stanceBarButtonContainer = _G["StanceBarButtonContainer" .. i]
		if stanceBarButtonContainer then
			stanceBarButtonContainer.SetShown = MySetShown
			stanceBarButtonContainer.ShouldShow = MyShouldShow
			print("❌ StanceBar" .. i .. " 숨김 처리 완료!")
		end


        -- Texture settings and size correction
        -- Use inherited traits without anything special
        --btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
        --NormalTexture is displayed small again inside the button, so I clear it.
        btn:GetNormalTexture():ClearAllPoints()
        btn.UpdateUsable =  MyUpdateUsable
        btn:Update()

        buttons[i] = btn
    end
end


local function makeLoadButton(startN, endN)
    print("ajaebutton makeLoadButton called")
    local j = endN or NUM_ACTION_BUTTONS

    for i = startN or 1, j do

        local btn = CreateFrame("CheckButton", ACTIONBAR_NAME .. i, UIParent, "ActionBarButtonTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetNormalTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetPushedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetHighlightTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:GetCheckedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)

        
        local row = math.floor((i - 1) / BUTTONS_PER_ROW)
        local col = (i - 1) % BUTTONS_PER_ROW

        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            100 + col * (BUTTON_SIZE + BUTTON_SPACING),
            -100 - row * (BUTTON_SIZE + BUTTON_SPACING)
        )
        
        local saved = MyCustomActionBarDbData[i]
        if saved then
            if saved.pos then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
            end
		end

        btn:SetID(actionID + i)
        btn.action = actionID + i

        -- 아이콘 수동 생성
        -- 버튼이 생성될 때 텍스쳐를 아무 것도 안나타나게 해야 하는데 아직 그렇게는 못했다
        btn.icon:ClearAllPoints()
        btn.icon:SetPoint("TOPLEFT", 2, -2)
        btn.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        --btn.icon:SetTexture(nil)

        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:RegisterForDrag("LeftButton")
        
        btn:SetScript("OnDragStart", function(self)
            if not isLocked then self:StartMoving() end
        end)
	
        btn:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            MyCustomActionBarDbData[i] = MyCustomActionBarDbData[i] or {}
            local x, y = self:GetLeft(), self:GetTop()
            MyCustomActionBarDbData[i].pos = { x = x, y = y }
        end)

        -- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceButton1:SetShown()' 호출을 시도했습니다.
		-- [C]: ?
		local stanceButton = _G["StanceButton" .. i]
		if stanceButton then
			stanceButton.SetShown = MySetShown
			stanceButton.ShouldShow = MyShouldShow
			print("❌ StanceBar" .. i .. " 숨김 처리 완료!")
		end


        -- 1x [ADDON_ACTION_BLOCKED] 애드온 'AjaeButton'|1이;가; 보호된 함수 'StanceBarButtonContainer1:SetShown()' 호출을 시도했습니다.
        -- [C]: ?
		local stanceBarButtonContainer = _G["StanceBarButtonContainer" .. i]
		if stanceBarButtonContainer then
			stanceBarButtonContainer.SetShown = MySetShown
			stanceBarButtonContainer.ShouldShow = MyShouldShow
			print("❌ StanceBar" .. i .. " 숨김 처리 완료!")
		end

        
        
        -- Texture settings and size correction
        -- Use inherited traits without anything special
        --NormalTexture is displayed small again inside the button, so I clear it.
        btn:GetNormalTexture():ClearAllPoints()
        btn.UpdateUsable =  MyUpdateUsable
        btn:Update()

        buttons[i] = btn
    end
	
	if MyCustomActionBarDB.isLocked == true then
	    isLocked = true
	end
	
	if MyCustomActionBarDB.isVisible == false then
	    buttonUnVisable()
	end
end



-- 슬래시 명령어로 잠금/숨김 토글 및 설정
SLASH_AJAEBUTTON1 = "/ajaebutton"
SlashCmdList["AJAEBUTTON"] = function(msg)
    msg = msg:lower()
    if msg == "lock" then
        isLocked = true
		MyCustomActionBarDB.isLocked = true
        print("🔒 버튼 이동 잠금")
    elseif msg == "unlock" then
        isLocked = false
		MyCustomActionBarDB.isLocked = false
        print("🔓 버튼 이동 해제")
    elseif msg == "hide" then
        buttonUnVisable()
        print("🙈 버튼 숨김")
    elseif msg == "show" then
        buttonVisable()
        print("👁️ 버튼 표시")
    elseif msg == "status" then
        print("ㅁajaebutton cnt: ", #buttons)
    elseif msg == "init" then
        clearButton()
        print("ㅁajaebutton clear: current cnt is ", #buttons)
    elseif msg == "help" then
        print("|cffffff00/ajaebutton lock|unlock|hide|show|status|init||num0~", BUTTON_LIMIT_CNT, "|size10~100|r")
        print("|cffffff00 lock - ajaebutton don't move")
        print("|cffffff00 unlock - ajaebutton movable")
        print("|cffffff00 hide - ajaebutton unvisible")
        print("|cffffff00 show - ajaebutton visible")
        print("|cffffff00 num[count] - ex: num3 create ajaebutton count [count]|r")
        print("|cffffff00            - create num count limit 0 ~ ", BUTTON_LIMIT_CNT)
        print("|cffffff00 size[size] - ex: size30 change ajaebutton size [size]")
        print("|cffffff00            - size num limit 10 ~ 100")
        print("|cffffff00 status - show ajaebutton count")
        print("|cffffff00 init - delete all ajaebutton and delete all saved data")
    elseif msg:find("num%d+") then
        local n = tonumber(msg:match("%d+"))
        if n and n >= 0 and n <= BUTTON_LIMIT_CNT then
            print("change actionabr number: ", n," before number: ", NUM_ACTION_BUTTONS)
            -- If the action bar increases in number beyond the original number, only the increased number of action buttons will be created.
            if n > NUM_ACTION_BUTTONS then
                print("increase start button number: ", NUM_ACTION_BUTTONS+1, " increase end button number: ", n - NUM_ACTION_BUTTONS + NUM_ACTION_BUTTONS)
			    makeButton(NUM_ACTION_BUTTONS + 1, n - NUM_ACTION_BUTTONS + NUM_ACTION_BUTTONS)
            else
			    local diffNum = NUM_ACTION_BUTTONS - n
				local listLen = #buttons
                print("reduce actionbar count: ", diffNum, " d: ", listLen)
				for i=1, diffNum do
                    print("chnage start button count")
                    RemoveButton(listLen)
                    listLen = listLen - 1
                end
                --remakeButton()
			end
            NUM_ACTION_BUTTONS = n
            MyCustomActionBarDB.buttonCnt = n
            updateButton()
        end
    elseif msg:find("size%d+") then
        local s = tonumber(msg:match("%d+"))
        
        if s and s >= 10 and s <= 100 then
            print("change button size ", BUTTON_SIZE, " to ", s)
            BUTTON_SIZE = s
			MyCustomActionBarDB.buttonSize = s
            setButtonSize()
            updateButton()
        end
    else
        print("|cffffff00/ajaebutton lock|unlock|hide|show|status|init||num0~", BUTTON_LIMIT_CNT, "|size10~100|r")
        print("|cffffff00 more infomation command /ajaebutton help")
    end
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    NUM_ACTION_BUTTONS = MyCustomActionBarDB.buttonCnt or DEFAULT_BUTTON_CNT --최초에 버튼개수는 3개이고
    BUTTON_SIZE = MyCustomActionBarDB.buttonSize or DEFAULT_BUTTON_SIZE -- 최초의 버튼 사이즈는 40

    if MyCustomActionBarDB.buttonSize == nil then   -- 애드온을 처음 설치해서 변수가 없는 경우
        MyCustomActionBarDB.buttonSize = BUTTON_SIZE  -- 기본 크기로 데이터 저장한다
    end

    if MyCustomActionBarDB.buttonCnt == nil then  -- 애드온을 처음 설치해서 버튼 개수가 없는 경우
        MyCustomActionBarDB.buttonCnt = NUM_ACTION_BUTTONS  -- 기본 값인 3을 넣어서 버튼 3개가 생기게 한다.
        makeButton(1, NUM_ACTION_BUTTONS)
    else
        if MyCustomActionBarDbData and #MyCustomActionBarDbData ~= 0 then -- 그 외 애드온을 사용하여 버튼 개수와 버튼 데이터가 존재하는 경우
            if NUM_ACTION_BUTTONS == #MyCustomActionBarDbData then        -- 버튼 데이터의 개수와 현재 버튼 설정의 개수가 같다면 
			    makeLoadButton(1, NUM_ACTION_BUTTONS)                         -- 해당 개수만큼 버튼을 만든다
			else
                NUM_ACTION_BUTTONS = #MyCustomActionBarDbData             -- 버튼 데이터의 개수와 현재 버튼 수 설정이 다르다면 데이터의 개수만큼 버튼 개수를 줄이고
                makeLoadButton(1, NUM_ACTION_BUTTONS)                     -- 버튼을 만든다.
            end
        else
		    MyCustomActionBarDB.buttonCnt = NUM_ACTION_BUTTONS          -- 버튼 개수는 있는데 버튼 데이터가 없는 이상한 경우라면 설정된 버튼 개수
			makeButton(1, NUM_ACTION_BUTTONS)                           -- 만큼 버튼을 신규로 생성 한다.
		end
    end

    updateButton() -- 버튼 생성 시 1번 action button의 아이콘이 최초에 겹쳐 보이는 것을 방지 한다.
end)


