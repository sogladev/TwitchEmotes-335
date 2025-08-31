-- local LIBRARY_NAME = "AceGUI-3.0-EditBox-AutoComplete";
-- local VERSION = 1;
-- local AceGUI;
local maximumButtonCount = 5;
local autoCompleteButtonSpacing = 8; -- Vertical spacing between autocomplete buttons in pixels

-- TODO: Before pullrequesting to the LibEditbox-Autocomplete repo reimplement AceGUI-3.0 support
-- if LibStub then
-- 	AceGUI = LibStub("AceGUI-3.0")
-- 	if AceGUI then
-- 		local lib = LibStub:NewLibrary(LIBRARY_NAME,VERSION)
-- 		if not lib then return end

-- 		AceGUI:RegisterWidgetType ("EditBox-AutoComplete", function()
-- 			local e = AceGUI:Create("EditBox")
-- 			SetupAutoComplete(e.editbox)
-- 			e.SetValueList = function(self,valueList)
-- 				self.editbox.valueList = valueList
-- 			end
-- 			e.SetButtonCount = function(self,buttonCount)
-- 				self.editbox.buttonCount = buttonCount
-- 			end
-- 			e.AddHighlightedText = function(self,addHighlightedText)
-- 				self.editbox.addHighlightedText = addHighlightedText
-- 			end

-- 			return e 
-- 		end, VERSION)
-- 	end
-- end
local old_ChatEdit_GetNextTellTarget = ChatEdit_GetNextTellTarget;
function SetupAutoComplete(editbox, valueList, maxButtonCount, settings)

    editbox.old_OnEnterPressed = editbox.old_OnEnterPressed or
                                     editbox:GetScript("OnEnterPressed")
    editbox.old_OnEscPressed = editbox.old_OnEscPressed or
                                   editbox:GetScript("OnEscapePressed")
    editbox.old_OnTabPressed = editbox.old_OnTabPressed or
                                   editbox:GetScript("OnTabPressed")
    editbox.old_OnKeyDown = editbox.old_OnKeyDown or
                                editbox:GetScript("OnKeyDown")
    editbox.old_OnEditFocusLost = editbox.old_OnEditFocusLost or
                                      editbox:GetScript("OnEditFocusLost")

    local defaultsettings = {
        perWord = false,
        activationChar = '',
        closingChar = '',
        minChars = 0,
        fuzzyMatch = false,
        onSuggestionApplied = nil,
        renderSuggestionFN = nil,
        suggestionBiasFN = nil,
        interceptOnEnterPressed = false,
        addSpace = false,
        useTabToConfirm = false,
        useArrowButtons = false
    }

    editbox.settings = defaultsettings;

    if settings ~= nil then
        for k, v in pairs(settings) do editbox.settings[k] = v end
    end

    editbox.valueList = valueList or {}
    editbox.buttonCount = maxButtonCount or 10;
    editbox.addHighlightedText = true

    EditBoxAutoCompleteBox:SetScript("OnHide", function(self)
		ChatEdit_GetNextTellTarget = old_ChatEdit_GetNextTellTarget;
        TwitchEmotesResumeElvUIHistory(self.parent);
    end);

    -- This should happen once globally, not for each autocomplete textbox
    EditBoxAutoCompleteBox.mouseInside = false;
    EditBoxAutoCompleteBox:SetScript("OnEnter", function(self)
        EditBoxAutoCompleteBox.mouseInside = true;
    end);
    EditBoxAutoCompleteBox:SetScript("OnLeave", function(self)
        EditBoxAutoCompleteBox.mouseInside = false;
    end);

    editbox:HookScript("OnTabPressed", function(editbox)
        if (editbox.settings.useTabToConfirm) then
            EditBoxAutoComplete_OnEnterPressed(editbox)
        else
            EditBoxAutoComplete_IncrementSelection(editbox, IsShiftKeyDown());
        end
    end);

    if (settings.useArrowButtons) then
        editbox:SetScript("OnKeyDown", function(editbox, key)

            if (EditBoxAutoCompleteBox:IsShown() and (EditBoxAutoCompleteBox.parent == editbox)) then
                if key == "TAB" then
                    ChatEdit_GetNextTellTarget = function()
                        return "", "";
                    end
                end
            end

            if key == "ENTER" then
                EditBoxAutoComplete_OnEnterPressed(editbox)
            end

            if EditBoxAutoComplete_OnArrowPressed(editbox, key) then
                TwitchEmotesPauseElvUIHistory(editbox);
            else
                if editbox.old_OnKeyDown ~= nil then
                    editbox.old_OnKeyDown(editbox, key)
                end
            end

        end);
    end

    editbox:HookScript("OnTextChanged", function(editbox, changedByUser)
        EditBoxAutoComplete_OnTextChanged(editbox, changedByUser)
    end)

    editbox:HookScript("OnChar", function(editbox, char)

        if (char == editbox.settings.closingChar and
            editbox:GetUTF8CursorPosition() == #editbox:GetText() and
            editbox:GetUTF8CursorPosition() > 1) then

            EditBoxAutoComplete_OnEnterPressed(editbox)
        else
            EditBoxAutoComplete_OnChar(editbox);
        end

    end)

    editbox:SetScript("OnEditFocusLost", function(editbox)
        if not EditBoxAutoCompleteBox.mouseInside then
            EditBoxAutoComplete_HideIfAttachedTo(editbox)
            EditBox_ClearHighlight(editbox)
            editbox.old_OnEditFocusLost(editbox)
        end
    end)

    editbox:SetScript("OnEscapePressed", function(editbox)
        if not EditBoxAutoComplete_OnEscapePressed(editbox) then
            editbox.old_OnEscPressed(editbox)

            if AceGUI then
                AceGUI:ClearFocus(editbox.obj)
            else
                editbox:ClearFocus()
            end
        end
    end)

end

--todo: rename
function TwitchEmotesPauseElvUIHistory(editbox)
    if editbox.historyLines then
        -- If we captured the arrowkeys and ElvUI added historyLines to this editbox
        -- we save the historyLines and set the ElvUI var to nil
        -- ElvUI hooks onto the onKeyDown event, temporarily removing the historyLines
        -- prevents the chat editbox's content by being replaced by elvui when this hook runs
        -- we restore the historyLines when the autocomplete dialog closes

        -- print("Will back up  " .. #editbox.historyLines .. " lines")
        editbox.PreservedHistoryLines = editbox.historyLines
        editbox.historyLines = nil
    end
end

--todo: rename
function TwitchEmotesResumeElvUIHistory(editbox)

    if editbox ~= nil and editbox.PreservedHistoryLines ~= nil then
        -- print("restored " .. #editbox.PreservedHistoryLines .. " lines")
        editbox.historyLines = editbox.PreservedHistoryLines;
    end
end

function EditBoxAutoComplete_GetAutoCompleteButton(index)
    local buttonName = "EditBoxAutoCompleteButton" .. index;
    if not _G[buttonName] then
        local btn = CreateFrame("Button", buttonName, EditBoxAutoCompleteBox,
                                "EditBoxAutoCompleteButtonTemplate")
        btn:SetPoint("TOPLEFT", EditBoxAutoComplete_GetAutoCompleteButton(index - 1), "BOTTOMLEFT",
                     0, -autoCompleteButtonSpacing)
        btn:SetScript("OnEnter", function(self)
            EditBoxAutoCompleteBox.mouseInside = true;
        end)
        btn:SetScript("OnLeave", function(self)
            EditBoxAutoCompleteBox.mouseInside = false;
        end)
        _G[buttonName] = btn
        EditBoxAutoCompleteBox.existingButtonCount = max(index,
                                                         EditBoxAutoCompleteBox.existingButtonCount or
                                                             1)
    end
    return _G[buttonName];
end

local function GetEditBoxAutoCompleteResults(text, valueList, fuzzyMatch)
    local results = {}
    local resultsCount = 1

    pcall(function()
        for i, value in ipairs(valueList) do
            pcall(function()

                local pattern = text:lower();
                if fuzzyMatch then
                    pattern = "^.*" .. text:lower() .. ".*";
                end

                if string.find(value:lower(), pattern) == 1 then
                    results[resultsCount] = value;
                    resultsCount = resultsCount + 1
                end
            end)
        end
    end)

    return results;
end

function EditBoxAutoComplete_OnLoad(self)
    self:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
        tile = true,
        tileSize = 32,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    AutoCompleteInstructions:SetText("|cffbbbbbb" .. PRESS_TAB .. "|r");
end

function EditBoxAutoComplete_Update(parent, text, cursorPosition)
    local self = EditBoxAutoCompleteBox;
    local attachPoint;
    local origText = text

    if (not self:IsShown()) then
        self.currentResults = {}
        self.resultOffset = 0
    end

    if parent.settings.perWord then
        local words = {}
        local newSentence = ""

        for word in string.gmatch(parent:GetText(), "([^%s]+)") do
            if word then table.insert(words, word) end
        end

        if (string.sub(origText, -1) ~= " ") then
            text = words[#words] -- Only use last word
        else
            text = ""
        end

    end

    if (not text or text == "") then
        EditBoxAutoComplete_HideIfAttachedTo(parent);
        return;
    end

    if (text ~= nil and parent.settings.activationChar ~= "") then
        if (#text < 2 or string.sub(text, 1, 1) ~=
            parent.settings.activationChar) then
            EditBoxAutoComplete_HideIfAttachedTo(parent);
            return;
        else
            text = string.sub(text, 2) -- Remove the activation char
        end
    end

    if (#text < parent.settings.minChars) then
        EditBoxAutoComplete_HideIfAttachedTo(parent);
        return;
    end

    if (cursorPosition <= strlen(origText)) then

        self:SetParent(parent);
        if (self.parent ~= parent) then
            EditBoxAutoComplete_SetSelectedIndex(self, 0);
            self.parentArrows = parent:GetAltArrowKeyMode();
        end
        parent:SetAltArrowKeyMode(false);
        -- Calculate height including spacing between buttons
        local totalSpacing = (maximumButtonCount - 1) * autoCompleteButtonSpacing
        local height = EditBoxAutoComplete_GetAutoCompleteButton(1):GetHeight() * maximumButtonCount + totalSpacing
        if (parent:GetBottom() - height <= (AUTOCOMPLETE_DEFAULT_Y_OFFSET + 10)) then -- 10 is a magic number from the offset of AutoCompleteButton1.
            attachPoint = "ABOVE";
        else
            attachPoint = "BELOW";
        end
        if ((self.parent ~= parent) or (self.attachPoint ~= attachPoint)) then
            if (attachPoint == "ABOVE") then
                self:ClearAllPoints();
                self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT",
                              parent.autoCompleteXOffset or 0,
                              parent.autoCompleteYOffset or
                                  -AUTOCOMPLETE_DEFAULT_Y_OFFSET);
            elseif (attachPoint == "BELOW") then
                self:ClearAllPoints();
                self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",
                              parent.autoCompleteXOffset or 0,
                              parent.autoCompleteYOffset or
                                  AUTOCOMPLETE_DEFAULT_Y_OFFSET);
            end
            self.attachPoint = attachPoint;
        end

        self.parent = parent;
        local possibilities = GetEditBoxAutoCompleteResults(text,
                                                            parent.valueList,
                                                            parent.settings
                                                                .fuzzyMatch);
        if (not possibilities) then possibilities = {}; end

        if (parent.settings.fuzzyMatch) then
            -- We sort the possibilities here according to the following criteria

            -- 1. amount of characters in text vs the total in the possibility(match) (weight 100)
            -- 2. how early in we match (weight 50)
            -- 3. how many matching characters (case sensitive) (weight 25)

            local baseSortingFN = function(match, text)
                local matchingChars = 0;
                local cleanmatch = match;
                local cleantext = text;
                if(parent.settings.activationChar ~= '' or parent.settings.closingChar ~= '') then
                    cleanmatch = match:gsub("[" ..
                                            parent.settings.activationChar ..
                                            parent.settings.closingChar ..
                                            "]", "")
                    cleantext = text:gsub("[" ..
                        parent.settings.activationChar ..
                        parent.settings.closingChar ..
                    "]", "")
                end
                
                local index, _, _ =
                    string.find(cleanmatch:lower(), cleantext:lower())

                -- Check how many characters actually match (case sensitive)
                for i = index, index + #cleantext do
                    if (string.sub(cleantext, i - (index - 1), i - (index - 1)) ==
                        string.sub(cleanmatch, i, i)) then
                        matchingChars = matchingChars + 1;
                    end
                end

                return (25 * (1 - (matchingChars / #cleantext))) + (50 * index) +
                           (25 * (1 - (#cleantext / #cleanmatch)))
            end

            if parent.settings.suggestionBiasFN ~= nil then
                table.sort(possibilities, function(left, right)
                    return baseSortingFN(left, text) -
                               parent.settings.suggestionBiasFN(left, text) <
                               baseSortingFN(right, text) -
                               parent.settings.suggestionBiasFN(right, text)
                end)
            else
                table.sort(possibilities, function(left, right)
                    return
                        baseSortingFN(left, text) < baseSortingFN(right, text)
                end)
            end
        end

        self.currentResults = possibilities
        EditBoxAutoComplete_UpdateResults(self, possibilities);
    else
        EditBoxAutoComplete_HideIfAttachedTo(parent);
    end
end

function EditBoxAutoComplete_HideIfAttachedTo(parent)
    local self = EditBoxAutoCompleteBox;
    if (self.parent == parent) then
        if (self.parentArrows) then
            parent:SetAltArrowKeyMode(self.parentArrows);
            self.parentArrows = nil;
        end
        TwitchEmotesResumeElvUIHistory(parent);
        self.parent = nil;

        self:Hide();
    end
end

function EditBoxAutoComplete_SetSelectedIndex(self, index)
    self.selectedIndex = index;
    for i = 1, maximumButtonCount do
        EditBoxAutoComplete_GetAutoCompleteButton(i):UnlockHighlight();
    end
    if (index ~= 0) then EditBoxAutoComplete_GetAutoCompleteButton(index):LockHighlight(); end
end

function EditBoxAutoComplete_GetSelectedIndex(self) return self.selectedIndex; end

function EditBoxAutoComplete_GetNumResults(self) return self.numResults; end

function EditBoxAutoComplete_UpdateResults(self, results, indexOffset)
    local indexOffset = indexOffset or 0
    local totalReturns = #results - indexOffset;
    local numReturns = min(totalReturns, maximumButtonCount);
    local maxWidth = 150;

    for i = 1, numReturns do
        local button = EditBoxAutoComplete_GetAutoCompleteButton(i)
        button.name = Ambiguate(results[i + indexOffset], "none");

        if (self.parent.settings.renderSuggestionFN ~= nil) then
            local text = self.parent.settings.renderSuggestionFN(results[i +
                                                                     indexOffset])
            button:SetText(text);
        else
            button:SetText(results[i + indexOffset]);
        end

        maxWidth = max(maxWidth, button:GetFontString():GetWidth() + 30);
        button:Enable();
        button:Show();
    end

    for i = numReturns + 1, EditBoxAutoCompleteBox.existingButtonCount do
        EditBoxAutoComplete_GetAutoCompleteButton(i):Hide();
    end

    if (numReturns > 0) then
        maxWidth = max(maxWidth, AutoCompleteInstructions:GetStringWidth() + 30);
        -- Add spacing between buttons: numReturns * buttonHeight + (numReturns - 1) * spacing + base padding
        local totalSpacing = (numReturns - 1) * autoCompleteButtonSpacing
        self:SetHeight(numReturns * AutoCompleteButton1:GetHeight() + totalSpacing + 35);
        self:SetWidth(maxWidth);
        self:Show();
        EditBoxAutoComplete_SetSelectedIndex(self, 1);
    else
        self:Hide();
    end

    if (totalReturns > maximumButtonCount) then
        local button = EditBoxAutoComplete_GetAutoCompleteButton(maximumButtonCount);
        button:SetText(CONTINUED);
        button:Disable();
        self.numResults = numReturns - 1;
    else
        self.numResults = numReturns;
    end
end

function EditBoxAutoComplete_IncrementSelection(editBox, up)
    local autoComplete = EditBoxAutoCompleteBox;
    autoComplete.resultOffset = autoComplete.resultOffset or 0;

    if (autoComplete:IsShown() and autoComplete.parent == editBox) then
        local selectedIndex = EditBoxAutoComplete_GetSelectedIndex(autoComplete);
        local numReturns = EditBoxAutoComplete_GetNumResults(autoComplete);
        if (up) then
            local nextNum = selectedIndex;
            if selectedIndex == 1 then
                if autoComplete.resultOffset > 0 then
                    autoComplete.resultOffset = autoComplete.resultOffset - 1
                    EditBoxAutoComplete_UpdateResults(autoComplete,
                                                      autoComplete.currentResults,
                                                      autoComplete.resultOffset)
                else
                    autoComplete.resultOffset =
                        #autoComplete.currentResults - numReturns
                    nextNum = numReturns
                    EditBoxAutoComplete_UpdateResults(autoComplete,
                                                      autoComplete.currentResults,
                                                      autoComplete.resultOffset)
                end
            else
                nextNum = selectedIndex - 1;
            end
            EditBoxAutoComplete_SetSelectedIndex(autoComplete, nextNum);
        else
            -- print("Down " .. selectedIndex .. " " .. #autoComplete.currentResults .. " " .. (autoComplete.resultOffset or "NIL"))
            local nextNum = selectedIndex;
            if selectedIndex == numReturns then
                if #autoComplete.currentResults - autoComplete.resultOffset >
                    numReturns then
                    autoComplete.resultOffset = autoComplete.resultOffset + 1
                    EditBoxAutoComplete_UpdateResults(autoComplete,
                                                      autoComplete.currentResults,
                                                      autoComplete.resultOffset)
                else
                    autoComplete.resultOffset = 0
                    nextNum = 1
                    EditBoxAutoComplete_UpdateResults(autoComplete,
                                                      autoComplete.currentResults,
                                                      autoComplete.resultOffset)
                end
            else
                nextNum = selectedIndex + 1;
            end

            EditBoxAutoComplete_SetSelectedIndex(autoComplete, nextNum)
        end
        return true;
    end
    return false;
end

function EditBoxAutoComplete_OnTabPressed(editBox)
    return EditBoxAutoComplete_IncrementSelection(editBox, IsShiftKeyDown())
end

function EditBoxAutoComplete_OnArrowPressed(self, key)
    if (key == "UP") then
        return EditBoxAutoComplete_IncrementSelection(self, true);
    elseif (key == "DOWN") then
        return EditBoxAutoComplete_IncrementSelection(self, false);
    end
end

function EditBoxAutoComplete_OnEnterPressed(self)
    local autoComplete = EditBoxAutoCompleteBox;
    if (autoComplete:IsShown() and (autoComplete.parent == self) and
        (EditBoxAutoComplete_GetSelectedIndex(autoComplete) ~= 0)) then

        EditBoxAutoCompleteButton_OnClick(
            EditBoxAutoComplete_GetAutoCompleteButton(EditBoxAutoComplete_GetSelectedIndex(
                                      autoComplete)));
        return true;
    end
    return false;
end

function EditBoxAutoComplete_OnTextChanged(self, userInput)

    maximumButtonCount = self.buttonCount;
    if (userInput) then
        EditBoxAutoComplete_Update(self, self:GetText(),
                                   self:GetUTF8CursorPosition());
    end
    if (self:GetText() == "") then
        EditBoxAutoComplete_HideIfAttachedTo(self);
    end
end

function EditBoxAutoComplete_AddHighlightedText(editBox, text)
    local editBoxText = editBox:GetText();
    local utf8Position = editBox:GetUTF8CursorPosition();
    local possibilities = GetEditBoxAutoCompleteResults(text);

    if (possibilities and possibilities[1]) then
        -- We're going to be setting the text programatically which will clear the userInput flag on the editBox. So we want to manually update the dropdown before we change the text.
        EditBoxAutoComplete_Update(editBox, editBoxText, utf8Position);
        local newText = string.gsub(editBoxText, AUTOCOMPLETE_SIMPLE_REGEX,
                                    string.format(
                                        AUTOCOMPLETE_SIMPLE_FORMAT_REGEX,
                                        possibilities[1], string.match(
                                            editBoxText,
                                            AUTOCOMPLETE_SIMPLE_REGEX)), 1)
        editBox:SetText(newText);
        editBox:HighlightText(strlen(editBoxText), strlen(newText)); -- This won't work if there is more after the name, but we aren't enabling this for normal chat (yet). Please fix me when we do.
        editBox:SetCursorPosition(strlen(editBoxText));
    end
end

function EditBoxAutoComplete_OnChar(self)
    local autoComplete = EditBoxAutoCompleteBox;
    if (autoComplete:IsShown() and autoComplete.parent == self) then
        if (self.addHighlightedText and self:GetUTF8CursorPosition() ==
            strlenutf8(self:GetText())) then
            EditBoxAutoComplete_AddHighlightedText(self, self:GetText());
            return true;
        end
    end

    return false;
end

function EditBoxAutoComplete_OnEditFocusLost(self)
    EditBoxAutoComplete_HideIfAttachedTo(self);
end

function EditBoxAutoComplete_OnEscapePressed(self)
    local autoComplete = EditBoxAutoCompleteBox;
    if (autoComplete:IsShown() and autoComplete.parent == self) then
        EditBoxAutoComplete_HideIfAttachedTo(self);
        return true;
    end
    return false;
end

function EditBoxAutoCompleteButton_OnClick(self)
    local autoComplete = self:GetParent();
    local editBox = autoComplete.parent;
    local editBoxText = editBox:GetText();
    local newText;

    if (editBox.command) then
        newText = editBox.command .. " " .. self.name;
    else
        newText = string.gsub(editBoxText, AUTOCOMPLETE_SIMPLE_REGEX,
                              string.format(AUTOCOMPLETE_SIMPLE_FORMAT_REGEX,
                                            self.name, string.match(editBoxText,
                                                                    AUTOCOMPLETE_SIMPLE_REGEX)),
                              1);
    end

    if editBox.settings.perWord then
        local words = {}
        local newSentence = ""

        for word in string.gmatch(editBoxText, "([^%s]+)") do
            table.insert(words, word)
        end

        for i = 1, (#words - 1) do
            newSentence = newSentence .. words[i] .. " "
        end

        newSentence = newSentence .. newText
        if (editBox.settings.addSpace) then
            newSentence = newSentence .. " "
        end

        editBox:SetText(newSentence);
        -- When we change the text, we move to the end, so we'll be consistent and move to the end if we don't change it as well.
        editBox:SetCursorPosition(strlen(newSentence));
    else
        editBox:SetText(newText);
        -- When we change the text, we move to the end, so we'll be consistent and move to the end if we don't change it as well.
        editBox:SetCursorPosition(strlen(newText));
    end

    autoComplete:Hide();

    if editBox.settings.onSuggestionApplied ~= nil then
        editBox.settings.onSuggestionApplied(self.name);
    end
end
