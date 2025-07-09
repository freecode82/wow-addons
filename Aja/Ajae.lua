-- 최종 커스텀 액션 버튼 + 저장/복원 + 잠금/숨김 + 설정창 기능 포함
-- SavedVariables: AjaeMyCustomActionBarDB
-- This addon is based on 

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

-- Secure click 핸들링용 프레임
local wrapper = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")



-- 버튼 생성
local function makeButton(startN, endN)
    print("ajaebutton makeButton called")
    local j = endN or NUM_ACTION_BUTTONS

    for i = startN or 1, j do
        local btn = CreateFrame("CheckButton", ACTIONBAR_NAME .. i, UIParent, "ActionButtonTemplate, SecureActionButtonTemplate")

        btn.WIcon 			= _G[ACTIONBAR_NAME .. i .. "Icon"];
        btn.WNormalTexture 	= _G[ACTIONBAR_NAME .. i .. "NormalTexture"];
        btn.WCooldown 		= _G[ACTIONBAR_NAME .. i .. "Cooldown"];	
        btn.WCount 			= _G[ACTIONBAR_NAME .. i .. "Count"];
        btn.WBorder 		= _G[ACTIONBAR_NAME .. i .. "Border"];
        btn.WFlashTexture 	= _G[ACTIONBAR_NAME .. i .. "Flash"];
        btn.WHotKey 		= _G[ACTIONBAR_NAME .. i .. "HotKey"];
        btn.WName 			= _G[ACTIONBAR_NAME .. i .. "Name"];

        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn.WNormalTexture:SetSize(BUTTON_SIZE + 7,BUTTON_SIZE + 7) -- 이정도가 적당
        btn.PushedTexture:SetSize(BUTTON_SIZE + 4,BUTTON_SIZE + 4) -- 이정도가 적당
        btn.HighlightTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.CheckedTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.SlotBackground:SetSize(BUTTON_SIZE, BUTTON_SIZE) 

        local row = math.floor((i - 1) / BUTTONS_PER_ROW)
        local col = (i - 1) % BUTTONS_PER_ROW

        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            100 + col * (BUTTON_SIZE + BUTTON_SPACING),
            -100 - row * (BUTTON_SIZE + BUTTON_SPACING)
        )

        btn.myIndex = i
        btn:SetID(actionID + i)
        btn.action = actionID + i
        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:SetAttribute("pressAndHoldAction", true)
        btn:RegisterForClicks("AnyUp", "AnyDown");
        btn:RegisterForDrag("LeftButton")
        btn.cooldown = btn.WCooldown
        -- btn.cooldown:SetAllPoints()
        
        btn.GetFullSpellName = GetFullSpellName
        btn.UpdateTextCountSpell = UpdateTextCountSpell
        btn.UpdateTextCountItem = UpdateTextCountItem;
        btn.UpdateTextCountMacro = UpdateTextCountMacro
        btn.UpdateTextCountBonusAction = UpdateTextCountBonusAction
        btn.ChangeAttribute = ChangeAttribute
        btn.SpellRegisterProcess = SpellRegisterProcess
        btn.ItemRegisterProcess = ItemRegisterProcess
        btn.MacroRegisterProcess = MacroRegisterProcess
        btn.MountRegisterProcess = MountRegisterProcess
        btn.SpellLoadProcess = SpellLoadProcess
        btn.ItemLoadProcess = ItemLoadProcess
        btn.MacroLoadProcess = MacroLoadProcess
        btn.MountLoadProcess = MountLoadProcess
        btn.SpellUpdateUsable = SpellUpdateUsable
        btn.CoolTimeMySet = CoolTimeMySet
        btn.SpellUpdateUsable = SpellUpdateUsable
        
        
        btn:SetScript("OnDragStart", function(self)
            if not isLocked then self:StartMoving() end
        end)
        btn:SetScript("OnDragStop", MoveInfoSave)

        btn:SetScript("OnEnter", ShowMyTooltip)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)


        	
        -- 이벤트 등록 및 쿨다운 업데이트
        btn:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        btn:RegisterEvent("SPELL_UPDATE_USABLE")
        btn:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
        btn:SetScript("OnEvent", function(self, event)
            if event == "ACTIONBAR_UPDATE_COOLDOWN" then
                self:CoolTimeMySet()
			end
			
			if event == "SPELL_UPDATE_USABLE" then
			    --self:SpellUpdateUsable()
			end
		end)

        -- getcursorinfo value 
        -- skill : cursottype = spell, actionid = id, info2 = spell, spellID = skill_id
        -- item : cursottype = item, actionid = item_id, info2 = item_link, spellID = nill
        -- macro: cursortype = macro, actionID = macro_slot_number, info2 = nil, spellID = nil
        -- mount(탈것): cursortype = mount, actionID = mountID, info2 = mount_iconid, spellID = nil
        btn:SetScript("OnMouseDown", function(self, button)
            if InCombatLockdown() then return end -- 전투 중 변경 불가

            if IsShiftKeyDown() and IsAltKeyDown() and button == "RightButton" then
		        print("🔎 마우스로 클릭한 버튼 ", self:GetName(), "를 삭제합니다")
		        
		        --if self.WBorder then self.WBorder:Hide() end
		        --if self.WFlashTexture then self.WFlashTexture:Hide() end
		        --if self.WName then self.WName:SetText("") end
		        --if self.WNormalTexture then self.WNormalTexture:SetTexture(nil) end
		        if self.cooldown then
		        	-- self.cooldown:Clear()
		        	CooldownFrame_Set(self.cooldown, 0, 0, 0)
		        	self.cooldown:Hide()
		        end

		        if self.chargeCooldown then
		        	self.chargeCooldown:SetCooldown(0, 0)
		        	self.chargeCooldown:Hide()
		        end

                -- 기본 속성 제거 및 내부 모드 관련 변수 초기화
                -- 비동기 방식으로 작동해서 안에 이 코드를 넣지 않으면 올바르게 속성 초기화가 안된다.
                -- 탈것 버튼 이후 아이템 넣었는데 탈것과 아이템이 번갈아가며 작동 방지
                -- 탉것 버튼 이후 스킬 넣으면 탈것과 스킬이 번갈아가며 작동 방지
                self:SetAttribute("type", nil)
                self:SetAttribute("spell", nil)
                self:SetAttribute("item", nil)
                self:SetAttribute("macro", nil)
                self:SetAttribute("macrotext", nil)
                self:SetAttribute("ItemId", nil)
                self:SetAttribute("typerelease", nil)
                self:SetAttribute("skipNextClick", nil)
                self.mode = nil
                self.SpellName = nil
                self.SpellNameRank = nil
                self.spellIDInfo = nil
                self.ItemId = nil
                self.MacroName = nil
		        if self.WCount then self.WCount:SetText("") end
		        if self.WIcon then self.WIcon:SetTexture(nil) end
                self:SetAttribute("skipNextClick", nil)

                -- 디비에 저장된 버튼의 정보도 지운다
                local data = AjaeMyCustomActionBarDBData[self.myIndex]
                if data then
                    for key in pairs(data) do
                        if key ~= "pos" then
                            data[key] = nil
                        end
                    end
                end
	        end
        
            local cursorType, actionID, info2, spellID = GetCursorInfo()
            if cursorType == nil then return end

        	-- print("new info:", cursorType, actionID, info2, spellID)

            -- 기본 속성 제거 및 내부 모드 관련 변수 초기화
            -- 비동기 방식으로 작동해서 안에 이 코드를 넣지 않으면 올바르게 속성 초기화가 안된다.
            -- 탈것 버튼 이후 아이템 넣었는데 탈것과 아이템이 번갈아가며 작동 방지
            -- 탉것 버튼 이후 스킬 넣으면 탈것과 스킬이 번갈아가며 작동 방지
            self:SetAttribute("type", nil)
            self:SetAttribute("spell", nil)
            self:SetAttribute("item", nil)
            self:SetAttribute("macro", nil)
            self:SetAttribute("macrotext", nil)
            self:SetAttribute("ItemId", nil)
            self:SetAttribute("typerelease", nil)
            self.mode = nil
            self.SpellName = nil
            self.SpellNameRank = nil
            self.spellIDInfo = nil
            self.ItemId = nil
            self.MacroName = nil
          

            self:SetAttribute("skipNextClick", true)
            if cursorType == "spell" then
        		self:SpellRegisterProcess(actionID, spellID)
            elseif cursorType == "item" then
        		self:ItemRegisterProcess(actionID, info2)
            elseif cursorType == "macro" then
        		self:MacroRegisterProcess(actionID)
            elseif cursorType == "mount" then
                self:MountRegisterProcess(actionID)
            else
                -- print("⚠️ 올바른 스킬 데이터가 아님")
            end
        
        	ClearCursor()
        end)
        
        -- 보호된 클릭에 대한 WrapScript 처리 (옵션: 누를 때 다른 행동 삽입 가능)
        wrapper:SetFrameRef("mybtn" .. i, btn)
        --  버튼이 로드 되면 실행됨
        wrapper:Execute([[
        ]])

        -- 이벤트 발생 시 마다 실행됨
        -- 탈것 버튼에 넣을 때 탈것에 타지는 것 -- 해결
        -- 먹을 것 같은 음식을 버튼에 넣을 시 한개가 먹어지는 것 -- 해결
        -- 탈 것을 탈때에 프리작업으로 매크로가 실행 안되게 한다.
        wrapper:WrapScript(btn, "PreClick", [[
            if self.mode == "mount" then
                if self:GetAttribute("skipNextClick") then
                    self:SetAttribute("skipNextClick", nil)
                    return false  -- 클릭 동작 무시
                end
            end
        ]])

        wrapper:WrapScript(btn, "OnClick", [[
        	if self:GetAttribute("skipNextClick") then
                self:SetAttribute("skipNextClick", nil)
                return false -- 클릭 동작 무시
            end
        ]])


        buttons[i] = btn
        
        -- 버튼을 처음 생성 후 이동 시키지 않아도 위치를 저장한다.
        AjaeMyCustomActionBarDBData[i] = AjaeMyCustomActionBarDBData[i] or {}
        local x, y = btn:GetLeft(), btn:GetTop()
        AjaeMyCustomActionBarDBData[i].pos = { x = x, y = y }
        --print(AjaeMyCustomActionBarDBData[i].pos.x, AjaeMyCustomActionBarDBData[i].pos.y)
        -- print("my action num; ", btn.action)
    end
end



local function makeLoadButton(startN, endN)
    print("ajaebutton makeLoadButton called")
    local j = endN or NUM_ACTION_BUTTONS

    for i = startN or 1, j do

        --local btn = CreateFrame("CheckButton", ACTIONBAR_NAME .. i, UIParent, "ActionBarButtonTemplate")
        local btn = CreateFrame("CheckButton", ACTIONBAR_NAME .. i, UIParent, "ActionButtonTemplate, SecureActionButtonTemplate")

        btn.WIcon 			= _G[ACTIONBAR_NAME .. i .. "Icon"];
        btn.WNormalTexture 	= _G[ACTIONBAR_NAME .. i .. "NormalTexture"];
        btn.WCooldown 		= _G[ACTIONBAR_NAME .. i .. "Cooldown"];	
        btn.WCount 			= _G[ACTIONBAR_NAME .. i .. "Count"];
        btn.WBorder 		= _G[ACTIONBAR_NAME .. i .. "Border"];
        btn.WFlashTexture 	= _G[ACTIONBAR_NAME .. i .. "Flash"];
        btn.WHotKey 		= _G[ACTIONBAR_NAME .. i .. "HotKey"];
        btn.WName 			= _G[ACTIONBAR_NAME .. i .. "Name"];

        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn.WNormalTexture:SetSize(BUTTON_SIZE + 7,BUTTON_SIZE + 7) -- 이정도가 적당
        btn.PushedTexture:SetSize(BUTTON_SIZE + 4,BUTTON_SIZE + 4) -- 이정도가 적당
        btn.HighlightTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.CheckedTexture:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
        btn.SlotBackground:SetSize(BUTTON_SIZE, BUTTON_SIZE) 
       

        local row = math.floor((i - 1) / BUTTONS_PER_ROW)
        local col = (i - 1) % BUTTONS_PER_ROW

        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            100 + col * (BUTTON_SIZE + BUTTON_SPACING),
            -100 - row * (BUTTON_SIZE + BUTTON_SPACING)
        )
        
        local saved = AjaeMyCustomActionBarDBData[i]
        --print("저장된 데이터: ", saved)
        if saved then
            if saved.pos then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
            end
		end

        btn.myIndex = i
        btn:SetID(actionID + i)
        btn.action = actionID + i
        btn:SetMovable(true)
        btn:EnableMouse(true)
        btn:SetAttribute("pressAndHoldAction", true)
        btn:RegisterForClicks("AnyUp", "AnyDown");
        btn:RegisterForDrag("LeftButton")
        btn.cooldown = btn.WCooldown
        -- btn.cooldown:SetAllPoints()
        
        btn.GetFullSpellName = GetFullSpellName
        btn.UpdateTextCountSpell = UpdateTextCountSpell
        btn.UpdateTextCountItem = UpdateTextCountItem;
        btn.UpdateTextCountMacro = UpdateTextCountMacro
        btn.UpdateTextCountBonusAction = UpdateTextCountBonusAction
        btn.ChangeAttribute = ChangeAttribute
        btn.SpellRegisterProcess = SpellRegisterProcess
        btn.ItemRegisterProcess = ItemRegisterProcess
        btn.MacroRegisterProcess = MacroRegisterProcess
        btn.MountRegisterProcess = MountRegisterProcess
        btn.SpellLoadProcess = SpellLoadProcess
        btn.ItemLoadProcess = ItemLoadProcess
        btn.MacroLoadProcess = MacroLoadProcess
        btn.MountLoadProcess = MountLoadProcess
        btn.CoolTimeMySet = CoolTimeMySet
        btn.SpellUpdateUsable = SpellUpdateUsable
        
        
        btn:SetScript("OnDragStart", function(self)
            if not isLocked then self:StartMoving() end
        end)
        btn:SetScript("OnDragStop", MoveInfoSave) 

        btn:SetScript("OnEnter", ShowMyTooltip)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- 이벤트 등록 및 쿨다운 업데이트
        btn:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        btn:RegisterEvent("SPELL_UPDATE_USABLE")
        btn:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
        btn:SetScript("OnEvent", function(self, event)
            if event == "ACTIONBAR_UPDATE_COOLDOWN" then
                self:CoolTimeMySet()
			end
			
			if event == "SPELL_UPDATE_USABLE" then
			    --self:SpellUpdateUsable()
			end
		end)

        -- getcursorinfo value 
        -- skill : cursottype = spell, actionid = id, info2 = spell, spellID = skill_id
        -- item : cursottype = item, actionid = item_id, info2 = item_link, spellID = nill
        -- macro: cursortype = macro, actionID = macro_slot_number, info2 = nil, spellID = nil
        -- mount(탈것): cursortype = mount, actionID = mountID, info2 = mount_iconid, spellID = nil
        btn:SetScript("OnMouseDown", function(self, button)
            if InCombatLockdown() then return end -- 전투 중 변경 불가

            if IsShiftKeyDown() and IsAltKeyDown() and button == "RightButton" then
		        --print("🔎 마우스로 클릭한 버튼 ", self:GetName(), "를 삭제합니다")
		        
		        --if self.WBorder then self.WBorder:Hide() end
		        --if self.WFlashTexture then self.WFlashTexture:Hide() end
		        --if self.WName then self.WName:SetText("") end
		        --if self.WNormalTexture then self.WNormalTexture:SetTexture(nil) end
		        if self.cooldown then
		        	self.cooldown:Clear()
		        	CooldownFrame_Set(self.cooldown, 0, 0, 0)
		        	self.cooldown:Hide()
		        end

		        if self.chargeCooldown then
		        	self.chargeCooldown:SetCooldown(0, 0)
		        	self.chargeCooldown:Hide()
		        end

                -- 기본 속성 제거 및 내부 모드 관련 변수 초기화
                -- 비동기 방식으로 작동해서 안에 이 코드를 넣지 않으면 올바르게 속성 초기화가 안된다.
                -- 탈것 버튼 이후 아이템 넣었는데 탈것과 아이템이 번갈아가며 작동 방지
                -- 탉것 버튼 이후 스킬 넣으면 탈것과 스킬이 번갈아가며 작동 방지
                self:SetAttribute("type", nil)
                self:SetAttribute("spell", nil)
                self:SetAttribute("item", nil)
                self:SetAttribute("macro", nil)
                self:SetAttribute("macrotext", nil)
                self:SetAttribute("ItemId", nil)
                self:SetAttribute("typerelease", nil)
                self:SetAttribute("skipNextClick", nil)
                self.mode = nil
                self.SpellName = nil
                self.SpellNameRank = nil
                self.spellIDInfo = nil
                self.ItemId = nil
                self.MacroName = nil
		        if self.WCount then self.WCount:SetText("") end
		        if self.WIcon then self.WIcon:SetTexture(nil) end
		        self:SetAttribute("skipNextClick", nil)

                -- 디비에 저장된 버튼의 정보도 지운다
                local data = AjaeMyCustomActionBarDBData[self.myIndex]
                if data then
                    for key in pairs(data) do
                        if key ~= "pos" then
                            data[key] = nil
                        end
                    end
                end
	        end
        
            local cursorType, actionID, info2, spellID = GetCursorInfo()
            if cursorType == nil then return end

        	-- print("new info:", cursorType, actionID, info2, spellID)

            -- 기본 속성 제거 및 내부 모드 관련 변수 초기화
            -- 비동기 방식으로 작동해서 안에 이 코드를 넣지 않으면 올바르게 속성 초기화가 안된다.
            -- 탈것 버튼 이후 아이템 넣었는데 탈것과 아이템이 번갈아가며 작동 방지
            -- 탉것 버튼 이후 스킬 넣으면 탈것과 스킬이 번갈아가며 작동 방지
            self:SetAttribute("type", nil)
            self:SetAttribute("spell", nil)
            self:SetAttribute("item", nil)
            self:SetAttribute("macro", nil)
            self:SetAttribute("macrotext", nil)
            self:SetAttribute("ItemId", nil)
            self:SetAttribute("typerelease", nil)
            self.mode = nil
            self.SpellName = nil
            self.SpellNameRank = nil
            self.spellIDInfo = nil
            self.ItemId = nil
            self.MacroName = nil
            
            self:SetAttribute("skipNextClick", true)
            if cursorType == "spell" then
        		self:SpellRegisterProcess(actionID, spellID)
            elseif cursorType == "item" then
        		self:ItemRegisterProcess(actionID, info2)
            elseif cursorType == "macro" then
        		self:MacroRegisterProcess(actionID)
            elseif cursorType == "mount" then
                -- actionID == MountID
                self:MountRegisterProcess(actionID)
            else
                -- print("⚠️ 올바른 스킬 데이터가 아님")
                self:SetAttribute("skipNextClick", nil)
            end
        	ClearCursor()
        end)
        
        if AjaeMyCustomActionBarDBData[i].mode == "skill" then
            btn:SpellLoadProcess()
		elseif AjaeMyCustomActionBarDBData[i].mode == "item" then
            btn:ItemLoadProcess()
		elseif AjaeMyCustomActionBarDBData[i].mode == "macro" then
            btn:MacroLoadProcess()
		elseif AjaeMyCustomActionBarDBData[i].mode == "mount" then
            btn:MountLoadProcess()
		else
            -- for future
		end

        -- 보호된 클릭에 대한 WrapScript 처리 (옵션: 누를 때 다른 행동 삽입 가능)
        wrapper:SetFrameRef("mybtn", btn)
        wrapper:Execute([[
        ]])
        
        -- 이벤트 발생 시 마다 실행됨
        -- 탈것 버튼에 넣을 때 탈것에 타지는 것 -- 해결
        -- 먹을 것 같은 음식을 버튼에 넣을 시 한개가 먹어지는 것 -- 해결
        -- 탈 것을 탈때에 프리작업으로 매크로가 실행 안되게 한다.
        wrapper:WrapScript(btn, "PreClick", [[
            if self.mode == "mount" then
                if self:GetAttribute("skipNextClick") then
                    self:SetAttribute("skipNextClick", nil)
                    return false  -- 클릭 동작 무시
                end
            end
        ]])

        wrapper:WrapScript(btn, "OnClick", [[
        	if self:GetAttribute("skipNextClick") then
                self:SetAttribute("skipNextClick", nil)
                return false -- 클릭 동작 무시
            end
        ]])

        buttons[i] = btn
        -- print("my action num; ", btn.action)
    end
	
	if AjaeMyCustomActionBarDB.isLocked == true then
	    isLocked = true
	end
	
	if AjaeMyCustomActionBarDB.isVisible == false then
	    buttonUnVisable()
	end
end



-- 슬래시 명령어로 잠금/숨김 토글 및 설정
SLASH_AJAE1 = "/ajae"
SlashCmdList["AJAE"] = function(msg)
    msg = msg:lower()
    if msg == "lock" then
        isLocked = true
		AjaeMyCustomActionBarDB.isLocked = true
        print("🔒 버튼 이동 잠금")
    elseif msg == "unlock" then
        isLocked = false
		AjaeMyCustomActionBarDB.isLocked = false
        print("🔓 버튼 이동 해제")
    elseif msg == "hide" then
        buttonUnVisable()
        print("🙈 버튼 숨김")
    elseif msg == "show" then
        buttonVisable()
        print("👁️ 버튼 표시")
    elseif msg == "status" then
        print("ㅁajaebutton cnt: ", #buttons)
    elseif msg == "detail" then
        ShowStatus()
    elseif msg == "init" then
        AjaeClearButton()
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
        print("|cffffff00 detail - show detail info")
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
                    AjaeRemoveButton(listLen)
                    listLen = listLen - 1
                end
			end
            NUM_ACTION_BUTTONS = n
            AjaeMyCustomActionBarDB.buttonCnt = n
        end
    elseif msg:find("size%d+") then
        local s = tonumber(msg:match("%d+"))
        
        if s and s >= 10 and s <= 100 then
            print("change button size ", BUTTON_SIZE, " to ", s)
            BUTTON_SIZE = s
			AjaeMyCustomActionBarDB.buttonSize = s
            AjaeSetButtonSize()
        end
    else
        print("|cffffff00/ajaebutton lock|unlock|hide|show|status|init||num0~", BUTTON_LIMIT_CNT, "|size10~100|r")
        print("|cffffff00 more infomation command /ajaebutton help")
    end
end

local function checkButtonCnt()
    local btnCnt = 0
    for i=1, BUTTON_LIMIT_CNT do
        local checkBtn = _G[ACTIONBAR_NAME .. i]
        if checkBtn then
        	btnCnt = btnCnt + 1
        end
	end
    print("Ajae Button cnt: ", btnCnt)

    if btnCnt ~= AjaeMyCustomActionBarDB.buttonCnt then
	    print("애드온 UI 이상으로 생성한 버튼의 개수와 실제 개수가 다릅니다.")
		print("애드온 개수 다시 설정 중")
	    
        buttons = {} 
	    AjaeMyCustomActionBarDB.buttonCnt = btnCnt
		NUM_ACTION_BUTTONS = btnCnt

        if AjaeMyCustomActionBarDB.buttonSize then
		    BUTTON_SIZE = AjaeMyCustomActionBarDB.buttonSize
        else
            AjaeMyCustomActionBarDB.buttonSize = BUTTON_SIZE
		end
		
		for i=1, btnCnt do
		    local checkBtn = _G[ACTIONBAR_NAME .. i]
			--print(checkBtn:GetSize())
			AjaeMyCustomActionBarDBData[i].pos = {x = checkBtn:GetLeft(), y = checkBtn:GetTop()}
            buttons[i] = checkBtn
		end
        print("애드온 개수 설정 완료")
	end
end


-- 경고창 비활성화
UIParent:HookScript("OnEvent", function(s, e, a1, a2)
    -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
	if e == "ADDON_ACTION_FORBIDDEN" and a1 == "Ajae" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		StaticPopup_Hide(e)
	end

    if e == "ADDON_ACTION_BLOCKED" and a1 == "Ajae" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		StaticPopup_Hide(e)
	end
end)

		
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    NUM_ACTION_BUTTONS = AjaeMyCustomActionBarDB.buttonCnt or DEFAULT_BUTTON_CNT --최초에 버튼개수는 3개이고
    BUTTON_SIZE = AjaeMyCustomActionBarDB.buttonSize or DEFAULT_BUTTON_SIZE -- 최초의 버튼 사이즈는 40

    if AjaeMyCustomActionBarDB.buttonSize == nil then   -- 애드온을 처음 설치해서 변수가 없는 경우
        AjaeMyCustomActionBarDB.buttonSize = BUTTON_SIZE  -- 기본 크기로 데이터 저장한다
    end

    if AjaeMyCustomActionBarDB.buttonCnt == nil then  -- 애드온을 처음 설치해서 버튼 개수가 없는 경우
        AjaeMyCustomActionBarDB.buttonCnt = NUM_ACTION_BUTTONS  -- 기본 값인 3을 넣어서 버튼 3개가 생기게 한다.
        makeButton(1, NUM_ACTION_BUTTONS)
    else
        if AjaeMyCustomActionBarDBData and #AjaeMyCustomActionBarDBData ~= 0 then -- 그 외 애드온을 사용하여 버튼 개수와 버튼 데이터가 존재하는 경우
            if NUM_ACTION_BUTTONS == #AjaeMyCustomActionBarDBData then        -- 버튼 데이터의 개수와 현재 버튼 설정의 개수가 같다면 
			    makeLoadButton(1, NUM_ACTION_BUTTONS)                         -- 해당 개수만큼 버튼을 만든다
			else
                NUM_ACTION_BUTTONS = #AjaeMyCustomActionBarDBData             -- 버튼 데이터의 개수와 현재 버튼 수 설정이 다르다면 데이터의 개수만큼 버튼 개수를 줄이고
                makeLoadButton(1, NUM_ACTION_BUTTONS)                     -- 버튼을 만든다.
            end
        else
		    AjaeMyCustomActionBarDB.buttonCnt = NUM_ACTION_BUTTONS          -- 버튼 개수는 있는데 버튼 데이터가 없는 이상한 경우라면 설정된 버튼 개수
			makeButton(1, NUM_ACTION_BUTTONS)                           -- 만큼 버튼을 신규로 생성 한다.
		end
    end
    -- addon error check
    checkButtonCnt()
end)
