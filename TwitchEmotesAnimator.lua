local TWITCHEMOTES_TimeSinceLastUpdate = 0
local TWITCHEMOTES_T = 0;

function TwitchEmotesAnimator_OnUpdate(self, elapsed)

    if (TWITCHEMOTES_TimeSinceLastUpdate >= 0.033) then
        -- Update animated emotes in chat windows
        for _, frameName in pairs(CHAT_FRAMES) do
            for _, visibleLine in ipairs(_G[frameName].visibleLines) do
                if(_G[frameName]:IsShown() and visibleLine.messageInfo ~= TwitchEmotes_HoverMessageInfo) then 
                    TwitchEmotesAnimator_UpdateEmoteInFontString(visibleLine, 28, 28);
                end
            end
        end

        -- Update animated emotes in suggestion list
        if (EditBoxAutoCompleteBox and EditBoxAutoCompleteBox:IsShown() and
            EditBoxAutoCompleteBox.existingButtonCount ~= nil) then
            for i = 1, EditBoxAutoCompleteBox.existingButtonCount do
                local cBtn = EditBoxAutoComplete_GetAutoCompleteButton(i);
                if (cBtn:IsVisible()) then
                    TwitchEmotesAnimator_UpdateEmoteInFontString(cBtn, 16, 16);
                else
                    break
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
                local sentEntry = getglobal("TwitchStatsSentEntry"..line)
                local recievedEntry = getglobal("TwitchStatsRecievedEntry"..line)

                if(sentEntry:IsVisible()) then
                    TwitchEmotesAnimator_UpdateEmoteInFontString(sentEntry, 16, 16);
                end

                if(recievedEntry:IsVisible()) then
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
                if(widthOverride ~= nil or heightOverride ~= nil) then
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                        TwitchEmotes_BuildEmoteFrameStringWithDimensions(
                                        imagepath, animdata, framenum, widthOverride, heightOverride))
                else
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                      TwitchEmotes_BuildEmoteFrameString(
                                        imagepath, animdata, framenum))
                end

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