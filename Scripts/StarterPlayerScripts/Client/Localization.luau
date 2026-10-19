local FX = _G.FX
local FXLoader = FX.Loader
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local SourceTable = FXLoader:Shared("Shared/Localization")
local LegacyTextSources = FXLoader:RequireShared("Scripts/Game/Shared/LegacyTextSources")
local Localization = {}
Localization.__index = Localization
local warnedCloudLocales = {}

--- 本地英文不依赖云端；云端加载在后台进行，不阻塞玩家组件初始化。
--- @param player Player 当前本地玩家。
--- @return table 当前玩家的翻译对象，Changed 为文案刷新信号。
function Localization.New(player)
    local self = setmetatable({}, Localization)
    self._english = SourceTable:GetTranslator("en-us")
    self._keys = {}
    self._legacyKeys = {}
    for index, entry in ipairs(SourceTable:GetEntries()) do
        self._keys[entry.Key] = true
        self._legacyKeys[entry.Source] = entry.Key
    end
    self._changed = Instance.new("BindableEvent")
    self.Changed = self._changed.Event
    --- 后台获取云端译文，失败不影响离线文案。
    self._loadTask = task.defer(function()
        -- 平台请求可能失败；有限重试后继续使用本地英文。
        for attempt = 1, 3 do
            --- Studio 跟随模拟语言，正式游戏跟随玩家当前体验语言。
            --- @return Translator 平台加载的翻译器。
            local success, translator = pcall(function()
                if RunService:IsStudio() then
                    return LocalizationService:GetTranslatorForLocaleAsync(LocalizationService.RobloxLocaleId)
                end
                return LocalizationService:GetTranslatorForPlayerAsync(player)
            end)
            if self._destroyed then
                return
            end
            if success then
                self._cloud = translator
                self._changed:Fire()
                --- Roblox 游戏内切换语言由 Translator 的 LocaleId 变化通知。
                self._cloudConnection = translator:GetPropertyChangedSignal("LocaleId"):Connect(function()
                    self._changed:Fire()
                end)
                self._loadTask = nil
                return
            end
            warn("Localization: cloud translator request " .. attempt .. " failed: " .. tostring(translator))
            if attempt < 3 then
                task.wait(5)
            end
        end
        self._loadTask = nil
        warn("Localization: cloud translator unavailable; using local English.")
    end)
    return self
end

--- 云端译文失败时每种语言仅警告一次并回退英文，避免界面刷新刷屏；本地 Key 或参数错误仍直接抛出。
--- @param key string 本地文案表中的稳定 Key。
--- @param arguments table? 模板参数；itemKey 在客户端按当前语言解析为 item，数量仍由调用方格式化。
--- @return string 当前玩家语言的文案。
function Localization:FormatByKey(key, arguments)
    if arguments and arguments.itemKey then
        arguments = table.clone(arguments)
        arguments.item = self:FormatByKey(arguments.itemKey)
        arguments.itemKey = nil
    end
    if not self._keys[key] then
        error("Localization: unknown key " .. tostring(key), 2)
    end
    if self._cloud and string.match(string.lower(self._cloud.LocaleId), "^[^-]+") ~= "en" then
        --- 云端缺少 Key 或译文格式错误时允许回退英文。
        --- @return string 格式化后的云端译文。
        local success, text = pcall(function()
            return self._cloud:FormatByKey(key, arguments)
        end)
        if success and text ~= "" then
            return text
        end
        local localeId = string.lower(self._cloud.LocaleId)
        if not warnedCloudLocales[localeId] then
            warnedCloudLocales[localeId] = true
            warn("Localization: cloud translation failed for " .. key .. " (" .. self._cloud.LocaleId
                .. "); using local English: " .. (success and "empty translation" or tostring(text)))
        end
    end
    return self._english:FormatByKey(key, arguments)
end

--- 英文原文直接作为 Key；尚未收集的模板仅在独立的运行时英文表中格式化，不修改发布文案表。
--- @param source string 英文原文或原生参数模板。
--- @param arguments table? 原生模板参数；旧协议的 itemKey 只在客户端解析。
--- @return string 当前玩家语言的文案，缺少译文时使用格式化后的英文。
function Localization:Tr(source, arguments)
    if arguments and arguments.itemKey then
        arguments = table.clone(arguments)
        arguments.item = self:Tr(arguments.itemKey)
        arguments.itemKey = nil
    end
    local toolId = string.match(source, "^Weapon%.Name%.(%d+)$")
    local itemId = string.match(source, "^Welfare%.Item%.(%d+)$")
    local descriptionId = string.match(source, "^Item%.Description%.(%d+)$")
    if toolId then
        for index, config in ipairs(_G.GameConfig.ToolConfig) do
            if config.ToolId == tonumber(toolId) then
                source = config.Name
                break
            end
        end
    elseif itemId then
        source = _G.ItemConfig.Display[tonumber(itemId)].Name
    elseif descriptionId then
        source = _G.ItemConfig.Display[tonumber(descriptionId)].Desc
    else
        source = LegacyTextSources[source] or source
    end
    if self._keys[source] then
        return self:FormatByKey(source, arguments)
    end
    if self._cloud and string.match(string.lower(self._cloud.LocaleId), "^[^-]+") ~= "en" then
        --- 云端条目可能早于本地收集更新，直接以英文原文查找。
        --- @return string 格式化后的云端译文。
        local success, text = pcall(function()
            return self._cloud:FormatByKey(source, arguments)
        end)
        if success and text ~= "" then
            return text
        end
    end
    -- 原文 Key 尚未上传时继续复用现有旧 Key 译文，不要求重建翻译表。
    local legacyKey = self._legacyKeys[source]
    if legacyKey then
        return self:FormatByKey(legacyKey, arguments)
    end
    if not arguments then
        return source
    end
    if not self._sourceFallback then
        self._sourceFallback = Instance.new("LocalizationTable")
        self._sourceFallback.SourceLocaleId = "en-us"
    end
    self._sourceFallback:SetEntryValue(source, source, "", "en-us", source)
    return self._sourceFallback:GetTranslator("en-us"):FormatByKey(source, arguments)
end

--- 释放本对象的后台请求任务、临时英文表和语言监听，避免销毁后更新界面。
function Localization:Destroy()
    self._destroyed = true
    if self._loadTask then
        task.cancel(self._loadTask)
        self._loadTask = nil
    end
    if self._cloudConnection then
        self._cloudConnection:Disconnect()
    end
    if self._sourceFallback then
        self._sourceFallback:Destroy()
    end
    self._changed:Destroy()
end

return Localization
