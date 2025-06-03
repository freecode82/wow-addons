-- Author      : freeman
-- Create Date : 2025-05-31 오후 10:54:45
MyCustomActionBarDB = MyCustomActionBarDB or {}
MyCustomActionBarDbData = MyCustomActionBarDbData or {}

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


local function initButton()
    -- 모든 버튼이 이동 가능하게 한다.
    for i, btnFrame in ipairs(allButtons) do
        --print(btnFrame.numButtons)
    
        for j, btn in ipairs(btnFrame.actionButtons) do
            --print("버튼 이름:", btn:GetName())
            btn:SetMovable(true)
            btn:EnableMouse(true)
            btn:RegisterForDrag("LeftButton")

            local btnName = btn:GetName()

            if MyCustomActionBarDbData[btnName] ~= nil then -- 한번이라도 버튼 이동을 시킨 정보가 존재하면 버튼 프레임에서 떼어낸다
                local saved = MyCustomActionBarDbData[btnName]
                --print(btn:GetName())
                btn:ClearAllPoints()  -- 위치를 이동 시키기 전 포인터 정보 초기화
                btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
		        btn:SetParent(UIParent)  -- 액션버튼의 기본 프레임에서 이동 없이 부모를 변경하면 버튼이 불능이 된다. 그래서 위의 2코드로 위치 이동
            end

            btn:SetScript("OnDragStart", function(self)
                if InCombatLockdown() then return end
                if not isLocked then self:StartMoving() end
            end)

            btn:SetScript("OnDragStop", function(self)
                if InCombatLockdown() then return end
            
                self:StopMovingOrSizing()
                MyCustomActionBarDbData[btnName] = MyCustomActionBarDbData[btnName] or {}
                local x, y = self:GetLeft(), self:GetTop()
                MyCustomActionBarDbData[btnName].pos = { x = x, y = y }
                self:SetParent(UIParent)
            end)
        end
    end
end


local function initCheck()
    if MyCustomActionBarDB.isLocked == true then
        isLocked = MyCustomActionBarDB.isLocked
    else
        MyCustomActionBarDB.isLocked = isLocked
    end

    if MyCustomActionBarDB.MainMenuBarShow == false then
        MainMenuBarShow = MyCustomActionBarDB.MainMenuBarShow
    else
        MyCustomActionBarDB.MainMenuBarShow = MainMenuBarShow
    end

    if MyCustomActionBarDB.MultiBarBottomRightButtonShow == false then
        MultiBarBottomRightButtonShow = MyCustomActionBarDB.MultiBarBottomRightButtonShow
    else
        MyCustomActionBarDB.MultiBarBottomRightButtonShow =  MultiBarBottomRightButtonShow
    end 

    if MyCustomActionBarDB.MultiBarBottomLeftButtonShow == false then
        MultiBarBottomLeftButtonShow = MyCustomActionBarDB.MultiBarBottomLeftButtonShow
    else
        MyCustomActionBarDB.MultiBarBottomLeftButtonShow = MultiBarBottomLeftButtonShow
    end

    if MyCustomActionBarDB.MultiBar7Show == false then
        MultiBar7Show = MyCustomActionBarDB.MultiBar7Show
    else
        MyCustomActionBarDB.MultiBar7Show = MultiBar7Show
    end

    if MyCustomActionBarDB.MultiBar6Show == false then
        MultiBar6Show = MyCustomActionBarDB.MultiBar6Show
    else
        MyCustomActionBarDB.MultiBar6Show = MultiBar6Show
    end

    if MyCustomActionBarDB.MultiBar5Show == false then
        MultiBar5Show = MyCustomActionBarDB.MultiBar5Show
    else
        MyCustomActionBarDB.MultiBar5Show = MultiBar5Show
    end

    if MyCustomActionBarDB.MultiBarLeftShow == false then
        MultiBarLeftShow = MyCustomActionBarDB.MultiBarLeftShow
    else
        MyCustomActionBarDB.MultiBarLeftShow = MultiBarLeftShow
    end

    if MyCustomActionBarDB.MultiBarRightShow == false then
        MultiBarRightShow = MyCustomActionBarDB.MultiBarRightShow
    else
        MyCustomActionBarDB.MultiBarRightShow = MultiBarRightShow
    end

    if MyCustomActionBarDB.capsShow == false then
        capsShow = MyCustomActionBarDB.capsShow
    else
        MyCustomActionBarDB.capsShow = capsShow
    end
end

local function showMainMenuBar()
    if MainMenuBarShow then 
        main:Show() 
    else
        main:Hide()
    end
end

local function showMultiBarBottomRight()
    if MultiBarBottomRightButtonShow then 
        multiBarBottomRight:Show() 
    else
        multiBarBottomRight:Hide()
    end
end

local function showMultiBarBottomLeft()
    if MultiBarBottomLeftButtonShow then 
        multiBarBottomLeft:Show() 
    else
        multiBarBottomLeft:Hide()
    end
end

local function showMultiBar7()
    if MultiBar7Show then 
        multiBar7:Show() 
    else
        multiBar7:Hide()
    end
end

local function showMultiBar6()
    if MultiBar6Show then 
        multiBar6:Show() 
    else
        multiBar6:Hide()
    end
end

local function showMultiBar5()
    if MultiBar5Show then 
        multiBar5:Show() 
    else
        multiBar5:Hide()
    end
end

local function showMultiBarLeft()
    if MultiBarLeftShow then 
        multiBarLeft:Show() 
    else
        multiBarLeft:Hide()
    end
end

local function showMultiBarRight()
    if MultiBarRightShow then 
        multiBarRight:Show() 
    else
        multiBarRight:Hide()
    end
end

local function showCaps()
    if capsShow then 
        for i, cap in ipairs(caps) do
            cap:Show()
        end
    else
        for i, cap in ipairs(caps) do
            cap:Hide()
        end
    end
end


-- 옵션 창 생성
local settingsFrame = CreateFrame("Frame", "AjaeButtonOptions", InterfaceOptionsFramePanelContainer)
settingsFrame.name = "AjaeButton"

local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("AjaeButton Setting")

local mainButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
mainButton:SetSize(300, 25)
mainButton:SetText("MainMenuBar show/hide")
mainButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
mainButton:SetScript("OnClick", function()
    if not MainMenuBarShow then 
        main:Show() 
        MainMenuBarShow = true
        MyCustomActionBarDB.MainMenuBarShow = true
    else
        main:Hide()
        MainMenuBarShow = false
        MyCustomActionBarDB.MainMenuBarShow = false
    end
end)

local MultiBarBottomRightShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
MultiBarBottomRightShowButton:SetSize(300, 25)
MultiBarBottomRightShowButton:SetText("MultiBarBottomRight show/hide")
MultiBarBottomRightShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -40)
MultiBarBottomRightShowButton:SetScript("OnClick", function()
    if not MultiBarBottomRightButtonShow then
        multiBarBottomRight:Show() 
        MultiBarBottomRightButtonShow = true
        MyCustomActionBarDB.MultiBarBottomRightButtonShow = true
    else
        multiBarBottomRight:Hide()
        MultiBarBottomRightButtonShow = false
        MyCustomActionBarDB.MultiBarBottomRightButtonShow = false
    end
end)

local MultiBarBottomLeftShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
MultiBarBottomLeftShowButton:SetSize(300, 25)
MultiBarBottomLeftShowButton:SetText("MultiBarBottomRight show/hide")
MultiBarBottomLeftShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -60)
MultiBarBottomLeftShowButton:SetScript("OnClick", function()
    if not MultiBarBottomLeftButtonShow then
        multiBarBottomLeft:Show() 
        MultiBarBottomLeftButtonShow = true
        MyCustomActionBarDB.MultiBarBottomLeftButtonShow = true
    else
        multiBarBottomLeft:Hide()
        MultiBarBottomLeftButtonShow = false
        MyCustomActionBarDB.MultiBarBottomLeftButtonShow = false
    end
end)

local multiBar7ShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
multiBar7ShowButton:SetSize(300, 25)
multiBar7ShowButton:SetText("multiBar7 show/hide")
multiBar7ShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -80)
multiBar7ShowButton:SetScript("OnClick", function()
    if not MultiBar7Show then
        multiBar7:Show() 
        MultiBar7Show = true
        MyCustomActionBarDB.MultiBar7Show = true
    else
        multiBar7:Hide()
        MultiBar7Show = false
        MyCustomActionBarDB.MultiBar7Show = false
    end
end)

local multiBar6ShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
multiBar6ShowButton:SetSize(300, 25)
multiBar6ShowButton:SetText("multiBar6 show/hide")
multiBar6ShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -100)
multiBar6ShowButton:SetScript("OnClick", function()
    if not MultiBar6Show then
        multiBar6:Show() 
        MultiBar6Show = true
        MyCustomActionBarDB.MultiBar6Show = true
    else
        multiBar6:Hide()
        MultiBar6Show = false
        MyCustomActionBarDB.MultiBar6Show = false
    end
end)


local multiBar5ShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
multiBar5ShowButton:SetSize(300, 25)
multiBar5ShowButton:SetText("multiBar5 show/hide")
multiBar5ShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -120)
multiBar5ShowButton:SetScript("OnClick", function()
    if not MultiBar5Show then
        multiBar5:Show() 
        MultiBar5Show = true
        MyCustomActionBarDB.MultiBar5Show = true
    else
        multiBar5:Hide()
        MultiBar5Show = false
        MyCustomActionBarDB.MultiBar5Show = false
    end
end)

local multiBarLeftShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
multiBarLeftShowButton:SetSize(300, 25)
multiBarLeftShowButton:SetText("multiBarLeft show/hide")
multiBarLeftShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -140)
multiBarLeftShowButton:SetScript("OnClick", function()
    if not MultiBarLeftShow then
        multiBarLeft:Show() 
        MultiBarLeftShow = true
        MyCustomActionBarDB.MultiBarLeftShow = true
    else
        multiBarLeft:Hide()
        MultiBarLeftShow = false
        MyCustomActionBarDB.MultiBarLeftShow = false
    end
end)

local multiBarRightShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
multiBarRightShowButton:SetSize(300, 25)
multiBarRightShowButton:SetText("multiBarRight show/hide")
multiBarRightShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -160)
multiBarRightShowButton:SetScript("OnClick", function()
    if not MultiBarRightShow then
        multiBarRight:Show() 
        MultiBarRightShow = true
        MyCustomActionBarDB.MultiBarRightShow = true
    else
        multiBarRight:Hide()
        MultiBarRightShow = false
        MyCustomActionBarDB.MultiBarRightShow = false
    end
end)


local capsShowButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
capsShowButton:SetSize(300, 25)
capsShowButton:SetText("MainMenuBarCaps show/hide")
capsShowButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -180)
capsShowButton:SetScript("OnClick", function(self)
    if not capsShow then
        for i, cap in ipairs(caps) do
            cap:Show()
        end
        capsShow = true
        MyCustomActionBarDB.capsShow = true
    else
        for i, cap in ipairs(caps) do
            cap:Hide()
        end
        capsShow = false
        MyCustomActionBarDB.capsShow = false
    end
end)


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
f:SetScript("OnEvent", function()
    --print("variable status: ", MyCustomActionBarDB.MainMenuBarShow, " ", MainMenuBarShow)

    C_Timer.After(5, function()
        print("ajaebutton initialize...")
        -- 게임 시작 시 와우의 기본 모든 패널들이 로드 된 후에 애드온 설정을 시작해야함
        -- 이 애드온은 와우의 기본 패널을 컨트롤 하기 때문에 순서가 중요함
        initButton()
        initCheck()
        
        showMainMenuBar()
        showMultiBarBottomRight()
        showMultiBarBottomLeft()
        showMultiBar7()
        showMultiBar6()
        showMultiBar5()
        showMultiBarLeft()
        showMultiBarRight()
        showCaps()
    end)
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