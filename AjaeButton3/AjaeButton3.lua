-- Author      : freeman
-- Create Date : 2025-05-31 오후 10:54:45
MyCustomActionBarDB = MyCustomActionBarDB or {}
MyCustomActionBarDbData = MyCustomActionBarDbData or {}
MyCustomActionBarSizeDbData = MyCustomActionBarSizeDbData or {}


main = _G["MainActionBar"]
multiBarBottomRight = _G["MultiBarBottomRight"]
multiBarBottomLeft = _G["MultiBarBottomLeft"]
multiBar7 = _G["MultiBar7"]
multiBar6 = _G["MultiBar6"]
multiBar5 = _G["MultiBar5"]
multiBarLeft = _G["MultiBarLeft"]
multiBarRight = _G["MultiBarRight"]

stanceButtons = {}

allButtons = {multiBarBottomRight, multiBarBottomLeft, multiBar7, multiBar6, multiBar5, multiBarLeft, multiBarRight}
caps = {main.EndCaps, main.ActionBarPageNumber}


-- initialize show/hide, lock/unlock 
isLocked = false
MainMenuBarShow = true
MultiBarBottomRightButtonShow = true
MultiBarBottomLeftButtonShow = true
MultiBar7Show = true
MultiBar6Show = true
MultiBar5Show = true
MultiBarLeftShow = true
MultiBarRightShow = true
capsShow = true


local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "AjaeButton") 
Settings.RegisterAddOnCategory(category)


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
    else
        print("|cffffff00/ajaebutton lock|unlock")
    end
end

--local function ChatFilter(self, event, msg, author, ...)
--    if msg:find("애드온") then
--        return true -- 메시지를 차단 (출력되지 않음)
--    end
--end

--ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", ChatFilter)
--ChatFrame_AddMessageEventFilter("UI_INFO_MESSAGE", ChatFilter)

UIParent:HookScript("OnEvent", function(s, e, a1, a2)
    -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
	if e == "ADDON_ACTION_FORBIDDEN" and a1 == "AjaeButton3" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		StaticPopup_Hide(e)
	end
    --if e == "UI_ERROR_MESSAGE" and a1 == "AjaeButton3" then
        -- print("이벤트:", e, "arg1:", a1, "arg2:", a2)
		--StaticPopup_Hide(e)
	--end
    --if e == "ADDON_ACTION_BLOCKED" and a1 == "AjaeButton3" then
        --print("이벤트:", e, "arg1:", a1, "arg2:", a2)
        --return
		--StaticPopup_Hide(e)
	--end
    --local realPrint = print
    
    if e == "ADDON_ACTION_BLOCKED" and a1 == "AjaeButton3" then -- and a2 == "MultiBarLeft:SetPointBase()" then
        --print = function() end
        --UIErrorsFrame:AddMessage(" ", 0, 0, 0, 0)
    --    print("이벤트:", e, "arg1:", a1, "arg2:", a2)
        --ChatFrame3:AddMessage(e, 1, 1, 1, 0)
        --print = realPrint
        return
	end
    
    --if e == "UI_ERROR_MESSAGE" and a1 == "AjaeButton3" then
        --print = function() end
        --UIErrorsFrame:AddMessage(" ", 0, 0, 0, 0)
    --    ChatFrame3:AddMessage(e, 1, 1, 1, 0)
        --print = realPrint
	--end
    if e == "LUA_WARNING" then
        return
    end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_FLAGS")
--f:RegisterEvent("CLIENT_SCENE_OPENED")
--f:RegisterEvent("CLIENT_SCENE_CLOSED")
--f:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
--f:RegisterEvent("PLAYER_FLAGS_CHANGED")
--f:RegisterEvent("ADDON_ACTION_BLOCKED")
--f:RegisterEvent("UI_ERROR_MESSAGE")
f:SetScript("OnEvent", function(self, event, ...)
    -- if InCombatLockdown() then return end
    if event == "PLAYER_ENTERING_WORLD" then
        print("🌍 게임 접속 또는 로딩 완료")
        

		C_Timer.After(1, function()
            print("ajaebutton initialize...")
            -- 게임 시작 시 와우의 기본 모든 패널들이 로드 된 후에 애드온 설정을 시작해야함
            -- 이 애드온은 와우의 기본 패널을 컨트롤 하기 때문에 순서가 중요함
            --if UIErrorsFrame ~= nil then
            --    UIErrorsFrame:AddMessage(" ", 0, 0, 0, 0)
            --end
            loadButtonSize()
            initButton()
            initStance()
            initCheck()
            showAll()
        end)
    elseif event == "UNIT_AURA" or event == "UNIT_FLAGS" or event == "UNIT_EXITED_VEHICLE" or event == "PLAYER_FLAGS_CHANGED" then
        C_Timer.After(1, function()
            if OverrideActionBar:IsShown() then
                hideButtonBecauseOverrideActionBar()
            --    ChatFrame4:AddMessage("override nothing", 1, 1, 1, 0)
            else
                showButtonBecauseOverrideActionBar()
            end
            loadButtonSize()
            initButton()
            initStance()
	        initCheck()
            showAll()
		end)
    --elseif event == "UPDATE_OVERRIDE_ACTIONBAR" then
    --    C_Timer.After(1, function()
    --        hideButtonBecauseOverrideActionBar()
    --        ChatFrame4:AddMessage("ok ok ok", 1, 1, 1, 0)
    --    end)
    --elseif event == "CLIENT_SCENE_CLOSED" then
    --    C_Timer.After(1, function()
    --        showButtonBecauseOverrideActionBar()
    --    end)
	end
end)