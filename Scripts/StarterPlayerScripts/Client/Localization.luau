local FX = _G.FX
local FXLoader = FX.Loader
local LocalizationService = game:GetService("LocalizationService")
local SourceTable = FXLoader:Shared("Scripts/Game/Shared/Localization")
local Localization = {}
Localization.__index = Localization

--- 本地英文不依赖云端；云端加载在后台进行，不阻塞玩家组件初始化。
--- @param player Player 当前本地玩家。
--- @return table 当前玩家的翻译对象，Changed 为文案刷新信号。
function Localization.New(player)
    local self = setmetatable({}, Localization)
    self._english = SourceTable:GetTranslator("en-us")
    self._keys = {}
    self._missingKeys = {}
    for index, entry in ipairs(SourceTable:GetEntries()) do
        self._keys[entry.Key] = true
    end
    self._changed = Instance.new("BindableEvent")
    self.Changed = self._changed.Event
    --- 后台获取云端译文，失败不影响离线文案。
    self._loadTask = task.defer(function()
        -- 平台请求可能失败；有限重试后继续使用本地英文。
        for attempt = 1, 3 do
            --- 请求玩家当前体验语言的云端翻译器。
            --- @return Translator 平台加载的翻译器。
            local success, translator = pcall(function()
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
            if attempt < 3 then
                task.wait(5)
            end
        end
        self._loadTask = nil
        warn("Localization: cloud translator unavailable; using local English.")
    end)
    return self
end

--- 英文玩家使用本地源文案，其余读取 Roblox 云端译文；缺失时回退本地英文。
--- @param key string 本地文案表中的稳定 Key。
--- @param arguments table? 模板参数；itemKey 在客户端按当前语言解析为 item，数量仍由调用方格式化。
--- @return string 当前玩家语言的文案，未知 Key 显示通用英文提示。
function Localization:FormatByKey(key, arguments)
    if arguments and arguments.itemKey then
        arguments = table.clone(arguments)
        arguments.item = self:FormatByKey(arguments.itemKey)
        arguments.itemKey = nil
    end
    if not self._keys[key] then
        if not self._missingKeys[key] then
            self._missingKeys[key] = true
            warn("Localization: unknown key " .. tostring(key))
        end
        return self._english:FormatByKey("Common.Unknown")
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
    end
    --- 错误参数只影响本次提示，不能打断后续 UI 和网络回调。
    --- @return string 格式化后的英文源文案。
    local success, text = pcall(function()
        return self._english:FormatByKey(key, arguments)
    end)
    if success then
        return text
    end
    warn("Localization: invalid parameters for " .. key .. ": " .. tostring(text))
    return self._english:FormatByKey("Common.Unknown")
end

--- 释放本对象的后台请求任务和语言监听，避免销毁后更新界面。
function Localization:Destroy()
    self._destroyed = true
    if self._loadTask then
        task.cancel(self._loadTask)
        self._loadTask = nil
    end
    if self._cloudConnection then
        self._cloudConnection:Disconnect()
    end
    self._changed:Destroy()
end

return Localization
