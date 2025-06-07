-- Author      : freeman
-- Create Date : 2025-05-31 오후 10:54:45
MyCustomActionBarDB = MyCustomActionBarDB or {}
MyCustomActionBarDbData = MyCustomActionBarDbData or {}
MyCustomActionBarSizeDbData = MyCustomActionBarSizeDbData or {}


main = _G["MainMenuBar"]
multiBarBottomRight = _G["MultiBarBottomRight"]
multiBarBottomLeft = _G["MultiBarBottomLeft"]
multiBar7 = _G["MultiBar7"]
multiBar6 = _G["MultiBar6"]
multiBar5 = _G["MultiBar5"]
multiBarLeft = _G["MultiBarLeft"]
multiBarRight = _G["MultiBarRight"]

stanceButton = _G["StanceButton1"]

allButtons = {main, multiBarBottomRight, multiBarBottomLeft, multiBar7, multiBar6, multiBar5, multiBarLeft, multiBarRight}
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


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_FLAGS")
f:SetScript("OnEvent", function(self, event, ...)
    --print("variable status: ", MyCustomActionBarDB.MainMenuBarShow, " ", MainMenuBarShow)
    if event == "PLAYER_ENTERING_WORLD" then
        print("🌍 게임 접속 또는 로딩 완료")
		C_Timer.After(1, function()
            print("ajaebutton initialize...")
            -- 게임 시작 시 와우의 기본 모든 패널들이 로드 된 후에 애드온 설정을 시작해야함
            -- 이 애드온은 와우의 기본 패널을 컨트롤 하기 때문에 순서가 중요함
            loadButtonSize()
            initButton()
            initCheck()
            showAll()
        end)
    elseif event == "UNIT_AURA" or event == "UNIT_FLAGS" then
        C_Timer.After(1, function()
            loadButtonSize()
            initButton()
	        initCheck()
            showAll()
		end)
	end

    --multiBarBottomRight.actionButtons[2].IconMask:SetSize(20,20)
    --main.actionButtons[2].IconMask:SetSize(20,20)

    --for k, v in pairs(multiBarBottomRight.actionButtons[1]) do
    --    print(k, type(v))
    -- end
    --print(multiBarBottomRight.actionButtons[1]:GetSize())
    --print(main.actionButtons[1]:GetName())
end)


--[[
print("mainmenubar start")
--for k, v in pairs(main) do
--    print(k, type(v))
--end


print("actionbutton start")
--for k, v in pairs(ac1) do
--    print(k, type(v))
--end


mybuttonSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    print(value)
    setButtonSize(ac1, value)
    myeditbox:SetText(value)
end)


myeditbox:SetScript("OnEnterPressed", function(self)
    local val = tonumber(self:GetText())
    if val then
        local min, max = mybuttonSlider:GetMinMaxValues()
        if val < min then val = min end
        if val > max then val = max end
        mybuttonSlider:SetValue(val)
    end
    self:ClearFocus()
end)


frame1:RegisterEvent("ADDON_LOADED")
frame1:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "MyMainMenuControl" then
        myeditbox = _G["myeditbox1"]
        myeditbox:SetAutoFocus(false)
        mybuttonSlider = _G["buttonSlider"]
        if myeditbox then
            print("EditBox 로드됨:", myeditbox:GetName())
        else
            print("❌ EditBox를 찾을 수 없음")
        end
    end
end)


local function setButtonSize(btn, BUTTON_SIZE)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetNormalTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetPushedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetHighlightTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetCheckedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
end

]]