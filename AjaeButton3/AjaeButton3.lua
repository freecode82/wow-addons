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

stanceButtons = {}

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
    if InCombatLockdown() then return end
    
    if event == "PLAYER_ENTERING_WORLD" then
        print("🌍 게임 접속 또는 로딩 완료")
		C_Timer.After(1, function()
            print("ajaebutton initialize...")
            -- 게임 시작 시 와우의 기본 모든 패널들이 로드 된 후에 애드온 설정을 시작해야함
            -- 이 애드온은 와우의 기본 패널을 컨트롤 하기 때문에 순서가 중요함
            loadButtonSize()
            initButton()
            initStance()
            initCheck()
            showAll()
            
        end)
    elseif event == "UNIT_AURA" or event == "UNIT_FLAGS" then
        C_Timer.After(1, function()
            loadButtonSize()
            initButton()
            initStance()
	        initCheck()
            showAll()
		end)
	end
end)
