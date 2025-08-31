local TWITCHEMOTES_TimeSinceLastUpdate = 0
local TWITCHEMOTES_T = 0;

function TwitchEmotesAnimator_OnUpdate(self, elapsed)

    if (TWITCHEMOTES_TimeSinceLastUpdate >= 0.033) then
        -- Update animated emotes in chat windows (WoTLK compatible)
        for _, frameName in pairs(CHAT_FRAMES) do
            local chatFrame = _G[frameName]
            if chatFrame and chatFrame:IsShown() then
                -- In WoTLK, we need to iterate through fontstrings directly
                for i = 1, chatFrame:GetNumRegions() do
                    local region = select(i, chatFrame:GetRegions())
                    if region and region:GetObjectType() == "FontString" then
                        local text = region:GetText()
                        if text and string.find(text, "|TInterface\\AddOns\\TwitchEmotes\\Emotes") then
                            -- Preserve smart sizing
                            TwitchEmotesAnimator_UpdateEmoteInFontString(region, nil, nil);
                        end
                    end
                end
            end
        end

        -- Update animated emotes in suggestion list
        if (EditBoxAutoCompleteBox and EditBoxAutoCompleteBox:IsShown() and
            EditBoxAutoCompleteBox.existingButtonCount ~= nil) then
            for i = 1, EditBoxAutoCompleteBox.existingButtonCount do
                local cBtn = EditBoxAutoComplete_GetAutoCompleteButton(i);
                if (cBtn:IsVisible()) then
                    -- Preserve smart sizing
                    TwitchEmotesAnimator_UpdateEmoteInFontString(cBtn, nil, nil);
                else
                    break
                end
            end
        end

        -- Update animated emotes in WIM windows (if WIM is loaded)
        if WIM and WIM.windows and WIM.windows.active then
            -- Check active whisper windows
            if WIM.windows.active.whisper then
                for _, win in pairs(WIM.windows.active.whisper) do
                    if win and win.widgets and win.widgets.chat_display and win:IsShown() then
                        local chatDisplay = win.widgets.chat_display
                        if chatDisplay:IsVisible() then
                            -- Check each fontstring in the ScrollingMessageFrame
                            for i = 1, chatDisplay:GetNumRegions() do
                                local region = select(i, chatDisplay:GetRegions())
                                if region and region:GetObjectType() == "FontString" then
                                    local text = region:GetText()
                                    if text and string.find(text, "|TInterface\\AddOns\\TwitchEmotes\\Emotes") then
                                        TwitchEmotesAnimator_UpdateEmoteInFontString(region, nil, nil);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Check active chat windows (if any)
            if WIM.windows.active.chat then
                for _, win in pairs(WIM.windows.active.chat) do
                    if win and win.widgets and win.widgets.chat_display and win:IsShown() then
                        local chatDisplay = win.widgets.chat_display
                        if chatDisplay:IsVisible() then
                            for i = 1, chatDisplay:GetNumRegions() do
                                local region = select(i, chatDisplay:GetRegions())
                                if region and region:GetObjectType() == "FontString" then
                                    local text = region:GetText()
                                    if text and string.find(text, "|TInterface\\AddOns\\TwitchEmotes\\Emotes") then
                                        TwitchEmotesAnimator_UpdateEmoteInFontString(region, nil, nil);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Check active w2w windows (if any)
            if WIM.windows.active.w2w then
                for _, win in pairs(WIM.windows.active.w2w) do
                    if win and win.widgets and win.widgets.chat_display and win:IsShown() then
                        local chatDisplay = win.widgets.chat_display
                        if chatDisplay:IsVisible() then
                            for i = 1, chatDisplay:GetNumRegions() do
                                local region = select(i, chatDisplay:GetRegions())
                                if region and region:GetObjectType() == "FontString" then
                                    local text = region:GetText()
                                    if text and string.find(text, "|TInterface\\AddOns\\TwitchEmotes\\Emotes") then
                                        TwitchEmotesAnimator_UpdateEmoteInFontString(region, nil, nil);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Update animated emotes in statistics screen
        if(TwitchStatsScreen:IsVisible()) then
           
            local topSentImagePath = TwitchEmotes_defaultpack[TwitchEmoteSentStatKeys[1]] or "Interface\\AddOns\\TwitchEmotes\\Emotes\\1337.tga";
            local animdata = TwitchEmotes_animation_metadata[topSentImagePath:match("(Interface\\AddOns\\TwitchEmotes\\Emotes.-.tga)")]
            
            if(animdata ~= nil) then
                local cFrame = TwitchEmotes_GetCurrentFrameNum(animdata)
                TwitchStatsScreen.topSentEmoteTexture:SetTexCoord(TwitchEmotes_GetTexCoordsForFrame(animdata, cFrame)) 
            end
                

            local topSeenImagePath = TwitchEmotes_defaultpack[TwitchEmoteRecievedStatKeys[1]] or "Interface\\AddOns\\TwitchEmotes\\Emotes\\1337.tga";
            local animdata = TwitchEmotes_animation_metadata[topSeenImagePath:match("(Interface\\AddOns\\TwitchEmotes\\Emotes.-.tga)")]
            if(animdata ~= nil) then
                local cFrame = TwitchEmotes_GetCurrentFrameNum(animdata)
                TwitchStatsScreen.topSeenEmoteTexture:SetTexCoord(TwitchEmotes_GetTexCoordsForFrame(animdata, cFrame)) 
            end
            

            for line=1, 17 do
                local sentEntry = _G["TwitchStatsSentEntry"..line]
                local recievedEntry = _G["TwitchStatsRecievedEntry"..line]

                if(sentEntry and sentEntry:IsVisible()) then
                    TwitchEmotesAnimator_UpdateEmoteInFontString(sentEntry, 16, 16);
                end

                if(recievedEntry and recievedEntry:IsVisible()) then
                    TwitchEmotesAnimator_UpdateEmoteInFontString(recievedEntry, 16, 16);
                end
            end
        end
        

        TWITCHEMOTES_TimeSinceLastUpdate = 0;
    end

    TWITCHEMOTES_T = TWITCHEMOTES_T + elapsed
    TWITCHEMOTES_TimeSinceLastUpdate = TWITCHEMOTES_TimeSinceLastUpdate +
                                        elapsed;
end

local function escpattern(x)
    return (
            --x:gsub('%%', '%%%%')
             --:gsub('^%^', '%%^')
             --:gsub('%$$', '%%$')
             --:gsub('%(', '%%(')
             --:gsub('%)', '%%)')
             --:gsub('%.', '%%.')
             --:gsub('%[', '%%[')
             --:gsub('%]', '%%]')
             --:gsub('%*', '%%*')
             x:gsub('%+', '%%+')
             :gsub('%-', '%%-')
             --:gsub('%?', '%%?'))
            )
end

-- This will update the texture escapesequence of an animated emote
-- if it exsists in the contents of the fontstring
function TwitchEmotesAnimator_UpdateEmoteInFontString(fontstring, widthOverride, heightOverride)
    local txt = fontstring:GetText();
    if (txt ~= nil) then
        for emoteTextureString in txt:gmatch("(|TInterface\\AddOns\\TwitchEmotes\\Emotes.-|t)") do
            local imagepath = emoteTextureString:match("|T(Interface\\AddOns\\TwitchEmotes\\Emotes.-.tga).-|t")

            local animdata = TwitchEmotes_animation_metadata[imagepath];
            if (animdata ~= nil) then
                local framenum = TwitchEmotes_GetCurrentFrameNum(animdata);
                local nTxt;
                
                -- Extract existing dimensions from the emote string to preserve smart sizing
                local existingWidth, existingHeight = emoteTextureString:match("|T.-:(%d+):(%d+):")
                local finalWidth = widthOverride or (existingWidth and tonumber(existingWidth)) or 24
                local finalHeight = heightOverride or (existingHeight and tonumber(existingHeight)) or 24
                
                nTxt = txt:gsub(escpattern(emoteTextureString),
                                    TwitchEmotes_BuildEmoteFrameStringWithDimensions(
                                    imagepath, animdata, framenum, finalWidth, finalHeight))

                -- If we're updating a chat message we need to alter the messageInfo as wel
                if (fontstring.messageInfo ~= nil) then
                    fontstring.messageInfo.message = nTxt
                end
                fontstring:SetText(nTxt);
                txt = nTxt;
            end
        end
    end
end

function TwitchEmotes_GetAnimData(imagepath)
    return TwitchEmotes_animation_metadata[imagepath]
end

function TwitchEmotes_GetCurrentFrameNum(animdata)
    if(animdata.pingpong) then
        local vframen = math.floor((TWITCHEMOTES_T * animdata.framerate) % ((animdata.nFrames * 2) - 1));
        if vframen > animdata.nFrames then
            vframen = animdata.nFrames - (vframen % animdata.nFrames)
        end
        return  vframen
    end
    
    return math.floor((TWITCHEMOTES_T * animdata.framerate) % animdata.nFrames);
end

function TwitchEmotes_GetTexCoordsForFrame(animdata, framenum)
    local fHeight = animdata.frameHeight;
    return 0, 1 ,framenum * fHeight / animdata.imageHeight, ((framenum * fHeight) + fHeight) / animdata.imageHeight
end

function TwitchEmotes_BuildEmoteFrameString(imagepath, animdata, framenum)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. animdata.frameWidth .. ":" ..
                        animdata.frameHeight .. ":0:0:" .. animdata.imageWidth ..
                        ":" .. animdata.imageHeight .. ":0:" ..
                        animdata.frameWidth .. ":" .. top .. ":" .. bottom ..
                        "|t";
    return emoteStr
end

function TwitchEmotes_BuildEmoteFrameStringWithDimensions(imagepath, animdata,
                                                        framenum, framewidth,
                                                        frameheight)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. framewidth .. ":" ..
                        frameheight .. ":0:0:" .. animdata.imageWidth .. ":" ..
                        animdata.imageHeight .. ":0:" .. animdata.frameWidth ..
                        ":" .. top .. ":" .. bottom .. "|t";
    return emoteStr
end
