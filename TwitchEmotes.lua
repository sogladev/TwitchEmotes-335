local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

Emoticons_Settings = {
    --["CHAT_MSG_OFFICER"] = true, -- 1
    ["CHAT_MSG_GUILD"] = true, -- 2
    ["CHAT_MSG_PARTY"] = true, -- 3
    ["CHAT_MSG_PARTY_LEADER"] = true, -- dont count, tie to 3
    ["CHAT_MSG_PARTY_GUIDE"] = true, -- dont count, tie to 3
    ["CHAT_MSG_RAID"] = true, -- 4
    ["CHAT_MSG_RAID_LEADER"] = true, -- dont count, tie to 4
    ["CHAT_MSG_RAID_WARNING"] = true, -- dont count, tie to 4
    ["CHAT_MSG_SAY"] = true, -- 5
    ["CHAT_MSG_YELL"] = true, -- 6
    ["CHAT_MSG_WHISPER"] = true, -- 7
    ["CHAT_MSG_WHISPER_INFORM"] = true, -- dont count, tie to 7
    ["CHAT_MSG_CHANNEL"] = true, -- 8
    ["CHAT_MSG_BN_WHISPER"] = true, -- 9
    ["CHAT_MSG_BN_WHISPER_INFORM"] = true, -- dont count, tie to 9
    ["CHAT_MSG_BN_CONVERSATION"] = true, -- 10
    ["CHAT_MSG_INSTANCE_CHAT"] = true, -- 11
    ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true, -- dont count, tie to 11
    ["MAIL"] = true,
    ["MINIMAPBUTTON"] = true,
	["MINIMAPDATA"] = {minimapPos=135},
    ["LARGEEMOTES"] = false,
	["ENABLE_CLICKABLEEMOTES"] = true,
    ["ENABLE_AUTOCOMPLETE"] = true,
    ["ENABLE_ANIMATEDEMOTES"] = true,
    ["AUTOCOMPLETE_CONFIRM_WITH_TAB"] = false,
    ["FAVEMOTES"] = {
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true
    }
};

local origsettings = {
    --["CHAT_MSG_OFFICER"] = true,
    ["CHAT_MSG_GUILD"] = true,
    ["CHAT_MSG_PARTY"] = true,
    ["CHAT_MSG_PARTY_LEADER"] = true,
    ["CHAT_MSG_PARTY_GUIDE"] = true,
    ["CHAT_MSG_RAID"] = true,
    ["CHAT_MSG_RAID_LEADER"] = true,
    ["CHAT_MSG_RAID_WARNING"] = true,
    ["CHAT_MSG_SAY"] = true,
    ["CHAT_MSG_YELL"] = true,
    ["CHAT_MSG_WHISPER"] = true,
    ["CHAT_MSG_WHISPER_INFORM"] = true,
    ["CHAT_MSG_BN_WHISPER"] = true,
    ["CHAT_MSG_BN_WHISPER_INFORM"] = true,
    ["CHAT_MSG_BN_CONVERSATION"] = true,
    ["CHAT_MSG_CHANNEL"] = true,
    ["CHAT_MSG_INSTANCE_CHAT"] = true,
    ["MAIL"] = true,
    ["MINIMAPBUTTON"] = true,
	["MINIMAPDATA"] = {minimapPos=135},
    ["LARGEEMOTES"] = false,
	["ENABLE_CLICKABLEEMOTES"] = true,
    ["ENABLE_AUTOCOMPLETE"] = true,
    ["ENABLE_ANIMATEDEMOTES"] = true,
    ["FAVEMOTES"] = {
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true
    }
};

local TwitchEmotes_N_CHATFRAMES = 0;

-- Put your code that you want on a minimap button click here.  arg1="LeftButton", "RightButton", etc
function TwitchEmotes_MinimapButton_OnClick(btn)
    if IsShiftKeyDown() then
        TwitchStatsScreen_OnLoad();
    else
        LibDD:ToggleDropDownMenu(1, nil, EmoticonMiniMapDropDown,"cursor", 0, 0);
        -- ToggleDropDownMenu(1, nil, EmoticonMiniMapDropDown,"cursor", 285, 0);
    end
end

local ItemTextFrameSetText = ItemTextPageText.SetText;
function ItemTextPageText.SetText(self, msg, ...)
    if (Emoticons_Settings["MAIL"] and msg ~= nil) then
        local msgID = select(10, ...);
        local senderGUID = select(11, ...)
        msg = Emoticons_RunReplacement(msg, senderGUID, msgID, false);
    end
    ItemTextFrameSetText(self, msg, ...);
end

local OpenMailBodyTextSetText = OpenMailBodyText.SetText;
function OpenMailBodyText.SetText(self, msg, ...)
    if (Emoticons_Settings["MAIL"] and msg ~= nil) then
        local msgID = select(10, ...);
        local senderGUID = select(11, ...)
        msg = Emoticons_RunReplacement(msg, senderGUID, msgID, false);
    end
    OpenMailBodyTextSetText(self, msg, ...);
end

function Emoticons_LoadMiniMapDropdown(self, level, menuList)
    local info = LibDD:UIDropDownMenu_CreateInfo();
    -- local info = UIDropDownMenu_CreateInfo();
    info.isNotRadio = true;
    info.notCheckable = true;
    info.notClickable = false;
    if (level or 1) == 1 then
        for k, v in ipairs(TwitchEmotes_dropdown_options) do
            if (Emoticons_Settings["FAVEMOTES"][k]) then
                info.hasArrow = true;
                info.text = v[1];
                info.value = false;
                info.menuList = k;
                LibDD:UIDropDownMenu_AddButton(info);
                -- UIDropDownMenu_AddButton(info);
            end
        end
    else
        first = true;
        for ke, va in ipairs(TwitchEmotes_dropdown_options[menuList]) do
            if (first) then
                first = false;
            else
                -- if(TwitchEmotes_defaultpack[va] == nil) then
                --     print(ke.." " .. va .. " is broken");
                -- end
                
                info.text = "|T" .. TwitchEmotes_defaultpack[va] .. "|t " .. va;
                info.value = va;
                info.func = Emoticons_Dropdown_OnClick;
                LibDD:UIDropDownMenu_AddButton(info, level);
                -- UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

function Emoticons_Dropdown_OnClick(self, arg1, arg2, arg3)
    if (ACTIVE_CHAT_EDIT_BOX ~= nil) then
        ACTIVE_CHAT_EDIT_BOX:Insert(self.value);
    end
end

local sm = SendMail;
function SendMail(recipient, subject, msg, ...)
    if msg ~= nil then
        if Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
            msg = TwitchEmotes_Message_StripEscapes(msg) 
        end
        sm(recipient, subject, msg, ...);
    end
end

local scm = SendChatMessage;
function SendChatMessage(msg, ...)
    if msg ~= nil then
        if Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
            msg = TwitchEmotes_Message_StripEscapes(msg) 
        end
        scm(msg, ...);
    end
end

local bnsw = BNSendWhisper;
function BNSendWhisper(id, msg, ...)
    if msg ~= nil then
        if Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
            msg = TwitchEmotes_Message_StripEscapes(msg) 
        end
        bnsw(id, msg, ...);
    end
end

local function escpattern(x)
    return (x:gsub('%%', '%%%%')
             :gsub('^%^', '%%^')
             :gsub('%$$', '%%$')
             :gsub('%(', '%%(')
             :gsub('%)', '%%)')
             :gsub('%.', '%%.')
             :gsub('%[', '%%[')
             :gsub('%]', '%%]')
             :gsub('%*', '%%*')
             :gsub('%+', '%%+')
             :gsub('%-', '%%-')
             :gsub('%?', '%%?'))
 end

-- Strip the twitch emote link and texture escapes from the message before sending.
-- (to allow for sending shift-clicked emotes, we are not allowed to send messages with a '|T' sequence in it)
function TwitchEmotes_Message_StripEscapes(msg)

	--find a twitch emote link in the message
	for str in string.gmatch(msg, "(|Htel:.-|h.-|h)") do
		--find the emote string in the twitch emote link
		for emotestr in string.gmatch(str, "|Htel:(.-)|h.-|h") do
			msg = msg:gsub(escpattern(str), " " .. emotestr .. " "); -- Replace the link and texture with the plain emote key (and a space)
			break;
		end
	end
		
	return msg
end

function Emoticons_UpdateChatFilters()
    -- todo: this should only check the keys that start with CHAT_MSG_
    for k, v in pairs(Emoticons_Settings) do
        if k ~= "MAIL" then
            if (v) then
                ChatFrame_AddMessageEventFilter(k, Emoticons_MessageFilter)
            else
                ChatFrame_RemoveMessageEventFilter(k, Emoticons_MessageFilter);
            end
        end
    end
end

function Emoticons_MessageFilter(self, event, message, ...)
    local msgID = select(10, ...);
    local senderGUID = select(11, ...)
    
    message = Emoticons_RunReplacement(message, senderGUID, msgID);

    return false, message, ...
end

local accept_stat_updates = false;
local iconregistered = false
local autocompleteInited = false
local Broker_TwitchEmotes
local _G = getfenv(0)
function Emoticons_OnEvent(self, event, ...)
    if (event == "ADDON_LOADED" and select(1, ...) == "TwitchEmotes") then
        for k, v in pairs(origsettings) do
            if (Emoticons_Settings[k] == nil) then
                Emoticons_Settings[k] = v;
            end
        end

        -- Tauren Dairy Co
        if GetRealmName() == "Golemagg" or GetRealmName() == "Living Flame" then
            -- Emote directory
            TwitchEmotes_defaultpack["arthaslul"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\arthaslul.tga:28:28"
            TwitchEmotes_defaultpack["banspray"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\banspray.tga:28:28"
            TwitchEmotes_defaultpack[":bruh:"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\bruh.tga:28:28"
            TwitchEmotes_defaultpack["dots"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\dots.tga:28:28"
            TwitchEmotes_defaultpack["FeralPog"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\FeralPog.tga:28:28"
            TwitchEmotes_defaultpack["Gachicrul"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Gachicrul.tga:28:28"
            TwitchEmotes_defaultpack["hugevenomsac"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\hugevenomsac.tga:28:28"
            TwitchEmotes_defaultpack["hugevipus"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\hugevipus.tga:28:28"
            TwitchEmotes_defaultpack["Jooper"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Jooper.tga:28:28"
            TwitchEmotes_defaultpack["khadscusemewhat"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\khadscusemewhat.tga:28:28"
            TwitchEmotes_defaultpack["khadthink"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\khadthink.tga:28:28"
            TwitchEmotes_defaultpack["konks"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\konks.tga:28:28"
            TwitchEmotes_defaultpack["largecock"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\largecock.tga:28:28"
            TwitchEmotes_defaultpack["monkaScandy"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\monkaScandy.tga:28:28"
            TwitchEmotes_defaultpack["moppcum"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\moppcum.tga:28:28"
            TwitchEmotes_defaultpack["Moppers"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Moppers.tga:28:28"
            TwitchEmotes_defaultpack["pepeshoots"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\pepeshoots.tga:28:28"
            TwitchEmotes_defaultpack["purge"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\purge.tga:28:28"
            TwitchEmotes_defaultpack["Stahp"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Stahp.tga:28:28"
            TwitchEmotes_defaultpack["suckssac"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\suckssac.tga:28:28"
            TwitchEmotes_defaultpack[":sac:"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\venomsac.tga:28:28"
            TwitchEmotes_defaultpack["Vipus"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Vipus.tga:28:28"
            TwitchEmotes_defaultpack["workwork"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\workwork.tga:28:28"
            TwitchEmotes_defaultpack["YKD"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\YKD.tga:28:28"
            TwitchEmotes_defaultpack["Grimaldus"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\Grimaldus.tga:28:28"
            TwitchEmotes_defaultpack["SadBuns"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\SadBuns.tga:28:28"
            TwitchEmotes_defaultpack["peepoMphjens"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\peepoMphjens.tga"
            TwitchEmotes_animation_metadata["Interface\\AddOns\\TwitchEmotes\\Emotes\\TaurenDairyCo\\peepoMphjens.tga"] = {["nFrames"] = 4, ["frameWidth"] = 32, ["frameHeight"] = 32, ["imageWidth"]=32, ["imageHeight"]=128, ["framerate"] = 10}
            -- Emote name references
            TwitchEmotes_emoticons["arthaslul"] = "arthaslul"
            TwitchEmotes_emoticons["banspray"] = "banspray"
            TwitchEmotes_emoticons[":bruh:"] = ":bruh:"
            TwitchEmotes_emoticons["dots"] = "dots"
            TwitchEmotes_emoticons["FeralPog"] = "FeralPog"
            TwitchEmotes_emoticons["Gachicrul"] = "Gachicrul"
            TwitchEmotes_emoticons["hugevenomsac"] = "hugevenomsac"
            TwitchEmotes_emoticons["hugevipus"] = "hugevipus"
            TwitchEmotes_emoticons["Jooper"] = "Jooper"
            TwitchEmotes_emoticons["khadscusemewhat"] = "khadscusemewhat"
            TwitchEmotes_emoticons["khadthink"] = "khadthink"
            TwitchEmotes_emoticons["konks"] = "konks"
            TwitchEmotes_emoticons["largecock"] = "largecock"
            TwitchEmotes_emoticons["monkaScandy"] = "monkaScandy"
            TwitchEmotes_emoticons["moppcum"] = "moppcum"
            TwitchEmotes_emoticons["Moppers"] = "Moppers"
            TwitchEmotes_emoticons["pepeshoots"] = "pepeshoots"
            TwitchEmotes_emoticons["purge"] = "purge"
            TwitchEmotes_emoticons["Stahp"] = "Stahp"
            TwitchEmotes_emoticons["suckssac"] = "suckssac"
            TwitchEmotes_emoticons["venomsac"] = "venomsac"
            TwitchEmotes_emoticons[":sac:"] = ":sac:"
            TwitchEmotes_emoticons["Vipus"] = "Vipus"
            TwitchEmotes_emoticons["workwork"] = "workwork"
            TwitchEmotes_emoticons["YKD"] = "YKD"
            TwitchEmotes_emoticons["Grimaldus"] = "Grimaldus"
            TwitchEmotes_emoticons["SadBuns"] = "SadBuns"
            TwitchEmotes_emoticons["peepoMphjens"] = "peepoMphjens"
            -- Dropdown menu
            TwitchEmotes_dropdown_options[#TwitchEmotes_dropdown_options + 1] = { -- 25
                "Tauren Dairy Co", "arthaslul", "banspray", ":bruh:", "dots","FeralPog", 
                "Gachicrul", "Grimaldus", "hugevenomsac", "hugevipus","Jooper","khadscusemewhat", 
                "khadthink", "konks","largecock", "monkaScandy", "moppcum", "Moppers", 
                "pepeshoots", "purge","Stahp", "suckssac",":sac:","SadBuns","Vipus","YKD",":jons:", "peepoMphjens"
            }
        elseif GetRealmName() == "Twisting Nether" and IsInGuild() then
            local function IsPlayerInOGFeedback()
                local guildName, guildRankName, guildRankIndex, realm = GetGuildInfo("player")
                if guildName == "OG Feedback" then
                    return true
                end
            end
            if IsPlayerInOGFeedback() == true then
                TwitchEmotes_dropdown_options[#TwitchEmotes_dropdown_options + 1] = { -- 16
                    'OG Feedback',
                    "BaileysDude", "BatriSam", "Cakers", "Chibol", "dudeman","SamWise", 
                    "FeelsPewMan", "GorillaPump", "PreachChamp", "Priotais","SamS","SamSafe", 
                    "samshades", "skoopas","SkoopRage", "Snakers"
                }
            end
        end

        local dateTime = C_DateAndTime.GetCurrentCalendarTime()
        if (dateTime.monthDay==4 and dateTime.month==5) and (dateTime.hour >= 10) then
            TwitchEmotes_emoticons["Sayrahs"] = "PepeSith"
            TwitchEmotes_emoticons["Sayramage"] = "PepeSith"
            TwitchEmotes_emoticons["Sayradh"] = "PepeSith"
        end


        TwitchEmotesUpdateFrame = CreateFrame("Frame", "TwitchEmotes_EventFrame", UIParent)
        TwitchEmotesUpdateFrame:SetScript('OnUpdate', TwitchEmotes_Update)

        Emoticons_EnableAnimatedEmotes(Emoticons_Settings["ENABLE_ANIMATEDEMOTES"])

        -- layout is TwitchEmoteStatistics[emote] = {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}
        TwitchEmoteStatistics = TwitchEmoteStatistics or {}; -- saved in savedvariables. (might slow ui loading if the dict gets big?)
        
        Emoticons_UpdateChatFilters();
        Emoticons_SetLargeEmotes(Emoticons_Settings["LARGEEMOTES"]);
        Emoticons_SetClickableEmotes(Emoticons_Settings["ENABLE_CLICKABLEEMOTES"]);
        Emoticons_InitChannelSettings();
		
		-- TODO: Waiting 1 second is kinda arbitrary, find a nicer solution.
		-- We don't accept Emote stat updates before ElvUI has posted it's chat history
		-- else they will be counted twice
		C_Timer.After(1, function()
			accept_stat_updates = true;
		end)
        
        Broker_TwitchEmotes = LDB:NewDataObject("TwitchEmotes", {
            type = "launcher",
            text = "TwitchEmotes",
            icon = "Interface\\AddOns\\TwitchEmotes\\Emotes\\1337.tga",
            OnClick = TwitchEmotes_MinimapButton_OnClick
        })
        
        if(Emoticons_Settings["MINIMAPBUTTON"]) then
            LDBIcon:Register("TwitchEmotes", Broker_TwitchEmotes, Emoticons_Settings["MINIMAPDATA"])
            iconregistered = true
        end

        Emoticons_SetMinimapButton(Emoticons_Settings["MINIMAPBUTTON"])
        
        AllTwitchEmoteNames = {};
        Emoticons_SetAutoComplete(Emoticons_Settings["ENABLE_AUTOCOMPLETE"])

        -- add WIM Support
    elseif (event == "ADDON_LOADED" and select(1, ...) == "WIM" and Emoticons_Settings["ENABLE_AUTOCOMPLETE"]) then
        local module = WIM.CreateModule("TwitchEmotes", true);
        function module:OnWindowCreated(win)
            local editbox = win.widgets.msg_box
            editbox:SetScript("OnKeyDown", editbox:GetScript("OnKeyDown") or function () end)

            local suggestionList = AllTwitchEmoteNames; -- Aleady preloaded from self loading
            local maxButtonCount = 20;
            local autocompletesettings = {
                perWord = true,
                activationChar = ':',
                closingChar = ':',
                minChars = 2,
                fuzzyMatch = true,
                onSuggestionApplied = function(suggestion)
                    UpdateEmoteStats(suggestion, true, false, false);
                end,
                renderSuggestionFN = Emoticons_RenderSuggestionFN,
                suggestionBiasFN = function(suggestion, text)
                    --Bias the sorting function towards the most autocompleted emotes
                    if TwitchEmoteStatistics[suggestion] ~= nil then
                        return TwitchEmoteStatistics[suggestion][1] * 5
                    end
                    return 0;
                end,
                interceptOnEnterPressed = true,
                addSpace = true,
                useTabToConfirm = Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"],
                useArrowButtons = true,
            }
            SetupAutoComplete(editbox, suggestionList, maxButtonCount, autocompletesettings);
        end
    end
end

function Emoticons_InitChannelSettings()
    local channels = {
        "CHAT_MSG_GUILD",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_PARTY_GUIDE",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_BN_CONVERSATION",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "MAIL"
    }

    for i=1, #channels do

        local channel = channels[i];
        local frame = getglobal("EmoticonsOptionsControlsPanel"..channel);
        if(frame ~= nil) then
            frame:SetChecked(Emoticons_Settings[channel]);
        end
    end
end

--this function transforms the text in the autocomplete suggestions (we add the emote image here)
function Emoticons_RenderSuggestionFN(text)
    local fullEmotePath = TwitchEmotes_defaultpack[text]
    if(fullEmotePath ~= nil) then
        local animdata = TwitchEmotes_animation_metadata[fullEmotePath]
        if animdata ~= nil then
            return TwitchEmotes_BuildEmoteFrameStringWithDimensions(fullEmotePath, animdata, 0, 16, 16) .. text;
        else
            local size = string.match(fullEmotePath, ":(.*)")
            local path_and_size = "";
            if(size ~= nil) then
                path_and_size = string.gsub(fullEmotePath, size, "16:16")
            else
                path_and_size = fullEmotePath .. "16:16";
            end
            return "|T".. path_and_size .."|t " .. text;
        end
    end
end

function setAllFav(value)
    for n, m in ipairs(Emoticons_Settings["FAVEMOTES"]) do
        Emoticons_Settings["FAVEMOTES"][n] = value;
        getglobal("favCheckButton_" .. TwitchEmotes_dropdown_options[n][1]):SetChecked(value);
    end
end

function Emoticons_OptionsWindow_OnShow(self)

    if Emoticons_Settings["MINIMAPBUTTON"] then
        getglobal("$showMinimapButtonButton"):SetChecked(true);
    end

    if Emoticons_Settings["LARGEEMOTES"] then
        getglobal("$showLargeEmotesButton"):SetChecked(true);
	end

    if Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
        getglobal("$showClickableEmotesButton"):SetChecked(true);
    end

    if Emoticons_Settings["ENABLE_AUTOCOMPLETE"] then
        getglobal("$autocompleteCheckButton"):SetChecked(true);
    end

    if Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"] then
        getglobal("$autocompleteUseTabToComplete"):SetChecked(true);
    end
    

    -- getglobal("$autocompleteCheckButton").tooltipText = "Start with a ':' to show a list of emotes.";

    getglobal("$autocompleteUseTabToComplete").tooltipText = "This will disable cycling the selected suggestion with tab, the arrow keys will still work.";

    favall = CreateFrame("CheckButton", "favall_GlobalName",
                         EmoticonsOptionsControlsPanel, "UIPanelButtonTemplate");
    favall:SetWidth(85);
    favall:SetScript("OnClick", function(self, arg1)
        setAllFav(true);
    end)

    favall:SetPoint("TOPLEFT", 17, -350);
    favall:SetText("Check all");
    favall.tooltip = "Check all boxes below.";

    favnone = CreateFrame("CheckButton", "favall_GlobalName",
                         EmoticonsOptionsControlsPanel, "UIPanelButtonTemplate");
    favnone:SetWidth(85);
    favnone:SetScript("OnClick", function(self, arg1)
        setAllFav(false);
    end)

    favnone:SetPoint("TOPLEFT", 130, -350);
    favnone:SetText("Check none");
    favnone.tooltip = "Uncheck all boxes below.";

    favnone = CreateFrame("CheckButton", "favnone_GlobalName",
                          favall_GlobalName, "UIRadioButtonTemplate");

    favframe = CreateFrame("Frame", "favframe_GlobalName", favall_GlobalName);
    favframe:SetPoint("TOPLEFT", 0, -24);
    favframe:SetSize(590, 175);

    first = true;
    itemcnt = 0
    for a, c in ipairs(TwitchEmotes_dropdown_options) do
        if first then
            favCheckButton = CreateFrame("CheckButton",
                                         "favCheckButton_" .. c[1],
                                         favframe_GlobalName,
                                         "ChatConfigCheckButtonTemplate");
            first = false;
            favCheckButton:SetPoint("TOPLEFT", 0, 0);
        else
            -- favbuttonlist=loadstring("favCheckButton_"..anchor);

            favCheckButton = CreateFrame("CheckButton",
                                         "favCheckButton_" .. c[1],
                                         favframe_GlobalName,
                                         "ChatConfigCheckButtonTemplate");
            favCheckButton:SetParent(getglobal("favCheckButton_" .. anchor));
            if ((itemcnt % 10) ~= 0) then
                favCheckButton:SetPoint("TOPLEFT", 0, -16);
            else
                favCheckButton:SetPoint("TOPLEFT", 110, 9 * 16);
            end
        end
        itemcnt = itemcnt + 1;
        anchor = c[1];

        getglobal(favCheckButton:GetName() .. "Text"):SetText(c[1]);
        if (getglobal("favCheckButton_" .. c[1]):GetChecked() ~=
            Emoticons_Settings["FAVEMOTES"][a]) then
            getglobal("favCheckButton_" .. c[1]):SetChecked(
                Emoticons_Settings["FAVEMOTES"][a]);
        end
        favCheckButton.tooltip = "Checked boxes will show in the dropdownlist.";
        favCheckButton:SetScript("OnClick", function(self)
            if (self:GetChecked()) then
                Emoticons_Settings["FAVEMOTES"][a] = true;
            else
                Emoticons_Settings["FAVEMOTES"][a] = false;
            end
        end);

    end
end

function Emoticons_RunReplacement(msg, senderGUID, msgID)
    -- remember to watch out for |H|h|h's

    local outstr = "";
    local origlen = #msg;
    local startpos = 1;
    local endpos;

    -- We need to ignore links, as to not break them.
    local linkStart, linkEnd = string.find(msg, "%[.+%]", startpos) 
    while(linkStart) do
        local link = string.sub(msg, linkStart, linkEnd)

        if startpos < linkStart then
            outstr = outstr .. Emoticons_InsertEmoticons(string.sub(msg, startpos, linkStart - 1), senderGUID, msgID); -- the bit before the current link
    end
        outstr = outstr .. link -- don't run replacement on the link, just add it to the return string
        startpos = linkEnd + 1
    
        linkStart, linkEnd = string.find(msg, "%[.+-.+%]+", startpos) -- find next link
    end

    outstr = outstr .. Emoticons_InsertEmoticons(string.sub(msg, startpos, #msg), senderGUID, msgID); -- the bit after the last link (or the whole message when no links found)

    return outstr;
end

function Emoticons_SetMinimapButton(state)
    Emoticons_Settings["MINIMAPBUTTON"] = state;
    
    if (state) then
        if not iconregistered then
            LDBIcon:Register("TwitchEmotes", Broker_TwitchEmotes, Emoticons_Settings["MINIMAPDATA"])
            iconregistered = true
        end
        LDBIcon:Show("TwitchEmotes");
    else
        LDBIcon:Hide("TwitchEmotes");
    end
end


function Emoticons_SetConfirmWithTab(state)
    Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"] = state;
    for _, frameName in pairs(CHAT_FRAMES) do
        local frame = _G[frameName]

        local editbox = frame.editBox;
        if editbox ~= nil and editbox.settings ~= nil then
            editbox.settings.useTabToConfirm = Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"];
        end
    end
end

function Emoticons_SetLargeEmotes(state)
    Emoticons_Settings["LARGEEMOTES"] = state;
end

function Emoticons_SetClickableEmotes(state)
    Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] = state;
end

function Emoticons_EnableAnimatedEmotes(state)
    Emoticons_Settings["ENABLE_ANIMATEDEMOTES"] = state;
end

function TwitchEmotes_Update(self, elapsed)
    
    local nChatFrames = #CHAT_FRAMES;
    if nChatFrames ~= TwitchEmotes_N_CHATFRAMES then
        TwitchEmotes_N_CHATFRAMES = nChatFrames
        TwitchEmotes_SetupChatFrames();
    end
    
    if Emoticons_Settings["ENABLE_ANIMATEDEMOTES"] then
        TwitchEmotesAnimator_OnUpdate(self, elapsed);
    end
    
end

function TwitchEmotes_SetupChatFrames() 
    for _, frameName in pairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        
        frame:HookScript("OnHyperlinkEnter", Emoticons_OnHyperlinkEnter)
        frame:HookScript("OnHyperlinkLeave", Emoticons_OnHyperlinkLeave)
    end
end

function Emoticons_SetAutoComplete(state)
    
    Emoticons_Settings["ENABLE_AUTOCOMPLETE"] = state

    if Emoticons_Settings["ENABLE_AUTOCOMPLETE"] and not autocompleteInited then
        AllTwitchEmoteNames = {};

        local i = 1;
        for k, v in pairs(TwitchEmotes_defaultpack) do
            --Some values in emoticons don't have a corresponding key in TwitchEmotes_defaultpack
            --we need to filter these out because we don't have an emote to show for these
            -- if TwitchEmotes_defaultpack[v] ~= nil then
                local excluded = false;
                for j=1, #TwitchEmotes_ExcludedSuggestions do
                    if k == TwitchEmotes_ExcludedSuggestions[j] then
                        excluded = true;
                        break;
                    end
                end

                if excluded == false then
                    AllTwitchEmoteNames[i] = k;
                    i = i + 1;
                end
            -- end
        end

        --Sort the list alphabetically
        table.sort(AllTwitchEmoteNames)

        for _, frameName in pairs(CHAT_FRAMES) do
            local frame = _G[frameName]

            local editbox = frame.editBox;
            local suggestionList = AllTwitchEmoteNames;
            local maxButtonCount = 20;

            local autocompletesettings = {
                perWord = true,
                activationChar = ':',
                closingChar = ':',
                minChars = 2,
                fuzzyMatch = true,
                onSuggestionApplied = function(suggestion)
                    UpdateEmoteStats(suggestion, true, false, false);
                end,
                renderSuggestionFN = Emoticons_RenderSuggestionFN,
                suggestionBiasFN = function(suggestion, text)
                    --Bias the sorting function towards the most autocompleted emotes
                    if TwitchEmoteStatistics[suggestion] ~= nil then
                        return TwitchEmoteStatistics[suggestion][1] * 5
                    end
                    return 0;
                end,
                interceptOnEnterPressed = true,
                addSpace = true,
                useTabToConfirm = Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"],
                useArrowButtons = true,
            }

            SetupAutoComplete(editbox, suggestionList, maxButtonCount, autocompletesettings);
            
        end
    
        autocompleteInited = true;
    end

end

--pass false or nil to leave a value as is, otherwise it gets incremented by one {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}
function UpdateEmoteStats(emote, nrTimesAutoCompleted, nrTimesSent, nrTimesSeen)
    
    if TwitchEmoteStatistics[emote] == nil then
        TwitchEmoteStatistics[emote] = {0, 0, 0};
    end

    local newautocompleted = (nrTimesAutoCompleted and TwitchEmoteStatistics[emote][1] + 1) or TwitchEmoteStatistics[emote][1];
    local newnrTimesSent = (nrTimesSent and TwitchEmoteStatistics[emote][2] + 1) or TwitchEmoteStatistics[emote][2];
    local newnrTimesSeen = (nrTimesSeen and TwitchEmoteStatistics[emote][3] + 1) or TwitchEmoteStatistics[emote][3];
    --print("registered emote stat, {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}: ", nrTimesAutoCompleted, nrTimesSent, nrTimesSeen)
    --print("new values: ", newautocompleted, newnrTimesSent, newnrTimesSeen)
    TwitchEmoteStatistics[emote] = {newautocompleted, newnrTimesSent,  newnrTimesSeen}
end

local lastmsgID = -1;
function Emoticons_InsertEmoticons(msg, senderGUID, msgID)
    local normal = '28:28'
    local large = '64:64'
    local xlarge = '128:128'
    local xxlarge = '256:256'
    local delimiters = "%s,'<>?-%.!"

    for word in string.gmatch(msg, "[^" .. delimiters .. "]+") do
        local emote = TwitchEmotes_emoticons[word]

        if TwitchEmotes_defaultpack[emote] ~= nil then
            --print("Inserting ", emote, msgID,  UnitGUID("player"));
            if accept_stat_updates then
                if msgID ~= lastmsgID then -- Only handle 
                    local localPlayerGUID = UnitGUID("player");
                    if localPlayerGUID == senderGUID then --We sent this message
                        UpdateEmoteStats(emote, false, true, false);
                    else -- someone else sent this message
                        UpdateEmoteStats(emote, false, false, true);
                    end
                end
            end
            
            -- print("Detected " .. emote)
            -- Get the size of the emote, if not a standard size
            local path_and_size = TwitchEmotes_defaultpack[emote]
            local path = string.match(path_and_size, "(.*%.tga)")
            local size = string.match(path_and_size, ":(.*)")
            -- Make a copy of the file path so we don't modify the original value
            local animdata = TwitchEmotes_GetAnimData(path);
            
            if(animdata == nil) then
                -- Check if the user has large emotes enabled. 
                -- If not, replace the size with the standard size of 28:28,
                -- else set it to the standard large size of 64:64
                if not Emoticons_Settings["LARGEEMOTES"] then
                    if ( size == 'LARGE' or size == 'XLARGE' or size == 'XXLARGE' ) then
                        path_and_size = string.gsub(TwitchEmotes_defaultpack[emote], size, normal)
                    end
                else
                    if ( size == 'LARGE' ) then
                        path_and_size = string.gsub(TwitchEmotes_defaultpack[emote], size, large)
                    elseif ( size == 'XLARGE' ) then
                        path_and_size = string.gsub(TwitchEmotes_defaultpack[emote], size, xlarge)
                    elseif ( size == 'XXLARGE') then
                        path_and_size = string.gsub(TwitchEmotes_defaultpack[emote], size, xxlarge)
                    end
                end
            else 
                path_and_size = TwitchEmotes_BuildEmoteFrameString(path, animdata, 0):gsub("|T", ""):gsub("|t", "");
            end
            

            local wrapPattern = "([" .. delimiters .. "]+)"

            if Emoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "$", 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h", 1);
				msg = string.gsub(msg, "^" .. word .. wrapPattern, 
				"|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%1", 1);
				msg = string.gsub(msg, "^" .. word .. "$", 
				"|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "(%c)", 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
			else
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, "%1|T" .. path_and_size .. "|t%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "$", "%1|T" .. path_and_size .. "|t", 1);
				msg = string.gsub(msg, "^" .. word .. wrapPattern, "|T" .. path_and_size .. "|t%1", 1);
				msg = string.gsub(msg, "^" .. word .. "$", "|T" .. path_and_size .. "|t");
				msg = string.gsub(msg, wrapPattern .. word .. "(%c)", "%1|T" .. path_and_size .. "|t%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, "%1|T" .. path_and_size .. "|t%2", 1);
			end
        end
    end

    lastmsgID = msgID; -- we only save stats of unique messages (this function is called multiple times per message, for each chat frame)
    return msg;
end

local oldsethyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link)
	if (string.sub(link, 1, 3) == "tel") then
		-- Capture the 'tel' link clicks (we show a tooltip on hover, so no click handeling is needed)
	else
		oldsethyperlink(self, link)
	end
end

function Emoticons_SetType(chattype, state)
    print('settype '..chattype..'  '.. tostring(state))
    if (state) then
        state = true;
    else
        state = false;
    end
    if (chattype == "CHAT_MSG_RAID") then
        Emoticons_Settings["CHAT_MSG_RAID_LEADER"] = state;
        Emoticons_Settings["CHAT_MSG_RAID_WARNING"] = state;
    end
    if (chattype == "CHAT_MSG_PARTY") then
        Emoticons_Settings["CHAT_MSG_PARTY_LEADER"] = state;
        Emoticons_Settings["CHAT_MSG_PARTY_GUIDE"] = state;
    end
    if (chattype == "CHAT_MSG_WHISPER") then
        Emoticons_Settings["CHAT_MSG_WHISPER_INFORM"] = state;
    end
    if (chattype == "CHAT_MSG_INSTANCE_CHAT") then
        Emoticons_Settings["CHAT_MSG_INSTANCE_CHAT_LEADER"] = state;
    end
    if (chattype == "CHAT_MSG_BN_WHISPER") then
        Emoticons_Settings["CHAT_MSG_BN_WHISPER_INFORM"] = state;
    end

    Emoticons_Settings[chattype] = state;
    Emoticons_UpdateChatFilters();
end

function Emoticons_RegisterPack(name, newEmoticons, pack)
    for k, v in pairs(newEmoticons) do
        TwitchEmotes_emoticons[k] = v
    end

    for k, v in pairs(pack) do
        TwitchEmotes_defaultpack[k] = v
    end
end

-- Dec's Synergy Twitch Emotes support

TwitchEmotes = {};
function TwitchEmotes:AddCategory(name, emotes)
    -- Initialise the category data (starting with the name)
    local category = {name};

    -- Insert our emotes into the category data
    for _, emote in ipairs(emotes) do
        table.insert(category, emote);
    end

    -- Get the next index in our dropdown options
    local nextCategoryIndex = (#TwitchEmotes_dropdown_options + 1);

    -- Add to the dropdown list
    TwitchEmotes_dropdown_options[nextCategoryIndex] = category;

    -- Ensure it shows up in the list in regards to the favourite filtering
    Emoticons_Settings["FAVEMOTES"][nextCategoryIndex] = true;
end

function TwitchEmotes:AddEmote(id, name, path)
    -- Add to the emote store
    TwitchEmotes_defaultpack[id] = path;

    -- Add to the message replacement list
    TwitchEmotes_emoticons[name] = id;
end

TwitchEmotes_HoverMessageInfo = nil;
function Emoticons_OnHyperlinkEnter(frame, link, message, fontstring, ...)
	local linkType, linkContent = link:match("^([^:]+):(.+)")
	if (linkType) then
		if (linkType == "tel") then
            TwitchEmotes_HoverMessageInfo = fontstring.messageInfo;

			GameTooltip:SetOwner(frame, "ANCHOR_CURSOR");
			GameTooltip:SetText(linkContent, 255, 210, 0);
			GameTooltip:Show();
		end
	end
end

function Emoticons_OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
    TwitchEmotes_HoverMessageInfo = nil
end
