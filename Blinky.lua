--[[
    ---------------------------------------------------------
    Description


    ---------------------------------------------------------

    V1.0    01.01.18    initial release

--]]

----------------------------------------------------------------------
-- Locals for the application
local appVersion="1.0"
local lang

local onSwitch, changeSwitch, brightnessPropSwitch
local blinkyControllOutput=-0.1 -- blinky off


----------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file=io.readall("Apps/Blinky/Blinky.jsn")
    local obj=json.decode(file)
    if(obj) then
        lang=obj[lng] or obj[obj.default]
    end
end


----------------------------------------------------------------------
-- Store settings when changed by user
local function onSwitchChanged(value)
    onSwitch=value
    system.pSave("onSwitch",value)
end

local function changeSwitchChanged(value)
    changeSwitch=value
    system.pSave("changeSwitch",value)
end

local function brightnessPropSwitchChanged(value)
    brightnessPropSwitch=value
    system.pSave("brightnessPropSwitch",value)
end

----------------------------------------------------------------------
-- Draw the telemetry windows
local function printStatus(width,height)
    -- print brightness
    lcd.drawText(2,15,lang.brightness, FONT_MINI)
    local brightnessVal = system.getInputsVal(brightnessPropSwitch)
    if(brightnessVal and brightnessVal>=0.05)then
        brightnessVal=brightnessVal*100
        lcd.drawText(143-lcd.getTextWidth(FONT_MAXI,string.format("%.0f%%",brightnessVal)),1,string.format("%.0f%%",brightnessVal),FONT_MAXI)
    else
        lcd.drawText(143-lcd.getTextWidth(FONT_MAXI,"0%"),1,"0%",FONT_MAXI)
    end
    
    -- print status
    lcd.drawText(3,45,lang.status, FONT_MINI)
    if(blinkyControllOutput>=-0.4 and blinkyControllOutput<0.05)then
        -- blinky off
        lcd.setColor(200,0,0) -- red
        lcd.drawText(143-lcd.getTextWidth(FONT_BIG,lang.statusOff),40,lang.statusOff, FONT_BIG)
    elseif(blinkyControllOutput>=0.05)then
        -- blinky run
        lcd.setColor(0,200,0) -- green
        lcd.drawText(143-lcd.getTextWidth(FONT_BIG,lang.statusRun),40,lang.statusRun, FONT_BIG)
    elseif(blinkyControllOutput<-0.4)then
        -- blinky change pattern
        lcd.drawText(143-lcd.getTextWidth(FONT_BIG,lang.statusChange),40,lang.statusChange, FONT_BIG)
    end
end


----------------------------------------------------------------------
-- Draw the main form (Application menu inteface)
local function initForm(subform)
    -- main menu
    form.setTitle(lang.appName)
    
    form.addRow(2)
    form.addLabel({label=lang.onSwitch})
    form.addInputbox(onSwitch,false,onSwitchChanged)
    
    form.addRow(2)
    form.addLabel({label=lang.changeSwitch})
    form.addInputbox(changeSwitch,false,changeSwitchChanged)
    
    form.addRow(2)
    form.addLabel({label=lang.brightnessPropSwitch})
    form.addInputbox(brightnessPropSwitch,true,brightnessPropSwitchChanged)    
    
    form.addSpacer(150,61)
    
    form.addRow(1)
    form.addLabel({label="Powered by M.Lehmann V"..appVersion.." ",font=FONT_MINI,alignRight=true})
end



----------------------------------------------------------------------
-- Runtime functions
local function loop()
    -- get controllinput values
    local runBlinky,changePattern,brightnessVal = system.getInputsVal(onSwitch,changeSwitch,brightnessPropSwitch)
    
    -- Blinky controll
    blinkyControllOutput=-0.1 -- blinky off
    
    if(runBlinky and runBlinky>0)then
        if(brightnessVal and brightnessVal>0.05)then
            blinkyControllOutput=brightnessVal
        end
    end
    
    if(changePattern and changePattern>0)then
        blinkyControllOutput=-0.6 -- change pattern
    end
    
    system.setControl(1,blinkyControllOutput,0)
end

----------------------------------------------------------------------
-- Application initialization
local function init()
    -- read parameters
    onSwitch = system.pLoad("onSwitch")
    changeSwitch = system.pLoad("changeSwitch")
    brightnessPropSwitch = system.pLoad("brightnessPropSwitch")

    -- register form
    system.registerForm(1,MENU_APPS,lang.appName,initForm)
    system.registerTelemetry(1,lang.appName,2,printStatus)
    
    -- register output controll
    system.registerControl(1,"BlinkyControll", "Blc")
end

----------------------------------------------------------------------
setLanguage()
return {init=init,loop=loop,author="M.Lehmann",version=appVersion,name=lang.appName}
