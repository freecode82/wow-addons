﻿-- 최종 커스텀 액션 버튼 + 저장/복원 + 잠금/숨김 + 설정창 기능 포함
-- SavedVariables: MyCustomActionBarDB
-- maker: kcw2020@naver.com
-- This addon is based on Blizzard's ActionButton.lua. Some functions conflict with the game's default action bar, so they have been redefined and assigned.
MyCustomActionBarDB = MyCustomActionBarDB or {}
MyCustomActionBarDbData = MyCustomActionBarDbData or {}

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
-- ActionBarButtonTemplate으로 버튼을 만드는 경우 1~180까지 사용 가능
-- 1~120은 기본 블리자드가 사용 하는 것으로 나는 130부터 시작하여 180까지 총 50개를 제공한다.
firstActioonNum = 150
actionID = firstActioonNum

local wrapper = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

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
    NUM_ACTION_BUTTONS = 0
    MyCustomActionBarDB.buttonCnt = 0
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
		--icon:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		--icon:SetVertexColor(0.5, 0.5, 1.0);
	else
		--icon:SetVertexColor(0.4, 0.4, 0.4);
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


local function myButtonHooked()
    local protectedFunctions = {
        "SetAttribute"
    }
	
	for i=1, BUTTON_LIMIT_CNT do
        for _, funcName in ipairs(protectedFunctions) do
		    local ajaeButtonVal = _G["AjaeButton" .. i]
            if ajaeButtonVal then
        	    ajaeButtonVal[funcName] = function() end
			end
		end
	end
end

local function DisableMultiBarInteraction()
    if _G["AjaeButton_MultiBarHooked"] then return end
    
    -- 보호된 함수들에 대한 접근을 차단
    local protectedFunctions = {
        "SetAttribute"
    }
	
    for i=1, BUTTON_LIMIT_CNT do
        for _, funcName in ipairs(protectedFunctions) do
            local ActionButtonVal = _G["ActionButton" .. i]
            if ActionButtonVal then
        	    ActionButtonVal[funcName] = function() end
			end

            local multibarBottomLeft = _G["MultiBarBottomLeftButton" .. i]
            if multibarBottomLeft then
        	    multibarBottomLeft[funcName] = function() end
			end

            local multibarBottomRight = _G["MultiBarBottomRightButton" .. i]
            if multibarBottomRight then
        	    multibarBottomRight[funcName] = function() end
			end

            local OverrideActionBarButtonVal = _G["OverrideActionBarButton" .. i]
            if OverrideActionBarButtonVal then
        	    OverrideActionBarButtonVal[funcName] = function() end
			end

            --local ajaeButtonVal = _G["AjaeButton" .. i]
            --if ajaeButtonVal then
        	--    ajaeButtonVal[funcName] = function() end
			--end

            for j=1, BUTTON_LIMIT_CNT do
                local multiBarButtonVal = _G["MultiBar" .. i .. "Button" .. j]
                if multiBarButtonVal then
        	        multiBarButtonVal[funcName] = function() end
			    end
			end
        end
    end
    
    _G["AjaeButton_MultiBarHooked"] = true
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

        -- btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
        -- btn:GetNormalTexture():SetAllPoints()


        local row = math.floor((i - 1) / BUTTONS_PER_ROW)
        local col = (i - 1) % BUTTONS_PER_ROW

        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            100 + col * (BUTTON_SIZE + BUTTON_SPACING),
            -100 - row * (BUTTON_SIZE + BUTTON_SPACING)
        )

        btn:SetID(actionID + i)
        btn.action = actionID + i

        -- btn:SetAttribute("checkselfcast", true)
        -- btn:SetAttribute("checkfocuscast", true)
        -- btn:SetAttribute("checkmouseovercast", true)
        -- btn:SetAttribute("useparent-actionpage", true)
        btn:SetAttribute("pressAndHoldAction", true)


        -- 아이콘 수동 생성
        -- 버튼이 생성될 때 텍스쳐를 아무 것도 안나타나게 해야 하는데 아직 그렇게는 못했다
        btn.icon:ClearAllPoints()
        btn.icon:SetPoint("TOPLEFT", 2, -2)
        btn.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        btn.icon:Hide()
        --btn.icon:SetTexture(nil)

        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:RegisterForClicks("AnyUp", "AnyDown");
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

        -- 버튼 삭제
        --[[
        btn:SetScript("OnMouseUp", function(self, button)
            if IsShiftKeyDown() and IsAltKeyDown() and button == "RightButton" then
                print("🔎 마우스로 클릭한 버튼 ", self:GetName(), "를 삭제합니다")
            end
        end)
        ]]

        wrapper:SetFrameRef("mybtn"..i, btn)
        wrapper:Execute([[
            -- local b = self:GetFrameRef("mybtn"..i)
            -- b:SetAttribute("pressAndHoldAction", true)
        ]])

        wrapper:WrapScript(btn, "OnClick", [[
            -- if down then
                -- 클릭이 눌렸을 때만 반응 (AnyDown이면 true로 들어옴)
                -- secure context 안에서의 로직만 가능
                -- 예: 특정 조건에서만 시전 허용
                -- self:SetAttribute("enabled", true) -- 예시: 속성 조작
            -- end
        ]])

        -- wrapper:WrapScript(btn, "OnReceiveDrag", [[ ]])

        -- Texture settings and size correction
        -- Use inherited traits without anything special
        -- btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
        -- NormalTexture is displayed small again inside the button, so I clear it.
        btn:GetNormalTexture():ClearAllPoints()
        btn.UpdateUsable =  MyUpdateUsable
        btn:Update()

        buttons[i] = btn
        
        -- 버튼을 처음 생성 후 이동 시키지 않아도 위치를 저장한다.
        MyCustomActionBarDbData[i] = MyCustomActionBarDbData[i] or {}
        local x, y = btn:GetLeft(), btn:GetTop()
        MyCustomActionBarDbData[i].pos = { x = x, y = y }

        -- print("my action num; ", btn.action)
    end

    -- myButtonHooked()
    -- DisableMultiBarInteraction()
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

        -- btn:SetAttribute("checkselfcast", true)
        -- btn:SetAttribute("checkfocuscast", true)
        -- btn:SetAttribute("checkmouseovercast", true)
        -- btn:SetAttribute("useparent-actionpage", false)
        btn:SetAttribute("pressAndHoldAction", true)

        -- 아이콘 수동 생성
        -- 버튼이 생성될 때 텍스쳐를 아무 것도 안나타나게 해야 하는데 아직 그렇게는 못했다
        btn.icon:ClearAllPoints()
        btn.icon:SetPoint("TOPLEFT", 2, -2)
        btn.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        --btn.icon:SetTexture(nil)

        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:RegisterForClicks("AnyUp", "AnyDown");
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

        -- 버튼 삭제 기능
        --[[
        btn:SetScript("OnMouseUp", function(self, button)
            if IsShiftKeyDown() and IsAltKeyDown() and button == "RightButton" then
                print("🔎 마우스로 클릭한 버튼 ", self:GetName(), "를 삭제합니다")
            end
        end)
        ]]

        wrapper:SetFrameRef("mybtn"..i, btn)
        wrapper:Execute([[
            -- local b = self:GetFrameRef("mybtn"..i)
            -- b:SetAttribute("pressAndHoldAction", true)
        ]])

        wrapper:WrapScript(btn, "OnClick", [[
            -- if down then
                -- 클릭이 눌렸을 때만 반응 (AnyDown이면 true로 들어옴)
                -- secure context 안에서의 로직만 가능
                -- 예: 특정 조건에서만 시전 허용
                -- self:SetAttribute("enabled", true) -- 예시: 속성 조작
            -- end
        ]])

        -- Texture settings and size correction
        -- Use inherited traits without anything special
        --NormalTexture is displayed small again inside the button, so I clear it.
        btn:GetNormalTexture():ClearAllPoints()
        btn.UpdateUsable =  MyUpdateUsable
        btn:Update()

        buttons[i] = btn

        -- print("my action num; ", btn.action)
    end
	
	if MyCustomActionBarDB.isLocked == true then
	    isLocked = true
	end
	
	if MyCustomActionBarDB.isVisible == false then
	    buttonUnVisable()
	end

    -- myButtonHooked()
    -- DisableMultiBarInteraction()
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

local function checkButtonCnt()
    local btnCnt = 0
    for i=1, BUTTON_LIMIT_CNT do
        local checkBtn = _G["AjaeButton" .. i]
        if checkBtn then
        	btnCnt = btnCnt + 1
        end
	end
    print("button cnt: ", btnCnt)

    if btnCnt ~= MyCustomActionBarDB.buttonCnt then
	    print("애드온 UI 이상으로 생성한 버튼의 개수와 실제 개수가 다릅니다.")
		print("애드온 개수 다시 설정 중")
	    
        buttons = {} 
	    MyCustomActionBarDB.buttonCnt = btnCnt
		NUM_ACTION_BUTTONS = btnCnt

        if MyCustomActionBarDB.buttonSize then
		    BUTTON_SIZE = MyCustomActionBarDB.buttonSize
        else
            MyCustomActionBarDB.buttonSize = BUTTON_SIZE
		end
		
		for i=1, btnCnt do
		    local checkBtn = _G["AjaeButton" .. i]
			print(checkBtn:GetSize())
			MyCustomActionBarDbData[i].pos = {x = checkBtn:GetLeft(), y = checkBtn:GetTop()}
            buttons[i] = checkBtn
		end
        print("애드온 개수 설정 완료")
	end
end


-- 경고창 비활성화
UIParent:HookScript("OnEvent", function(s, e, a1, a2)
    -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
	if e == "ADDON_ACTION_FORBIDDEN" and a1 == "AjaeButton4" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		StaticPopup_Hide(e)
	end

    if e == "ADDON_ACTION_BLOCKED" and a1 == "AjaeButton4" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		StaticPopup_Hide(e)
	end
end)

		
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

    -- addon error check
    checkButtonCnt()
end)
