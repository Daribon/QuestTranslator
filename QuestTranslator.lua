-- Addon: QuestTranslator (version: 4.01) for Vanilla Wow (classic 1.12.1) 2015.02.12
-- Description: AddOn displays translated quest information in original or separete window.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Based on addon "QuestJapanizer" v.0.5.8 by lalha


-- Global Variables
local QTR_version = "4.01";
local QTR_name = UnitName("player");
local QTR_class= UnitClass("player");
local QTR_race = UnitRace("player");
local QTR_event="";
local QuestTranslator_MessOrig = {
      details    = "Description", 
      objectives = "Objectives", 
      rewards    = "Rewards", 
      itemchoose1= "You will be able to choose one of these rewards:", 
      itemchoose2= "Choose one of these rewards:", 
      itemreceiv1= "You will also receive:", 
      itemreceiv2= "You receiving the reward:", 
      learnspell = "Learn Spell:", 
      reqmoney   = "Required Money:", 
      reqitems   = "Required items:", 
      experience = "Experience:", 
      currquests = "Current Quests", 
      avaiquests = "Available Quests", };
local Original_Font1 = "Fonts\\MORPHEUS.ttf";
local Original_Font2 = "Fonts\\FRIZQT__.ttf";
if not QuestTranslator then
   QuestTranslator = { };
end


function QuestTranslator_CheckVars()
  if (not QTR_PS) then
     QTR_PS = {};
  end
  if (not QTR_PC) then
     QTR_PC = {};
  end
  if (not QTR_SAVED) then
     QTR_SAVED = {};
  end
  -- initialize check options
  if (not QTR_PS["active"]) then
     QTR_PS["active"] = "1";   
  end
  if (not QTR_PS["mode"] ) then
     QTR_PS["mode"] = "2";   
  end
  if (not QTR_PS["transtitle"] ) then
     QTR_PS["transtitle"] = "0";   
  end
  if (not QTR_PS["size"] ) then
     QTR_PS["size"] = "1";   
  end
  if (not QTR_PS["width"] ) then
     QTR_PS["width"] = "1";   
  end

  -- set check buttons 
  if (QTR_PS["size"] == "1") then
     QuestTranslator_SizeH = 1;
  else 
     QuestTranslator_SizeH = 2;     
     QuestTranslatorFrame1:SetHeight(525);
     QuestTranslator_QuestDetail:SetHeight(430);
     QTR_ToggleButton2:SetText("^");
  end
  if (QTR_PS["width"] == "1") then
     QuestTranslator_SizeW = 1;
  else 
     QuestTranslator_SizeW = 2;     
     QuestTranslatorFrame1:SetWidth(525);
     QuestTranslator_QuestDetail:SetWidth(495);
     QuestTranslator_QuestTitle:SetWidth(495);
     QTR_ToggleButton3:SetText("<");
  end
  if ( QTR_PS["isGetQuestID"] ) then
     isGetQuestID=QTR_PS["isGetQuestID"];
  end;
end


function QuestTranslator_SetCheckButtonState()
  QuestTranslatorCheckButton0:SetChecked(QTR_PS["active"]=="1");
  QuestTranslatorCheckButton1:SetChecked(QTR_PS["mode"]=="1");
  QuestTranslatorCheckButton2:SetChecked(QTR_PS["mode"]=="2");
  QuestTranslatorCheckButton3:SetChecked(QTR_PS["transtitle"]=="1");
  QuestTranslatorCheckButton4:SetChecked(QTR_PS["size"]=="1");
  QuestTranslatorCheckButton5:SetChecked(QTR_PS["size"]=="2");
  QuestTranslatorCheckButton6:SetChecked(QTR_PS["width"]=="1");
  QuestTranslatorCheckButton7:SetChecked(QTR_PS["width"]=="2");
end


function QuestTranslator_OnLoad1()
  QuestTranslator.frame1 = CreateFrame("Frame");
  QuestTranslator.frame1:RegisterEvent("ADDON_LOADED");
  QuestTranslator.frame1:RegisterEvent("QUEST_LOG_UPDATE");
  QuestTranslator.frame1:SetScript("OnEvent", QuestTranslator_OnEvent1);
  QuestLogDetailScrollFrame:SetScript("OnShow", QuestTranslator_ShowAndUpdateQuestInfo);
  QuestLogDetailScrollFrame:SetScript("OnHide", QuestTranslator_HideQuestInfo);

  QuestTranslator_QuestTitle:SetFont(QTR_Font, 17);
  QuestTranslator_QuestDetail:SetFont(QTR_Font, 14);
  QuestTranslatorFrame1:ClearAllPoints();
  QuestTranslatorFrame1:SetPoint("TOPLEFT", QuestLogFrame, "TOPRIGHT", -3, -12);

  -- small button in QuestLogFrame
  QTR_ToggleButton1 = CreateFrame("Button",nil, QuestLogFrame, "UIPanelButtonTemplate");
  QTR_ToggleButton1:SetWidth(35);
  QTR_ToggleButton1:SetHeight(18);
  QTR_ToggleButton1:SetText("QTR");
  QTR_ToggleButton1:Show();
  QTR_ToggleButton1:ClearAllPoints();
  QTR_ToggleButton1:SetPoint("TOPLEFT", QuestLogFrame, "TOPRIGHT", -100, -15);
  QTR_ToggleButton1:SetScript("OnClick", QuestTranslator_ToggleVisibility);

  -- button for ChangeFrameHeight
  QTR_ToggleButton2 = CreateFrame("Button",nil, QuestTranslatorFrame1, "UIPanelButtonTemplate");
  QTR_ToggleButton2:SetWidth(15);
  QTR_ToggleButton2:SetHeight(22);
  QTR_ToggleButton2:SetText("v");
  QTR_ToggleButton2:Show();
  QTR_ToggleButton2:ClearAllPoints();
  QTR_ToggleButton2:SetPoint("BOTTOMLEFT", QuestTranslatorFrame1, "BOTTOMRIGHT", -40, 9);
  QTR_ToggleButton2:SetScript("OnClick", QuestTranslator_ChangeFrameHeight);

  -- button for ChangeFrameWidth
  QTR_ToggleButton3 = CreateFrame("Button",nil, QuestTranslatorFrame1, "UIPanelButtonTemplate");
  QTR_ToggleButton3:SetWidth(15);
  QTR_ToggleButton3:SetHeight(22);
  QTR_ToggleButton3:SetText(">");
  QTR_ToggleButton3:Show();
  QTR_ToggleButton3:ClearAllPoints();
  QTR_ToggleButton3:SetPoint("BOTTOMLEFT", QuestTranslatorFrame1, "BOTTOMRIGHT", -25, 9);
  QTR_ToggleButton3:SetScript("OnClick", QuestTranslator_ChangeFrameWidth);

  if hooksecurefunc then
     hooksecurefunc("QuestLogTitleButton_OnClick", function() QuestTranslator_UpdateQuestInfo() end);
  else
     local QTR_QuestLogTitleButton_OnClik = QuestLogTitleButton_OnClick;
     function QuestLogTitleButton_OnClick(button)
        QuestTranslator_UpdateQuestInfo();
        QTR_QuestLogTitleButton_OnClik(button);
     end
  end
end


function QuestTranslator_OnEvent1()

  if (event == "ADDON_LOADED") then
     QuestTranslator_CheckVars();
     --QuestTranslator_BlizzardOptions();
     if (DEFAULT_CHAT_FRAME) then
         DEFAULT_CHAT_FRAME:AddMessage("|cffffff00QuestTranslator ver. "..QTR_version.." "..QTR_lang.." - " .. QuestTranslator_Messages.loaded);
     else
         UIErrorsFrame:AddMessage("|cffffff00QuestTranslator ver. "..QTR_version.." "..QTR_lang.." - " .. QuestTranslator_Messages.loaded, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
     end
     QuestTranslator.frame1:UnregisterEvent("ADDON_LOADED");
     if (not isGetQuestID) then
        DetectEmuServer();
     end;
  end

  if (event == "QUEST_LOG_UPDATE") then
     if (QuestTranslatorFrame1:IsVisible()) then
        QuestTranslator_UpdateQuestInfo();
     end
  end

end
  

function QuestTranslator_OnLoad2()
  QuestTranslator.frame2 = CreateFrame("Frame");
  QuestTranslator.frame2:RegisterEvent("QUEST_GREETING");
  QuestTranslator.frame2:RegisterEvent("QUEST_DETAIL");
  QuestTranslator.frame2:RegisterEvent("QUEST_PROGRESS");
  QuestTranslator.frame2:RegisterEvent("QUEST_COMPLETE");
  QuestTranslator.frame2:SetScript("OnEvent", QuestTranslator_OnEvent3);
  QuestTranslator_QuestTitle2:SetFont(QTR_Font, 17);
  QuestTranslator_QuestDetail2:SetFont(QTR_Font, 14);
  QuestTranslator_QuestWarning2:SetFont(QTR_Font, 12);
  QuestTranslatorFrame2:ClearAllPoints();
  QuestTranslatorFrame2:SetPoint("TOPLEFT", QuestFrame, "TOPRIGHT", -31, -19);
  QuestFrame:SetScript("OnHide", QuestTranslator_Frame2Close);
end


function DetectEmuServer()
  QTR_PS["isGetQuestID"]="0";
  isGetQuestID="0";
  -- function GetQuestID() don't work on wow-emulator servers - possible lua error when you first start - not significant
--   if (DEFAULT_CHAT_FRAME) then
--     DEFAULT_CHAT_FRAME:AddMessage("|cffffff00QTR: checking function GetQuestID() - possible lua error.");
--  end
--  if ( GetQuestID() ) then
--     QTR_PS["isGetQuestID"]="1";
--     isGetQuestID="1";
--     if (DEFAULT_CHAT_FRAME) then
--        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00QTR: function GetQuestID() working!");
--     end
--  end
end


function QuestTranslator_OnEvent3()

  if (event == "QUEST_GREETING") then
    if (QTR_PS["active"]=="1" and QTR_PS["mode"]=="1") then
      CurrentQuestsText:SetText(QuestTranslator_Messages.currquests);
      CurrentQuestsText:SetFont(QTR_Font, 18);
      AvailableQuestsText:SetText(QuestTranslator_Messages.avaiquests);
      AvailableQuestsText:SetFont(QTR_Font, 18);
    else
      CurrentQuestsText:SetText(QuestTranslator_MessOrig.currquests);
      CurrentQuestsText:SetFont(Original_Font1, 18);
      AvailableQuestsText:SetText(QuestTranslator_MessOrig.avaiquests);
      AvailableQuestsText:SetFont(Original_Font1, 18);
    end
  end

  if (event == "QUEST_DETAIL") then
     QTR_event = "QUEST_DETAIL";
     QuestTranslator_OnEvent2();
  end

  if (event == "QUEST_PROGRESS") then
     QTR_event = "QUEST_PROGRESS";
     QuestTranslator_OnEvent2();
  end

  if (event == "QUEST_COMPLETE") then
     QTR_event = "QUEST_COMPLETE";
     QuestTranslator_OnEvent2();
  end
  
end


function QuestTranslator_SearchIDforName(qqq_title)
    qqq_ID = 0;
    if (QuestTranslator_QuestList[qqq_title]) then
        local qqq_lists=QuestTranslator_QuestList[qqq_title];
        qqq_i=string.find(qqq_lists, ",");
        if ( string.find(qqq_lists, ",")==nil ) then
            -- only 1 questID to this title
            qqq_ID=tonumber(qqq_lists);
        else
            -- multiple questIDs - get first, available (not completed) questID from QuestLists
            local QTR_table=QTR_split(qqq_lists, ",");
            local QTR_multiple = "";
            local QTR_Center="";
            for ii,vv in ipairs(QTR_table) do
                if (not QTR_PC[vv]) then
                    if (QTR_Center=="") then
                        QTR_Center=vv;
                    else
                        QTR_multiple = QTR_multiple .. ", " .. vv;
                    end
                end
            end
            if ( string.len(QTR_Center)>0 ) then
                qqq_ID=tonumber(QTR_Center);
                if ( string.len(QTR_multiple)>0 ) then
                    QTR_multiple = " (" .. string.sub(QTR_multiple, 3) .. ")";
                    QuestTranslator_QuestWarning2:SetText(QuestTranslator_Messages.multipleID .. QTR_multiple);
                end
            end
        end
    end
return qqq_ID;
end


function QuestTranslator_OnEvent2()
  local q_ID = 0;
  local q_title = GetTitleText();
  
  if ( QTR_PS["active"]=="1" )then
     QuestTranslator_QuestID2:SetText("");
     QuestTranslator_QuestTitle2:SetText(q_title);
     QuestTranslator_QuestDetail2:SetText(QuestTranslator_Messages.missing);
     QuestTranslator_QuestWarning2:SetText("");
     
     if ( q_ID == 0 ) then
        if ( isGetQuestID=="1" ) then
           q_ID = GetQuestID();
        end
        if ( q_ID == 0 ) then
		   q_ID = QuestTranslator_SearchIDforName(q_title);
        end
     end
     if ( q_ID > 0 ) then
        local str_id = tostring(q_ID);
        QuestTranslator_QuestID2:SetText("QuestID: " .. str_id);
        QuestTranslator_QuestTitle2:SetText(q_title);
        if (QuestTranslator_QuestData[str_id]) then
           -- display only, if translation exists
	   if (QTR_PS["mode"]=="2") then
              QuestTranslator_ShowFrame2(QTR_event, str_id);
           end
        else
           -- DEFAULT_CHAT_FRAME:AddMessage("QuestTranslator - Qid: "..tostring(q_ID).." ("..QuestTranslator_Messages.missing..")");
           QTR_SAVED[str_id.." TITLE"]=GetTitleText();               -- save original title to future translation
           if (QTR_event=="QUEST_DETAIL") then
              QTR_SAVED[str_id.." DESCRIPTION"]=GetQuestText();      -- save original text to future translation
              QTR_SAVED[str_id.." OBJECTIVE"]=GetObjectiveText();    -- save original text to future translation
           end
           if (QTR_event=="QUEST_PROGRESS") then
              QTR_SAVED[str_id.." PROGRESS"]=GetProgressText();      -- save original text to future translation
           end
           if (QTR_event=="QUEST_COMPLETE") then
              QTR_SAVED[str_id.." COMPLETE"]=GetRewardText();        -- save original text to future translation
           end
           QuestTranslatorFrame2:Hide();
        end
     end
  end
  if (QTR_event == "QUEST_COMPLETE") then
     if ( q_ID > 0) then
        local str_id = tostring(q_ID);
        QTR_PC[str_id]="OK";
     end
  end
end


function QuestTranslator_ShowFrame2(eventStr, qid)
  QuestTranslator_QuestID2:SetText("QuestID: " .. qid);
  QuestTranslator_QuestDetail2:SetText(QuestTranslator_Messages.missing);
  if (QuestTranslator_QuestData[qid]) then
     QuestTranslator_QuestTitle2:SetText(QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[qid]["Title"]));
     local QTR_text = "";
     if (eventStr == "QUEST_DETAIL") then
        if (QuestTranslator_QuestData[qid]["Description"]) then
           QTR_text = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[qid]["Description"]);
        end
        local QTR_text2 = "";
        if (QuestTranslator_QuestData[qid]["Objectives"]) then
           QTR_text2 = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[qid]["Objectives"]);
        end
        QTR_text = QTR_text .. "\n\n" .. QuestTranslator_Messages.objectives .. "\n" .. QTR_text2;
     end
     if (eventStr == "QUEST_PROGRESS") then
        if (QuestTranslator_QuestData[qid]["Progress"]) then
           QTR_text = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[qid]["Progress"]);
        end
     end
     if (eventStr == "QUEST_COMPLETE") then
        if (QuestTranslator_QuestData[qid]["Completion"]) then
           QTR_text = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[qid]["Completion"]);
        end
     end
     QuestTranslator_QuestDetail2:SetText(QTR_text);
     QuestTranslatorFrame2:ClearAllPoints();
     QuestTranslatorFrame2:SetPoint("TOPLEFT", QuestFrame, "TOPRIGHT", -31, -19);
     if ( QuestNPCModel ) then
        if ( QuestNPCModel:IsVisible() ) then
           QuestTranslatorFrame2:SetPoint("TOPLEFT", QuestNPCModel, "TOPRIGHT", 0, 42);
        end
     end
     QuestTranslatorFrame2:Show();
  end
end


function QuestTranslator_Frame2Close()
  QuestTranslatorFrame2:Hide();
  QuestFrame_OnHide();
end


function QTR_split(str, c)
  local aCount = 0;
  local array = {};
  local a = string.find(str, c);
  while a do
     aCount = aCount + 1;
     array[aCount] = string.sub(str, 1, a-1);
     str=string.sub(str, a+1);
     a = string.find(str, c);
  end
  aCount = aCount + 1;
  array[aCount] = str;
  return array;
end


function QTR_findlast(source, char)
  if (not source) then
     return 0;
  end
  local lastpos = 0;
  local byte_char = string.byte(char);
  for i=1, table.getn(source) do
     if (string.byte(source,i)==byte_char) then
        lastpos = i;
     end
  end
  return lastpos;
end


function QuestTranslator_ChangeFrameHeight()
  -- normal height of Frame = 450, quest detail = 350
  if (QuestTranslator_SizeH == 1) then
     QuestTranslatorFrame1:SetHeight(525);
     QuestTranslator_QuestDetail:SetHeight(430);
     QTR_ToggleButton2:SetText("^");
     QuestTranslator_SizeH = 2;
     QTR_PS["size"] = "2";
  else
     QuestTranslatorFrame1:SetHeight(450);
     QuestTranslator_QuestDetail:SetHeight(350);
     QTR_ToggleButton2:SetText("v");
     QuestTranslator_SizeH = 1;
     QTR_PS["size"] = "1";
  end
end


function QuestTranslator_ChangeFrameWidth()
  -- normal width of Frame = 350, quest detail = 320
  if (QuestTranslator_SizeW == 1) then
     QuestTranslatorFrame1:SetWidth(525);
     QuestTranslator_QuestDetail:SetWidth(495);
     QuestTranslator_QuestTitle:SetWidth(495);
     QTR_ToggleButton3:SetText("<");
     QuestTranslator_SizeW = 2;
     QTR_PS["width"] = "2";
  else
     QuestTranslatorFrame1:SetWidth(350);
     QuestTranslator_QuestDetail:SetWidth(320);
     QuestTranslator_QuestTitle:SetWidth(320);
     QTR_ToggleButton3:SetText(">");
     QuestTranslator_SizeW = 1;
     QTR_PS["width"] = "1";
  end
end


function QuestTranslator_OnMouseDown1()
  -- start moving the window
  QuestTranslatorFrame1:StartMoving();
end
  

function QuestTranslator_OnMouseUp1()
  -- stop moving the window
  QuestTranslatorFrame1:StopMovingOrSizing();
end


function QuestTranslator_OnMouseDown2()
  -- start moving the window
  QuestTranslatorFrame2:StartMoving();
end
  

function QuestTranslator_OnMouseUp2()
  -- stop moving the window
  QuestTranslatorFrame2:StopMovingOrSizing();
end


function QuestTranslator_ToggleVisibility()
  -- click on QTR button in QuestLogFrame
  if (QTR_PS["active"]=="0") then
     QTR_PS["active"] = "1";
     QuestTranslator_ShowAndUpdateQuestInfo();
  else
     QTR_PS["active"] = "0";
     QuestTranslator_HideQuestInfo();
  end
end


function QuestTranslator_ShowAndUpdateQuestInfo()
  if (QTR_PS["active"]=="0") then
     return;
  end
  if (QTR_PS["mode"]=="2") then
     QuestTranslatorFrame1:Show();
  end;
  QuestTranslator_UpdateQuestInfo();
end


function QuestTranslator_HideQuestInfo()
  QuestTranslatorFrame1:Hide();
end


function QuestTranslator_UpdateQuestInfo()
  if (QTR_PS["active"]=="0") then
     return;
  end
  local questSelected = GetQuestLogSelection();
  if (GetQuestLogTitle(questSelected) == nil) then
     return;
  end
  local questTitle = GetQuestLogTitle(questSelected);
  if (isHeader) then
     return;
  end

  local qid = QuestTranslator_SearchIDforName(questTitle);
  local str_id = tostring(qid);
  QuestTranslator_QuestID:SetText("QuestID: " .. str_id);

  if (QuestTranslator_QuestData[str_id]) then
     QTR_objectives  = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[str_id]["Objectives"]);
     QTR_description = QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[str_id]["Description"]);
     QTR_descripFull = QuestTranslator_Messages.details .. "\n" .. QTR_description;
     QTR_translator = "";
     if (QuestTranslator_QuestData[str_id]["Translator"]) then
        if (QuestTranslator_QuestData[str_id]["Translator"]>"") then
            QTR_translator = "\n\n" .. QuestTranslator_Messages.translator .. " " .. QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[str_id]["Translator"]);
        end
     end
     QuestTranslator_QuestTitle:SetText(QuestTranslator_ExpandUnitInfo(QuestTranslator_QuestData[str_id]["Title"]));
     QuestTranslator_QuestDetail:SetText(QTR_objectives .. "\n\n" .. QTR_descripFull .. QTR_translator);
  else
     QuestTranslator_QuestTitle:SetText(questTitle);
     QuestTranslator_QuestDetail:SetText(QuestTranslator_Messages.missing);
  end 
end


function QuestTranslator_ExpandUnitInfo(msg)
  -- replace special characters into message
  msg = string.gsub(msg, "NEW_LINE", "\n");
  msg = string.gsub(msg, "YOUR_NAME", QTR_name);
  msg = string.gsub(msg, "YOUR_CLASS", QTR_class);
  msg = string.gsub(msg, "YOUR_RACE", QTR_race);
  return msg;
end

