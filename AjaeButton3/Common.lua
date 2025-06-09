function setButtonSize(btn, BUTTON_SIZE)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetNormalTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetPushedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetHighlightTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:GetCheckedTexture():SetSize(BUTTON_SIZE, BUTTON_SIZE)

    local size = btn:GetWidth()
    -- btn.IconMask:Hide()
    -- btn.IconMask:ClearAllPoints()
    btn.IconMask:SetSize(size, size)
    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 0)
    -- btn.IconMask:SetPoint("CENTER", btn)

    -- 버튼 사이즈 정보를 저장한다.
    MyCustomActionBarSizeDbData[btn:GetName()] = MyCustomActionBarSizeDbData[btnName] or {}
    MyCustomActionBarSizeDbData[btn:GetName()].buttonSize = BUTTON_SIZE
end


--[[ 구지 오른쪽 하단의 메뉴 버튼들은 이동 시킬 필요는 없을 거 같다
function initMicroMenu()
    local microButtons = _G["MicroMenu"]

    microButtons:SetMovable(true)
    microButtons:EnableMouse(true)
    microButtons:SetClampedToScreen(true)
    microButtons:RegisterForDrag("LeftButton")

    local btnName = microButtons:GetName()

    if MyCustomActionBarDbData[btnName] ~= nil then -- 한번이라도 버튼 이동을 시킨 정보가 존재하면 버튼 프레임에서 떼어낸다
        if MyCustomActionBarDbData[btnName].pos ~= nil then
            local saved = MyCustomActionBarDbData[btnName]
            microButtons:ClearAllPoints()  -- 위치를 이동 시키기 전 포인터 정보 초기화
            microButtons:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
	        -- microButtons:SetParent(UIParent)  -- 액션버튼의 기본 프레임에서 이동 없이 부모를 변경하면 버튼이 불능이 된다. 그래서 위의 2코드로 위치 이동
		end
    end

    microButtons:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        if not isLocked then self:StartMoving() end
    end)

    microButtons:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
    
        self:StopMovingOrSizing()
        MyCustomActionBarDbData[btnName] = MyCustomActionBarDbData[btnName] or {}
        local x, y = self:GetLeft(), self:GetTop()
        MyCustomActionBarDbData[btnName].pos = { x = x, y = y }
        -- self:SetParent(UIParent)
    end)
end
]]


function initStance()
    for i=1, 20 do
        local stanceButton = _G["StanceButton" .. i]

        if stanceButton ~= nil then
		    stanceButtons[#stanceButtons + 1] = stanceButton

            stanceButton:SetMovable(true)
            stanceButton:EnableMouse(true)
            stanceButton:SetClampedToScreen(true) -- 화면 밖으로 벗어나지 않도록
            stanceButton:RegisterForDrag("LeftButton")

            local btnName = stanceButton:GetName()

            if MyCustomActionBarDbData[btnName] ~= nil then -- 한번이라도 버튼 이동을 시킨 정보가 존재하면 버튼 프레임에서 떼어낸다
                if MyCustomActionBarDbData[btnName].pos ~= nil then
                    local saved = MyCustomActionBarDbData[btnName]
                    stanceButton:ClearAllPoints()  -- 위치를 이동 시키기 전 포인터 정보 초기화
                    stanceButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
		            stanceButton:SetParent(UIParent)  -- 액션버튼의 기본 프레임에서 이동 없이 부모를 변경하면 버튼이 불능이 된다. 그래서 위의 2코드로 위치 이동
				end
            end

            stanceButton:SetScript("OnDragStart", function(self)
                if InCombatLockdown() then return end
                if not isLocked then self:StartMoving() end
            end)

            stanceButton:SetScript("OnDragStop", function(self)
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


function initButton()
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
                if MyCustomActionBarDbData[btnName].pos ~= nil then
                    local saved = MyCustomActionBarDbData[btnName]
                    --print(btn:GetName())
                    btn:ClearAllPoints()  -- 위치를 이동 시키기 전 포인터 정보 초기화
                    btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.pos.x, saved.pos.y)
		            btn:SetParent(UIParent)  -- 액션버튼의 기본 프레임에서 이동 없이 부모를 변경하면 버튼이 불능이 된다. 그래서 위의 2코드로 위치 이동
                    -- btn:SetParent(nil)
				end
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
                -- btn:SetParent(nil)
            end)
        end
    end
end



function initCheck()
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



function loadButtonSize()
    for i, btnFrame in ipairs(allButtons) do
        for j, btn in ipairs(btnFrame.actionButtons) do
            -- print("버튼 이름:", btn:GetName())
            local btnName = btn:GetName()

            if MyCustomActionBarSizeDbData[btnName]~= nil then -- 한번이라도 버튼 사이즈를 변경 했다면
                if MyCustomActionBarSizeDbData[btnName].buttonSize ~= nil then
                    setButtonSize(btn, MyCustomActionBarSizeDbData[btnName].buttonSize)
				end
            end
        end
    end
end


function showAll()
    showMainMenuBar()
    showMultiBarBottomRight()
    showMultiBarBottomLeft()
    showMultiBar7()
    showMultiBar6()
    showMultiBar5()
    showMultiBarLeft()
    showMultiBarRight()
    showCaps()
end
