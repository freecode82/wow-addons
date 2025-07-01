settingsFrame = CreateFrame("Frame", "AjaeButtonOptions", InterfaceOptionsFramePanelContainer)
settingsFrame.name = "AjaeButton"

local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("AjaeButton Setting")

-- 可记 芒 积己
--[[
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
]]

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


local sizeStatusEditbox = CreateFrame("EditBox", "MySliderEditBox", settingsFrame, "InputBoxTemplate")
sizeStatusEditbox:SetSize(60, 20)
sizeStatusEditbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -220)
sizeStatusEditbox:SetAutoFocus(false)
sizeStatusEditbox:SetNumeric(true)
--sizeStatusEditbox:SetText(MainMenuBarSlider:GetValue())
local label = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("LEFT", sizeStatusEditbox, "RIGHT", 10, 0) -- EditBox 坷弗率 10px
label:SetText("<- show SIZE")



-- slider can setup size for button

--[[
local MainMenuBarSlider = CreateFrame("Slider", "MainMenuBarSlider", settingsFrame, "OptionsSliderTemplate")
MainMenuBarSlider:SetWidth(200)
MainMenuBarSlider:SetHeight(20)
MainMenuBarSlider:SetMinMaxValues(10, 100)
MainMenuBarSlider:SetValue(60)
MainMenuBarSlider:SetValueStep(1)
MainMenuBarSlider:SetOrientation("HORIZONTAL")
MainMenuBarSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -260)

_G[MainMenuBarSlider:GetName().."Text"]:SetText("MainMenuBarButton set Size")
_G[MainMenuBarSlider:GetName().."Low"]:SetText("10")
_G[MainMenuBarSlider:GetName().."High"]:SetText("100")

MainMenuBarSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(main.actionButtons) do
        setButtonSize(btn, value)
    end
end)
]]



local MultiBarBottomRightSlider = CreateFrame("Slider", "MultiBarBottomRightSlider", settingsFrame, "OptionsSliderTemplate")
MultiBarBottomRightSlider:SetWidth(200)
MultiBarBottomRightSlider:SetHeight(20)
MultiBarBottomRightSlider:SetMinMaxValues(10, 100)
MultiBarBottomRightSlider:SetValue(60)
MultiBarBottomRightSlider:SetValueStep(1)
MultiBarBottomRightSlider:SetOrientation("HORIZONTAL")
MultiBarBottomRightSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 240, -260)

_G[MultiBarBottomRightSlider:GetName().."Text"]:SetText("MultiBarBottomRightButton set Size")
_G[MultiBarBottomRightSlider:GetName().."Low"]:SetText("10")
_G[MultiBarBottomRightSlider:GetName().."High"]:SetText("100")

MultiBarBottomRightSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBarBottomRight.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local MultiBarBottomLeftSlider = CreateFrame("Slider", "MultiBarBottomLeftSlider", settingsFrame, "OptionsSliderTemplate")
MultiBarBottomLeftSlider:SetWidth(200)
MultiBarBottomLeftSlider:SetHeight(20)
MultiBarBottomLeftSlider:SetMinMaxValues(10, 100)
MultiBarBottomLeftSlider:SetValue(60)
MultiBarBottomLeftSlider:SetValueStep(1)
MultiBarBottomLeftSlider:SetOrientation("HORIZONTAL")
MultiBarBottomLeftSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -310)

_G[MultiBarBottomLeftSlider:GetName().."Text"]:SetText("MultiBarBottomLeftButton set Size")
_G[MultiBarBottomLeftSlider:GetName().."Low"]:SetText("10")
_G[MultiBarBottomLeftSlider:GetName().."High"]:SetText("100")

MultiBarBottomLeftSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBarBottomLeft.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local multiBarLeftSlider = CreateFrame("Slider", "multiBarLeftSlider", settingsFrame, "OptionsSliderTemplate")
multiBarLeftSlider:SetWidth(200)
multiBarLeftSlider:SetHeight(20)
multiBarLeftSlider:SetMinMaxValues(10, 100)
multiBarLeftSlider:SetValue(60)
multiBarLeftSlider:SetValueStep(1)
multiBarLeftSlider:SetOrientation("HORIZONTAL")
multiBarLeftSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 240, -310)

_G[multiBarLeftSlider:GetName().."Text"]:SetText("multiBarLeftButton set Size")
_G[multiBarLeftSlider:GetName().."Low"]:SetText("10")
_G[multiBarLeftSlider:GetName().."High"]:SetText("100")

multiBarLeftSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBarLeft.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local multiBarRightSlider = CreateFrame("Slider", "multiBarRightSlider", settingsFrame, "OptionsSliderTemplate")
multiBarRightSlider:SetWidth(200)
multiBarRightSlider:SetHeight(20)
multiBarRightSlider:SetMinMaxValues(10, 100)
multiBarRightSlider:SetValue(60)
multiBarRightSlider:SetValueStep(1)
multiBarRightSlider:SetOrientation("HORIZONTAL")
multiBarRightSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -360)

_G[multiBarRightSlider:GetName().."Text"]:SetText("multiBarRightButton set Size")
_G[multiBarRightSlider:GetName().."Low"]:SetText("10")
_G[multiBarRightSlider:GetName().."High"]:SetText("100")

multiBarRightSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBarRight.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local multiBar7Slider = CreateFrame("Slider", "multiBar7Slider", settingsFrame, "OptionsSliderTemplate")
multiBar7Slider:SetWidth(200)
multiBar7Slider:SetHeight(20)
multiBar7Slider:SetMinMaxValues(10, 100)
multiBar7Slider:SetValue(60)
multiBar7Slider:SetValueStep(1)
multiBar7Slider:SetOrientation("HORIZONTAL")
multiBar7Slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 240, -360)

_G[multiBar7Slider:GetName().."Text"]:SetText("multiBar7Button set Size")
_G[multiBar7Slider:GetName().."Low"]:SetText("10")
_G[multiBar7Slider:GetName().."High"]:SetText("100")

multiBar7Slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBar7.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local multiBar6Slider = CreateFrame("Slider", "multiBar6Slider", settingsFrame, "OptionsSliderTemplate")
multiBar6Slider:SetWidth(200)
multiBar6Slider:SetHeight(20)
multiBar6Slider:SetMinMaxValues(10, 100)
multiBar6Slider:SetValue(60)
multiBar6Slider:SetValueStep(1)
multiBar6Slider:SetOrientation("HORIZONTAL")
multiBar6Slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -410)

_G[multiBar6Slider:GetName().."Text"]:SetText("multiBar6Button set Size")
_G[multiBar6Slider:GetName().."Low"]:SetText("10")
_G[multiBar6Slider:GetName().."High"]:SetText("100")

multiBar6Slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBar6.actionButtons) do
        setButtonSize(btn, value)
    end
end)


local multiBar5Slider = CreateFrame("Slider", "multiBar5Slider", settingsFrame, "OptionsSliderTemplate")
multiBar5Slider:SetWidth(200)
multiBar5Slider:SetHeight(20)
multiBar5Slider:SetMinMaxValues(10, 100)
multiBar5Slider:SetValue(60)
multiBar5Slider:SetValueStep(1)
multiBar5Slider:SetOrientation("HORIZONTAL")
multiBar5Slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 240, -410)

_G[multiBar5Slider:GetName().."Text"]:SetText("multiBar5Button set Size")
_G[multiBar5Slider:GetName().."Low"]:SetText("10")
_G[multiBar5Slider:GetName().."High"]:SetText("100")

multiBar5Slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    sizeStatusEditbox:SetText(value)

    for j, btn in ipairs(multiBar5.actionButtons) do
        setButtonSize(btn, value)
    end
end)



