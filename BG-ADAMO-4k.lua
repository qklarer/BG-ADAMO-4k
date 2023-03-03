local json       = require('json')
local IP         = NamedControl.GetText("IP")
local Moving     = false
local activeMove = nil
local confirmLed = 0

local focusMode        = NamedControl.GetValue("focusMode")
local focusModeState   = nil
local audioEnable      = NamedControl.GetPosition("audioEnable")
local audioEnableState = nil
local audioLevel       = NamedControl.GetPosition("Vol")
local audioLevelState  = nil
local Tracking         = NamedControl.GetPosition("trackingEnable")
local trackingState    = nil

local Movments = {
    [1] = "left_start",
    [2] = "left_stop",
    [3] = "leftup_start",
    [4] = "leftup_stop",
    [5] = "leftdown_start",
    [6] = "leftdown_stop",
    [7] = "right_start",
    [8] = "right_stop",
    [9] = "rightup_start",
    [10] = "rightup_stop",
    [11] = "rightdown_start",
    [12] = "rightdown_stop",
    [13] = "up_start",
    [14] = "up_stop",
    [15] = "down_start",
    [16] = "down_stop",
    -------------------------------
    [17] = "zoomadd_start",
    [18] = "zoomadd_stop",
    [19] = "zoomdec_start",
    [20] = "zoomdec_stop",
    [21] = "focusadd_start",
    [22] = "focusadd_stop",
    [23] = "focusdec_start",
    [24] = "focusdec_stop"
}

local focusMode = {
    [2] = 'Auto',
    [3] = 'Manul',
    [4] = 'OnePush'
}

local preSetCmd = {
    [1] = "preset_set",
    [2] = "preset_call",
    [3] = "preset_clean"
}

local function Response(Table, ReturnCode, Data, Error, Headers)

    -- print(Data)
    -- print(Table)
    -- print(ReturnCode)
    -- print(Error)
    -- print(Headers)

    if ReturnCode == 200 then
        NamedControl.SetPosition("confirmLed", 1)
        confLed = 0
    end
end

function Move(Direction)

    local formattedStr = string.format("%0.f", NamedControl.GetValue("camSpeed"))
    local formattedNum = tonumber(formattedStr)
    local encodedJson = json.encode({ SysCtrl = { PtzCtrl = { nChanel = 0, szPtzCmd = Direction,
        byValue = formattedNum } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function changeFocusMode(State)

    local formattedStr = string.format("%0.f", State)
    local formattedNum = tonumber(formattedStr)
    local encodedJson = json.encode({ SetEnv = { VideoParam = { { stAF = { emAFMode = formattedNum + 2 }, nChannel = 0 } } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function changePreset(cmd, preSet)

    local encodedJson = json.encode({ SysCtrl = { PtzCtrl = { nChanel = 0, szPtzCmd = cmd, byValue = tonumber(preSet) } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function enableAudio(State)

    local formattedStr = string.format("%0.f", State)
    local formattedNum = tonumber(formattedStr)
    local encodedJson = json.encode({ SetEnv = { Audio = { bEnable = formattedNum } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function changeAudioLevel(Level)

    local formattedStr = string.format("%0.f", Level)
    local formattedNum = tonumber(formattedStr)
    local encodedJson = json.encode({ SetEnv = { Audio = { nInpVolume = formattedNum } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function changeTracking(State)

    local formattedStr = string.format("%0.f", State)
    local formattedNum = tonumber(formattedStr)
    local encodedJson = json.encode({ SetEnv = { MonoTracking = { bEnable = formattedNum } } })
    local Data = HttpClient.EncodeParams({ szCmd = encodedJson })

    HttpClient.Upload({
        Url = IP .. "/ajaxcom",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Data = Data,
        Method = "POST",
        EventHandler = Response })
end

function TimerClick()

    confirmLed = confirmLed + 1
    if confirmLed == 2 then
        confirmLed = 0
        NamedControl.SetPosition("confirmLed", 0)
    end
    IP = NamedControl.GetText("IP")
    audioEnable = NamedControl.GetPosition("audioEnable")
    focusMode = NamedControl.GetValue("focusMode")
    audioLevel = NamedControl.GetValue("Vol")
    Tracking = NamedControl.GetPosition("trackingEnable")

    for k, v in pairs(Movments) do
        if NamedControl.GetPosition("Move" .. k) == 1 and Moving == false then
            Move(v, NamedControl.GetText("IP"))
            activeMove = tonumber(k)
            Moving = true
        end
    end

    if activeMove ~= nil then
        if NamedControl.GetPosition("Move" .. activeMove) == 0 and Moving then
            Move(Movments[activeMove + 1])
            activeMove = nil
            Moving = false
        end
    end

    for k, v in pairs(preSetCmd) do
        if NamedControl.GetPosition(tostring(v)) == 1 then
            changePreset(v, string.format("%0.f", NamedControl.GetValue("Preset")))
            NamedControl.SetPosition(v, 0)
        end
    end

    if focusModeState ~= focusMode then
        changeFocusMode(focusMode)
        focusModeState = focusMode
    end

    if audioEnableState ~= audioEnable then
        enableAudio(audioEnable)
        audioEnableState = audioEnable
    end

    if audioLevelState ~= audioLevel then
        changeAudioLevel(audioLevel)
        audioLevelState = audioLevel
    end

    if Tracking ~= trackingState then
        changeTracking(Tracking)
        trackingState = Tracking
    end

    if NamedControl.GetPosition("Home") == 1 then
        Move("go_home")
        NamedControl.SetPosition("Home", 0)
    end

end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.25)
