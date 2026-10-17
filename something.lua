local KEYS = { ["16serial"] = true }
local KEY_FILE = "FwSerial_key.txt"

local function KeyGate()
    local TweenService = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")
    local parent = (gethui and gethui()) or game:GetService("CoreGui")

    local function verify(k)
        k = tostring(k or ""):match("^%s*(.-)%s*$"):lower()
        if k == "" then return false, "Enter a key." end
        if KEYS[k] == true then return true end
        return false, "Invalid key."
    end

    local saved
    pcall(function() if isfile and isfile(KEY_FILE) then saved = readfile(KEY_FILE) end end)
    if saved and verify(saved) then return true end

    local BGc, BG2c, BG3c = Color3.fromRGB(16, 16, 20), Color3.fromRGB(24, 24, 30), Color3.fromRGB(40, 40, 52)
    local ACC, TXTc, DIMc = Color3.fromRGB(88, 101, 242), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
    local RED, GREEN = Color3.fromRGB(240, 90, 100), Color3.fromRGB(80, 255, 120)
    local FONTc = Enum.Font.Code

    local function mk(class, props, par)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = par
        return o
    end
    local function tw(o, t, props, style, dir)
        local x = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
        x:Play()
        return x
    end
    local function rounded(p, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
    local function hover(btn, base)
        local sc = mk("UIScale", {}, btn)
        btn.AutoButtonColor = false
        btn.MouseEnter:Connect(function() tw(btn, 0.12, { BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.12) }) end)
        btn.MouseLeave:Connect(function()
            tw(btn, 0.12, { BackgroundColor3 = base })
            tw(sc, 0.15, { Scale = 1 })
        end)
        btn.MouseButton1Down:Connect(function() tw(sc, 0.08, { Scale = 0.95 }) end)
        btn.MouseButton1Up:Connect(function() tw(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back) end)
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "FwSerialKey"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 200
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    sg.Parent = parent

    local frame = mk("CanvasGroup", {
        Size = UDim2.fromOffset(340, 226), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = BGc, BorderSizePixel = 0, GroupTransparency = 1,
    }, sg)
    rounded(frame, 16)
    mk("UIStroke", { Color = ACC, Thickness = 1.5 }, frame)
    local scale = mk("UIScale", { Scale = 0.88 }, frame)
    tw(frame, 0.3, { GroupTransparency = 0 })
    tw(scale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

    mk("TextLabel", {
        Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Font = FONTc,
        TextSize = 20, TextColor3 = TXTc, Text = "FwSerial | HvH",
    }, frame)
    mk("TextLabel", {
        Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = FONTc,
        TextSize = 13, TextColor3 = DIMc, Text = "Enter your key to continue  (drag the top to move)",
    }, frame)

    local dragConns, dragging, dStart, dPos = {}, false, nil, nil
    local dragBar = mk("Frame", { Size = UDim2.new(1, -44, 0, 64), BackgroundTransparency = 1, Active = true }, frame)
    dragBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dStart, dPos = true, i.Position, frame.Position
        end
    end)
    table.insert(dragConns, UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            frame.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X, dPos.Y.Scale, dPos.Y.Offset + d.Y)
        end
    end))
    table.insert(dragConns, UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    local box = mk("TextBox", {
        Position = UDim2.fromOffset(20, 80), Size = UDim2.new(1, -40, 0, 38), BackgroundColor3 = BG3c, BorderSizePixel = 0,
        Font = FONTc, TextSize = 15, TextColor3 = TXTc, Text = "", PlaceholderText = "key...", PlaceholderColor3 = DIMc,
        ClearTextOnFocus = false,
    }, frame)
    rounded(box, 10)
    local boxStroke = mk("UIStroke", { Color = BG3c, Thickness = 1.5 }, box)
    box.Focused:Connect(function() tw(boxStroke, 0.15, { Color = ACC }) end)
    box.FocusLost:Connect(function() tw(boxStroke, 0.15, { Color = BG3c }) end)

    local status = mk("TextLabel", {
        Position = UDim2.fromOffset(20, 124), Size = UDim2.new(1, -40, 0, 16), BackgroundTransparency = 1, Font = FONTc,
        TextSize = 12, TextColor3 = DIMc, Text = "",
    }, frame)

    local verifyBtn = mk("TextButton", {
        Position = UDim2.fromOffset(20, 152), Size = UDim2.new(1, -40, 0, 42), BackgroundColor3 = ACC, BorderSizePixel = 0,
        Font = FONTc, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), Text = "Verify",
    }, frame)
    rounded(verifyBtn, 12)
    hover(verifyBtn, ACC)

    mk("TextLabel", {
        Position = UDim2.fromOffset(0, 200), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Font = FONTc,
        TextSize = 11, TextColor3 = DIMc, Text = "press ENTER to submit",
    }, frame)

    local closeB = mk("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(24, 22),
        BackgroundColor3 = Color3.fromRGB(170, 50, 65), BorderSizePixel = 0, Font = FONTc, TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1), Text = "X",
    }, frame)
    rounded(closeB, 8)
    hover(closeB, Color3.fromRGB(170, 50, 65))

    local done, ok, busy = false, false, false
    local function submit()
        if busy or done then return end
        busy = true
        status.TextColor3 = DIMc
        status.Text = "Checking..."
        local good, reason = verify(box.Text)
        if good then
            status.TextColor3 = GREEN
            status.Text = "Key accepted!"
            tw(boxStroke, 0.2, { Color = GREEN })
            pcall(function() if writefile then writefile(KEY_FILE, box.Text) end end)
            task.wait(0.4)
            ok, done = true, true
        else
            status.TextColor3 = RED
            status.Text = reason or "Invalid key."
            tw(boxStroke, 0.15, { Color = RED })
            local base = frame.Position
            for _, dx in ipairs({ 12, -12, 8, -8, 4, -4, 0 }) do
                tw(frame, 0.04, { Position = base + UDim2.fromOffset(dx, 0) })
                task.wait(0.04)
            end
            busy = false
        end
    end
    verifyBtn.MouseButton1Click:Connect(submit)
    box.FocusLost:Connect(function(enter) if enter then submit() end end)
    closeB.MouseButton1Click:Connect(function() done = true end)

    while not done do task.wait(0.1) end
    for _, c in ipairs(dragConns) do c:Disconnect() end
    tw(frame, 0.22, { GroupTransparency = 1 })
    tw(scale, 0.25, { Scale = ok and 1.08 or 0.88 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.wait(0.28)
    sg:Destroy()
    return ok
end

if not KeyGate() then return end

local Library, ThemeManager, SaveManager = (function()
    local UIS = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local GuiService = game:GetService("GuiService")
    local TweenService = game:GetService("TweenService")
    local GuiParent = (gethui and gethui()) or game:GetService("CoreGui")

    local Library = { Options = {}, Toggles = {}, Unloaded = false }
    local Options, Toggles = Library.Options, Library.Toggles
    local unloadFns, conns, keyObjs = {}, {}, {}
    local capturing, activeDrag, popup, popupOwner, mainFrame, mainScale
    local menuOpen = false

    local BG, BG2, BG3 = Color3.fromRGB(16, 16, 20), Color3.fromRGB(24, 24, 30), Color3.fromRGB(40, 40, 52)
    local ACCENT, TXT, DIM = Color3.fromRGB(88, 101, 242), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
    local FONT = Enum.Font.Code
    local MB1, TOUCH = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch

    local animStates = setmetatable({}, { __mode = "k" })
    local themeRoots, themeFns = {}, {}
    Library.Theme = { BG = BG, BG2 = BG2, BG3 = BG3, ACCENT = ACCENT, TXT = TXT, DIM = DIM }

    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function corner(parent, r)
        return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, parent)
    end
    local function tween(o, t, props, style, dir)
        local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end
    local function lighten(c) return c:Lerp(Color3.new(1, 1, 1), 0.12) end
    local function darken(c) return c:Lerp(Color3.new(0, 0, 0), 0.22) end

    local function animate(btn, base)
        local st = { base = base or btn.BackgroundColor3, hover = false }
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = st.base
        local sc = new("UIScale", { Scale = 1 }, btn)
        local function rest() return st.hover and lighten(st.base) or st.base end
        local function show(c, t) tween(btn, t or 0.12, { BackgroundColor3 = c }) end
        btn.MouseEnter:Connect(function() st.hover = true show(rest()) end)
        btn.MouseLeave:Connect(function()
            st.hover = false
            show(rest())
            tween(sc, 0.15, { Scale = 1 })
        end)
        btn.MouseButton1Down:Connect(function()
            show(darken(st.base), 0.06)
            tween(sc, 0.08, { Scale = 0.95 })
        end)
        btn.MouseButton1Up:Connect(function()
            show(rest())
            tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
        end)
        st.set = function(c)
            st.base = c
            show(rest())
        end
        animStates[btn] = st
        return st
    end

    Library.Tween = tween
    Library.Animate = animate

    local function fire(list, ...)
        for _, f in ipairs(list) do pcall(f, ...) end
    end
    local function round(v, r)
        if r and r > 0 then
            local m = 10 ^ r
            return math.floor(v * m + 0.5) / m
        end
        return math.floor(v + 0.5)
    end
    local function keyName(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
        if t == MB1 then return "MB1" end
        if t == Enum.UserInputType.MouseButton2 then return "MB2" end
        if t == Enum.UserInputType.MouseButton3 then return "MB3" end
    end
    local function text(parent, props)
        props.BackgroundTransparency = 1
        props.TextColor3 = props.TextColor3 or TXT
        props.Font = FONT
        props.TextSize = props.TextSize or 13
        props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
        return new("TextLabel", props, parent)
    end

    local function pointer(inp)
        if inp and inp.UserInputType == TOUCH then
            return inp.Position.X, inp.Position.Y + GuiService:GetGuiInset().Y
        end
        local m = UIS:GetMouseLocation()
        return m.X, m.Y
    end
    local function toHex(c)
        return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
    end

    local gui = new("ScreenGui", {
        Name = "FwSerialUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100, IgnoreGuiInset = true,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = GuiParent
    table.insert(themeRoots, gui)

    setmetatable(Library, { __index = function(_, k)
        if k == "Toggled" then return menuOpen or capturing ~= nil end
    end })

    function Library:IsCapturing() return capturing ~= nil end

    local ROLE_KEYS = { "BG", "BG2", "BG3", "ACCENT", "TXT", "DIM" }
    function Library:AddThemeRoot(inst) table.insert(themeRoots, inst) end
    function Library:OnTheme(f) table.insert(themeFns, f) end
    function Library:ApplyTheme(t)
        local list = {}
        for _, k in ipairs(ROLE_KEYS) do
            local old, new_ = Library.Theme[k], t[k]
            if new_ and old ~= new_ then table.insert(list, { old, new_ }) end
        end
        local function remap(c)
            for _, p in ipairs(list) do
                if c == p[1] then return p[2] end
            end
        end
        local function fix(d)
            if d.Name == "NoTheme" then return end
            if d:IsA("GuiObject") then
                local n = remap(d.BackgroundColor3)
                if n then d.BackgroundColor3 = n end
            end
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                local n = remap(d.TextColor3)
                if n then d.TextColor3 = n end
                if d:IsA("TextBox") then
                    local pc = remap(d.PlaceholderColor3)
                    if pc then d.PlaceholderColor3 = pc end
                end
            elseif d:IsA("UIStroke") then
                local n = remap(d.Color)
                if n then d.Color = n end
            end
        end
        for _, root in ipairs(themeRoots) do
            if root.Parent then
                fix(root)
                for _, d in ipairs(root:GetDescendants()) do fix(d) end
            end
        end
        for _, k in ipairs(ROLE_KEYS) do
            if t[k] then Library.Theme[k] = t[k] end
        end
        local T = Library.Theme
        BG, BG2, BG3, ACCENT, TXT, DIM = T.BG, T.BG2, T.BG3, T.ACCENT, T.TXT, T.DIM
        for btn, st in pairs(animStates) do
            local n = remap(st.base)
            if n then st.base = n end
            if btn.Parent then btn.BackgroundColor3 = st.hover and lighten(st.base) or st.base end
        end
        fire(themeFns, T)
    end

    table.insert(conns, UIS.InputChanged:Connect(function(i)
        if activeDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == TOUCH) then
            activeDrag(i.Position.X, i.Position.Y, i)
        end
    end))
    table.insert(conns, UIS.InputEnded:Connect(function(i)
        if i.UserInputType == MB1 or i.UserInputType == TOUCH then activeDrag = nil end
    end))

    function Library:Toggle()
        if not mainFrame then return end
        menuOpen = not menuOpen
        if popup then popup:Destroy() popup = nil popupOwner = nil end
        if menuOpen then
            mainFrame.Visible = true
            tween(mainFrame, 0.2, { GroupTransparency = 0 })
            tween(mainScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
        else
            tween(mainFrame, 0.16, { GroupTransparency = 1 })
            local tw = tween(mainScale, 0.18, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tw.Completed:Connect(function()
                if not menuOpen and mainFrame then mainFrame.Visible = false end
            end)
        end
    end

    local function finishCapture(o, name)
        if o._done then return end
        o._done = true
        o.Value = name
        o:_refresh()
        fire(o.Changed, name)
        task.delay(0.15, function()
            if capturing == o then capturing = nil end
            o._done = nil
            o:_refresh()
        end)
    end

    local EXTRA_BUTTONS = { MB3 = 0x04, MB4 = 0x05, MB5 = 0x06 }
    table.insert(conns, game:GetService("RunService").RenderStepped:Connect(function()
        if not capturing or capturing._done or not iskeypressed then return end
        for name, vk in pairs(EXTRA_BUTTONS) do
            local ok, down = pcall(iskeypressed, vk)
            if ok and down == true then
                finishCapture(capturing, name)
                return
            end
        end
    end))

    table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
        if Library.Unloaded then return end
        if capturing then
            local o = capturing
            if o._done then return end
            local name = keyName(input)
            if input.KeyCode == Enum.KeyCode.Escape then
                name = "None"
            elseif not name or processed then
                return
            end
            finishCapture(o, name)
            return
        end

        local mk = Options.MenuKeybind
        local bound = (mk and mk.Value) or "End"
        if bound ~= "None" and UIS:GetFocusedTextBox() == nil and keyName(input) == bound then
            Library:Toggle()
        end
    end))

    local toastHolder = new("Frame", {
        Size = UDim2.fromOffset(320, 400), Position = UDim2.new(1, -330, 0, 40), BackgroundTransparency = 1,
    }, gui)
    new("UIListLayout", { Padding = UDim.new(0, 5) }, toastHolder)

    function Library:Notify(msg, secs)
        if Library.Unloaded then return end
        local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, toastHolder)
        local l = text(holder, {
            Size = UDim2.new(1, 0, 1, 0), Position = UDim2.fromOffset(350, 0), BackgroundColor3 = BG2,
            Text = "  " .. tostring(msg), BorderSizePixel = 0,
        })
        l.BackgroundTransparency = 0.1
        corner(l, 8)
        new("UIStroke", { Color = ACCENT, Transparency = 0.5 }, l)
        tween(l, 0.35, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
        task.delay(secs or 3, function()
            if not l.Parent then return end
            local tw = tween(l, 0.25, { Position = UDim2.fromOffset(350, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tw.Completed:Connect(function() holder:Destroy() end)
        end)
    end

    local wm = text(gui, {
        Size = UDim2.fromOffset(260, 20), Position = UDim2.new(1, -270, 0, 8), Visible = false,
        TextXAlignment = Enum.TextXAlignment.Right, Text = "",
    })
    function Library:SetWatermark(t) wm.Text = tostring(t) end
    function Library:SetWatermarkVisibility(v) wm.Visible = v and true or false end

    local kbFrame = new("Frame", {
        Size = UDim2.fromOffset(200, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(8, 120),
        BackgroundColor3 = BG2, BackgroundTransparency = 0.15, BorderSizePixel = 0, Visible = false,
    }, gui)
    corner(kbFrame, 8)
    local kbLabel = text(kbFrame, {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = "", TextWrapped = true,
    })
    new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, kbFrame)
    Library.KeybindFrame = kbFrame
    local function refreshKeyList()
        local lines = { "Keybinds" }
        for _, o in ipairs(keyObjs) do
            if o.Value ~= "None" and o.Text ~= "" then table.insert(lines, o.Text .. " [" .. o.Value .. "]") end
        end
        kbLabel.Text = table.concat(lines, "\n")
    end
    refreshKeyList()

    function Library:OnUnload(f) table.insert(unloadFns, f) end
    function Library:Unload()
        if Library.Unloaded then return end
        Library.Unloaded = true
        for _, f in ipairs(unloadFns) do pcall(f) end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    local function makeAddonBar(r)
        local bar = r:FindFirstChild("Addons")
        if bar then return bar end
        bar = new("Frame", {
            Name = "Addons", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, ZIndex = 5,
        }, r)
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4),
        }, bar)
        return bar
    end

    local function addKeyPicker(r, idx, info)
        info = info or {}
        local bar = makeAddonBar(r)
        local o = {
            Type = "KeyPicker", Value = info.Default or "None", Mode = info.Mode or "Toggle",
            Text = info.Text or idx, Changed = {},
        }
        local b = new("TextButton", {
            Size = UDim2.fromOffset(64, 16), BackgroundColor3 = BG3, BorderSizePixel = 0, Font = FONT,
            TextSize = 11, TextColor3 = DIM, Text = "[None]", ZIndex = 6,
        }, bar)
        corner(b, 5)
        animate(b, BG3)
        function o:_refresh()
            b.Text = (capturing == o and not o._done) and "[...]" or ("[" .. tostring(o.Value) .. "]")
            refreshKeyList()
        end
        function o:OnChanged(f) table.insert(self.Changed, f) end
        function o:SetValue(data)
            if type(data) == "table" then
                self.Value = data[1] or "None"
                if data[2] then self.Mode = data[2] end
            end
            self:_refresh()
            fire(self.Changed, self.Value)
        end
        function o:GetState() return false end
        b.MouseButton1Click:Connect(function()
            if capturing and capturing ~= o then
                local old = capturing
                capturing = nil
                old:_refresh()
            end
            capturing = o
            o._done = nil
            o:_refresh()
        end)
        Options[idx] = o
        table.insert(keyObjs, o)
        o:_refresh()
        return o
    end

    local PALETTE = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 222), Color3.fromRGB(160, 160, 170), Color3.fromRGB(110, 110, 120),
        Color3.fromRGB(0, 0, 0), Color3.fromRGB(10, 30, 60), Color3.fromRGB(0, 102, 204), Color3.fromRGB(110, 200, 235),
        Color3.fromRGB(50, 205, 205), Color3.fromRGB(50, 140, 100), Color3.fromRGB(40, 200, 70), Color3.fromRGB(255, 215, 0),
        Color3.fromRGB(255, 140, 20), Color3.fromRGB(240, 65, 55), Color3.fromRGB(130, 20, 75), Color3.fromRGB(240, 60, 190),
        Color3.fromRGB(170, 50, 200), Color3.fromRGB(90, 70, 220), Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 255, 160),
        Color3.fromRGB(255, 255, 120), Color3.fromRGB(255, 180, 120), Color3.fromRGB(120, 180, 255), Color3.fromRGB(200, 150, 255),
    }

    local function addColorPicker(r, idx, info)
        info = info or {}
        local bar = makeAddonBar(r)
        local o = { Type = "ColorPicker", Value = info.Default or Color3.new(1, 1, 1), Changed = {} }
        local H, S, V = o.Value:ToHSV()
        local ui

        local sw = new("TextButton", {
            Name = "NoTheme", Size = UDim2.fromOffset(24, 14), BackgroundColor3 = o.Value, BorderSizePixel = 0, Text = "", ZIndex = 6,
            AutoButtonColor = false,
        }, bar)
        corner(sw, 5)
        local swScale = new("UIScale", {}, sw)
        sw.MouseEnter:Connect(function() tween(swScale, 0.12, { Scale = 1.12 }) end)
        sw.MouseLeave:Connect(function() tween(swScale, 0.12, { Scale = 1 }) end)

        local function refreshUI()
            if not ui or not ui.root.Parent then return end
            ui.sv.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            ui.cursor.Position = UDim2.fromScale(S, 1 - V)
            ui.hueKnob.Position = UDim2.fromScale(H, 0.5)
            ui.hueKnob.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            if not ui.hex:IsFocused() then ui.hex.Text = toHex(o.Value) end
        end
        local function apply(h, s, v, exact)
            H, S, V = h, s, v
            o.Value = exact or Color3.fromHSV(h, s, v)
            sw.BackgroundColor3 = o.Value
            refreshUI()
            fire(o.Changed, o.Value)
        end
        function o:SetValue(c)
            local h, s, v = c:ToHSV()
            if s == 0 or v == 0 then h = H end
            apply(h, s, v, c)
        end
        function o:OnChanged(f) table.insert(self.Changed, f) end

        local function openPopup()
            local W, HH = 210, 290
            local abs, scr = sw.AbsolutePosition, gui.AbsoluteSize
            local px = math.clamp(abs.X - W + 30, 4, math.max(scr.X - W - 4, 4))
            local py = math.clamp(abs.Y + 20, 4, math.max(scr.Y - HH - 4, 4))
            local root = new("Frame", {
                Size = UDim2.fromOffset(W, HH), BackgroundColor3 = BG2, BorderSizePixel = 0, ZIndex = 60,
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(px + W / 2, py + HH / 2),
            }, gui)
            corner(root, 12)
            new("UIStroke", { Color = ACCENT }, root)
            local pop = new("UIScale", { Scale = 0.85 }, root)
            tween(pop, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
            popup, popupOwner = root, o
            ui = { root = root }

            local sv = new("Frame", {
                Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 120),
                BackgroundColor3 = Color3.fromHSV(H, 1, 1), BorderSizePixel = 0, ZIndex = 61,
            }, root)
            corner(sv, 8)
            local white = new("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 62,
            }, sv)
            corner(white, 8)
            new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)
            local black = new("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 63,
            }, sv)
            corner(black, 8)
            new("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }, black)

            local cursor = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
                BorderSizePixel = 0, ZIndex = 64, Position = UDim2.fromScale(S, 1 - V),
            }, sv)
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, cursor)
            new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, cursor)
            local cursorShadow = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20),
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 64,
            }, cursor)
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, cursorShadow)
            new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.5 }, cursorShadow)

            local svCatch = new("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 66,
            }, sv)

            local hue = new("Frame", {
                Position = UDim2.fromOffset(8, 138), Size = UDim2.new(1, -16, 0, 12),
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 61,
            }, root)
            new("UICorner", { CornerRadius = UDim.new(0, 6) }, hue)
            local seq = {}
            for i = 0, 6 do
                table.insert(seq, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(math.min(i / 6, 1), 1, 1)))
            end
            new("UIGradient", { Color = ColorSequence.new(seq) }, hue)
            local hueKnob = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0, ZIndex = 64,
                Position = UDim2.fromScale(H, 0.5), BackgroundColor3 = Color3.fromHSV(H, 1, 1),
            }, hue)
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, hueKnob)
            new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, hueKnob)
            local hueCatch = new("TextButton", {
                Position = UDim2.fromOffset(0, -5), Size = UDim2.new(1, 0, 1, 10), BackgroundTransparency = 1, Text = "",
                AutoButtonColor = false, ZIndex = 66,
            }, hue)

            local hex = new("TextBox", {
                Position = UDim2.fromOffset(8, 162), Size = UDim2.new(1, -70, 0, 26), BackgroundColor3 = BG3,
                BorderSizePixel = 0, Font = FONT, TextSize = 14, TextColor3 = TXT, ClearTextOnFocus = false,
                Text = toHex(o.Value), ZIndex = 61,
            }, root)
            corner(hex, 8)
            local ok = new("TextButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 162), Size = UDim2.fromOffset(46, 26),
                BackgroundColor3 = ACCENT, BorderSizePixel = 0, Font = FONT, TextSize = 13, Text = "OK",
                TextColor3 = Color3.new(1, 1, 1), ZIndex = 61,
            }, root)
            corner(ok, 8)
            animate(ok, ACCENT)

            text(root, { Position = UDim2.fromOffset(10, 194), Size = UDim2.new(1, -20, 0, 14), Text = "Color palette", TextSize = 11, TextColor3 = DIM, ZIndex = 61 })

            ui.sv, ui.cursor, ui.hueKnob, ui.hex = sv, cursor, hueKnob, hex

            local gap = ((W - 16) - 8 * 20) / 7
            for i, c in ipairs(PALETTE) do
                local row, colm = math.floor((i - 1) / 8), (i - 1) % 8
                local b = new("TextButton", {
                    Position = UDim2.fromOffset(8 + colm * (20 + gap), 212 + row * 24), Size = UDim2.fromOffset(20, 20),
                    Name = "NoTheme", BackgroundColor3 = c, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 61,
                }, root)
                corner(b, 6)
                new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.75 }, b)
                local bs = new("UIScale", {}, b)
                b.MouseEnter:Connect(function() tween(bs, 0.12, { Scale = 1.15 }) end)
                b.MouseLeave:Connect(function() tween(bs, 0.12, { Scale = 1 }) end)
                b.MouseButton1Click:Connect(function() o:SetValue(c) end)
            end

            local function svSet(i)
                local pxx, pyy = pointer(i)
                local a, s = sv.AbsolutePosition, sv.AbsoluteSize
                apply(H, math.clamp((pxx - a.X) / s.X, 0, 1), 1 - math.clamp((pyy - a.Y) / s.Y, 0, 1))
            end
            svCatch.InputBegan:Connect(function(inp)
                if inp.UserInputType == MB1 or inp.UserInputType == TOUCH then
                    svSet(inp)
                    activeDrag = function(_, _, i) svSet(i or inp) end
                end
            end)
            local function hueSet(i)
                local pxx = pointer(i)
                local a, s = hue.AbsolutePosition, hue.AbsoluteSize
                apply(math.clamp((pxx - a.X) / s.X, 0, 1), S, V)
            end
            hueCatch.InputBegan:Connect(function(inp)
                if inp.UserInputType == MB1 or inp.UserInputType == TOUCH then
                    hueSet(inp)
                    activeDrag = function(_, _, i) hueSet(i or inp) end
                end
            end)
            hex.FocusLost:Connect(function()
                local rr, gg, bb = hex.Text:match("^#?(%x%x)(%x%x)(%x%x)$")
                if rr then
                    o:SetValue(Color3.fromRGB(tonumber(rr, 16), tonumber(gg, 16), tonumber(bb, 16)))
                else
                    refreshUI()
                end
            end)
            ok.MouseButton1Click:Connect(function()
                if popup == root then popup, popupOwner = nil, nil end
                local tw = tween(pop, 0.15, { Scale = 0.85 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                tw.Completed:Connect(function() root:Destroy() end)
            end)
            refreshUI()
        end

        sw.MouseButton1Click:Connect(function()
            if popup then
                local same = (popupOwner == o)
                popup:Destroy()
                popup, popupOwner = nil, nil
                if same then return end
            end
            openPopup()
        end)
        Options[idx] = o
        return o
    end

    local function makeGroupbox(col, name)
        local box = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = BG2, BorderSizePixel = 0,
        }, col)
        corner(box, 10)
        new("UIStroke", { Color = BG3 }, box)
        new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, box)
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8),
        }, box)
        text(box, { Size = UDim2.new(1, 0, 0, 16), Text = name, TextColor3 = ACCENT, LayoutOrder = 0 })

        local order = 0
        local g = {}
        local function row(h)
            order += 1
            return new("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, LayoutOrder = order }, box)
        end

        function g:AddToggle(idx, info)
            info = info or {}
            local r = row(22)
            local cb = new("Frame", {
                Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = BG3, BorderSizePixel = 0,
            }, r)
            corner(cb, 4)
            local cbScale = new("UIScale", {}, cb)
            local label = text(r, { Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -22, 1, 0), Text = info.Text or idx })
            local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 2 }, r)
            local o = { Type = "Toggle", Value = info.Default == true, Changed = {} }
            cb.BackgroundColor3 = o.Value and ACCENT or BG3
            local function paint(pop)
                tween(cb, 0.15, { BackgroundColor3 = o.Value and ACCENT or BG3 })
                if pop then
                    cbScale.Scale = 1.3
                    tween(cbScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
                end
            end
            function o:SetValue(v)
                v = v and true or false
                if self.Value == v then return end
                self.Value = v
                paint(true)
                fire(self.Changed, v)
            end
            function o:OnChanged(f) table.insert(self.Changed, f) end
            function o:AddKeyPicker(i, inf) return addKeyPicker(r, i, inf) end
            function o:AddColorPicker(i, inf) return addColorPicker(r, i, inf) end
            btn.MouseButton1Click:Connect(function() o:SetValue(not o.Value) end)
            btn.MouseEnter:Connect(function() tween(label, 0.12, { TextColor3 = Color3.new(1, 1, 1) }) end)
            btn.MouseLeave:Connect(function() tween(label, 0.12, { TextColor3 = TXT }) end)
            Toggles[idx] = o
            return o
        end

        function g:AddSlider(idx, info)
            info = info or {}
            local r = row(34)
            local lab = text(r, { Size = UDim2.new(1, 0, 0, 16) })
            local bar = new("Frame", {
                Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = BG3, BorderSizePixel = 0,
            }, r)
            corner(bar, 6)
            local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = ACCENT, BorderSizePixel = 0 }, bar)
            corner(fill, 6)
            local o = {
                Type = "Slider", Min = info.Min or 0, Max = info.Max or 100, Rounding = info.Rounding or 0,
                Value = info.Default or info.Min or 0, Changed = {},
            }
            local function render()
                lab.Text = (info.Text or idx) .. ": " .. tostring(o.Value) .. (info.Suffix or "")
                tween(fill, 0.08, { Size = UDim2.new((o.Value - o.Min) / math.max(o.Max - o.Min, 1e-9), 0, 1, 0) })
            end
            function o:SetValue(v)
                v = math.clamp(round(v, self.Rounding), self.Min, self.Max)
                if v == self.Value then render() return end
                self.Value = v
                render()
                fire(self.Changed, v)
            end
            function o:OnChanged(f) table.insert(self.Changed, f) end
            bar.InputBegan:Connect(function(i)
                if i.UserInputType == MB1 or i.UserInputType == TOUCH then
                    local function set(x)
                        o:SetValue(o.Min + (o.Max - o.Min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1))
                    end
                    set(i.Position.X)
                    activeDrag = function(x) set(x) end
                end
            end)
            render()
            Options[idx] = o
            return o
        end

        function g:AddDropdown(idx, info)
            info = info or {}
            order += 1
            local r = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order,
            }, box)
            new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, r)
            text(r, { Size = UDim2.new(1, 0, 0, 16), Text = info.Text or idx, LayoutOrder = 1 })
            local btn = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = BG3, BorderSizePixel = 0, Font = FONT, TextSize = 12,
                TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Text = "",
            }, r)
            corner(btn, 7)
            animate(btn, BG3)
            new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, btn)
            local list = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = BG, BorderSizePixel = 0,
                LayoutOrder = 3, Visible = false,
            }, r)
            corner(list, 7)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)

            local o = { Type = "Dropdown", Values = info.Values or {}, Multi = info.Multi == true, Changed = {} }
            if o.Multi then
                o.Value = {}
                local d = info.Default
                if type(d) == "number" and d > 0 and o.Values[d] then o.Value[o.Values[d]] = true end
                if type(d) == "table" then for _, n in ipairs(d) do o.Value[n] = true end end
            else
                local d = info.Default
                if type(d) == "string" then o.Value = d else o.Value = o.Values[d or 1] end
            end

            local function label()
                if o.Multi then
                    local sel = {}
                    for _, v in ipairs(o.Values) do if o.Value[v] then table.insert(sel, v) end end
                    btn.Text = #sel > 0 and table.concat(sel, ", ") or "None"
                else
                    btn.Text = o.Value ~= nil and tostring(o.Value) or "None"
                end
            end
            local function build()
                for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for i, v in ipairs(o.Values) do
                    local ob = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = BG, BorderSizePixel = 0, Font = FONT, TextSize = 12,
                        Text = " " .. tostring(v), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i,
                        TextColor3 = ((o.Multi and o.Value[v]) or (not o.Multi and o.Value == v)) and ACCENT or TXT,
                    }, list)
                    corner(ob, 6)
                    animate(ob, BG)
                    ob.MouseButton1Click:Connect(function()
                        if o.Multi then
                            local d = {}
                            for k, val in pairs(o.Value) do d[k] = val end
                            d[v] = (not d[v]) or nil
                            o:SetValue(d)
                        else
                            o:SetValue(v)
                            list.Visible = false
                        end
                    end)
                end
            end
            local function fadeIn()
                local i = 0
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then
                        i += 1
                        c.TextTransparency = 1
                        task.delay((i - 1) * 0.025, function()
                            if c.Parent then tween(c, 0.15, { TextTransparency = 0 }) end
                        end)
                    end
                end
            end
            function o:SetValues(vals)
                self.Values = vals
                build()
                label()
            end
            function o:SetValue(v)
                if self.Multi then
                    local d = {}
                    if type(v) == "table" then for k, val in pairs(v) do if val then d[k] = true end end end
                    self.Value = d
                else
                    if type(v) == "number" then v = self.Values[v] end
                    self.Value = v
                end
                build()
                label()
                fire(self.Changed, self.Value)
            end
            function o:OnChanged(f) table.insert(self.Changed, f) end
            btn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
                if list.Visible then fadeIn() end
            end)
            build()
            label()
            Options[idx] = o
            return o
        end

        function g:AddLabel(txt, wrap)
            local r
            if wrap then
                order += 1
                r = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order }, box)
            else
                r = row(22)
            end
            local t = text(r, {
                Size = UDim2.new(1, 0, 0, wrap and 0 or 22), AutomaticSize = wrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
                TextWrapped = wrap == true, Text = txt, TextColor3 = wrap and DIM or TXT,
            })
            local l = {}
            function l:SetText(s) t.Text = tostring(s) end
            function l:AddColorPicker(i, inf) return addColorPicker(r, i, inf) end
            function l:AddKeyPicker(i, inf) return addKeyPicker(r, i, inf) end
            return l
        end

        function g:AddButton(a, b)
            local label, fn
            if type(a) == "table" then label, fn = a.Text, a.Func else label, fn = a, b end
            local r = row(28)
            local btn = new("TextButton", {
                Size = UDim2.new(1, 0, 1, -2), BackgroundColor3 = BG3, BorderSizePixel = 0, Font = FONT, TextSize = 12,
                TextColor3 = TXT, Text = tostring(label),
            }, r)
            corner(btn, 8)
            animate(btn, BG3)
            btn.MouseButton1Click:Connect(function() if fn then task.spawn(fn) end end)
            return {}
        end

        function g:AddInput(idx, info)
            info = info or {}
            local r = row(44)
            text(r, { Size = UDim2.new(1, 0, 0, 16), Text = info.Text or idx })
            local tb = new("TextBox", {
                Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = BG3, BorderSizePixel = 0,
                Font = FONT, TextSize = 12, TextColor3 = TXT, Text = info.Default or "", ClearTextOnFocus = false,
                PlaceholderText = info.Placeholder or "", TextXAlignment = Enum.TextXAlignment.Left,
            }, r)
            corner(tb, 7)
            new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, tb)
            local o = { Type = "Input", Value = tb.Text, Changed = {} }
            function o:SetValue(s)
                self.Value = tostring(s)
                tb.Text = self.Value
                fire(self.Changed, self.Value)
            end
            function o:OnChanged(f) table.insert(self.Changed, f) end
            tb.FocusLost:Connect(function()
                o.Value = tb.Text
                fire(o.Changed, o.Value)
            end)
            Options[idx] = o
            return o
        end

        function g:AddDivider()
            local r = row(5)
            new("Frame", { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = BG3, BorderSizePixel = 0 }, r)
        end

        return g
    end

    local Window = {}
    function Library:CreateWindow(info)
        info = info or {}
        local autoShow = info.AutoShow ~= false
        mainFrame = new("CanvasGroup", {
            Size = info.Size or UDim2.fromOffset(720, 520), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = BG, BorderSizePixel = 0,
            Visible = autoShow, GroupTransparency = 1,
        }, gui)
        new("UICorner", { CornerRadius = UDim.new(0, 16) }, mainFrame)
        new("UIStroke", { Color = ACCENT, Thickness = 1.5 }, mainFrame)
        mainScale = new("UIScale", { Scale = 0.9 }, mainFrame)
        menuOpen = autoShow
        if autoShow then
            tween(mainFrame, 0.3, { GroupTransparency = 0 })
            tween(mainScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
        end

        local title = text(mainFrame, {
            Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 30), BackgroundColor3 = BG2,
            Text = "  " .. (info.Title or "FwSerial") .. "   [END = hide / show]", TextSize = 14, Active = true,
        })
        title.BackgroundTransparency = 0
        corner(title, 10)
        title.InputBegan:Connect(function(i)
            if i.UserInputType == MB1 or i.UserInputType == TOUCH then
                local startMouse, startPos = i.Position, mainFrame.Position
                activeDrag = function(x, y)
                    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (x - startMouse.X),
                        startPos.Y.Scale, startPos.Y.Offset + (y - startMouse.Y))
                end
            end
        end)
        local close = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(24, 22),
            BackgroundColor3 = Color3.fromRGB(170, 50, 65), BorderSizePixel = 0, Text = "X", TextColor3 = Color3.new(1, 1, 1),
            Font = FONT, TextSize = 13,
        }, title)
        corner(close, 8)
        animate(close, Color3.fromRGB(170, 50, 65))
        close.MouseButton1Click:Connect(function() Library:Toggle() end)

        local side = new("Frame", {
            Position = UDim2.fromOffset(8, 46), Size = UDim2.new(0, 124, 1, -54), BackgroundColor3 = BG2, BorderSizePixel = 0,
        }, mainFrame)
        corner(side, 12)
        new("UIListLayout", { Padding = UDim.new(0, 4) }, side)
        new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, side)
        local content = new("Frame", {
            Position = UDim2.fromOffset(140, 46), Size = UDim2.new(1, -148, 1, -54), BackgroundTransparency = 1,
        }, mainFrame)

        local tabsList = {}
        local function selectTab(t)
            for _, x in ipairs(tabsList) do
                local on = (x == t)
                if on and not x._page.Visible then
                    x._page.Visible = true
                    x._page.Position = UDim2.fromOffset(22, 0)
                    tween(x._page, 0.3, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
                elseif not on then
                    x._page.Visible = false
                end
                x._st.set(on and ACCENT or BG3)
            end
            if popup then popup:Destroy() popup = nil popupOwner = nil end
        end

        function Window:AddTab(name)
            local tab = {}
            local b = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = BG3, BorderSizePixel = 0, Font = FONT, TextSize = 13,
                TextColor3 = TXT, Text = name,
            }, side)
            corner(b, 9)
            local st = animate(b, BG3)
            local page = new("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
                CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
            }, content)
            local cols = new("Frame", {
                Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            }, page)
            new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }, cols)
            local function column()
                local c = new("Frame", {
                    Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                }, cols)
                new("UIListLayout", { Padding = UDim.new(0, 8) }, c)
                return c
            end
            local left, right = column(), column()
            tab._btn, tab._page, tab._st = b, page, st
            function tab:AddLeftGroupbox(n) return makeGroupbox(left, n) end
            function tab:AddRightGroupbox(n) return makeGroupbox(right, n) end
            b.MouseButton1Click:Connect(function() selectTab(tab) end)
            table.insert(tabsList, tab)
            if #tabsList == 1 then selectTab(tab) end
            return tab
        end

        local openBtn = new("TextButton", {
            Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 8, 0.5, -18), BackgroundColor3 = ACCENT, BorderSizePixel = 0,
            Text = "FW", TextColor3 = Color3.new(1, 1, 1), Font = FONT, TextSize = 14, ZIndex = 20,
        }, gui)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, openBtn)
        new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.7 }, openBtn)
        animate(openBtn, ACCENT)

        local dragMoved = false
        openBtn.InputBegan:Connect(function(i)
            if i.UserInputType == MB1 or i.UserInputType == TOUCH then
                local sm = i.Position
                local sa = openBtn.AbsolutePosition
                dragMoved = false
                activeDrag = function(x, y)
                    local dx, dy = x - sm.X, y - sm.Y
                    if math.abs(dx) + math.abs(dy) > 6 then dragMoved = true end
                    if dragMoved then
                        local scr = gui.AbsoluteSize
                        openBtn.Position = UDim2.fromOffset(
                            math.clamp(sa.X + dx, 0, math.max(scr.X - 36, 0)),
                            math.clamp(sa.Y + dy, 0, math.max(scr.Y - 36, 0)))
                    end
                end
            end
        end)
        openBtn.MouseButton1Click:Connect(function()
            if dragMoved then dragMoved = false return end
            Library:Toggle()
        end)

        return Window
    end

    local SaveManager = { _folder = "FwSerial", _ignore = {} }
    function SaveManager:SetLibrary() end
    function SaveManager:IgnoreThemeSettings() end
    function SaveManager:SetIgnoreIndexes(l) for _, i in ipairs(l) do self._ignore[i] = true end end
    function SaveManager:SetFolder(f) self._folder = f end
    function SaveManager:_collect()
        local data = {}
        for idx, o in pairs(Toggles) do data[idx] = { t = "b", v = o.Value } end
        for idx, o in pairs(Options) do
            if o.Type ~= "KeyPicker" and not self._ignore[idx] and idx:sub(1, 8) ~= "FwConfig" then
                if o.Type == "ColorPicker" then data[idx] = { t = "c", v = { o.Value.R, o.Value.G, o.Value.B } }
                else data[idx] = { t = "v", v = o.Value } end
            end
        end
        return data
    end
    function SaveManager:Write(name)
        local folder = self._folder
        return pcall(function()
            if not isfolder("FwSerial") then makefolder("FwSerial") end
            if not isfolder(folder) then makefolder(folder) end
            writefile(folder .. "/" .. name .. ".json", HttpService:JSONEncode(self:_collect()))
        end)
    end
    function SaveManager:Read(name)
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(self._folder .. "/" .. name .. ".json")) end)
        if not ok or type(data) ~= "table" then return false end
        for idx, e in pairs(data) do
            pcall(function()
                if e.t == "b" and Toggles[idx] then Toggles[idx]:SetValue(e.v)
                elseif e.t == "c" and Options[idx] then Options[idx]:SetValue(Color3.new(e.v[1], e.v[2], e.v[3]))
                elseif e.t == "v" and Options[idx] then Options[idx]:SetValue(e.v) end
            end)
        end
        return true
    end
    function SaveManager:LoadAutoloadConfig()
        local marker = false
        pcall(function() marker = isfile("FwSerial/autoload_last.txt") end)
        if not marker then return end
        if self:Read("_last") then
            if Toggles.AutoLoadLast then Toggles.AutoLoadLast:SetValue(true) end
            Library:Notify("Loaded last settings", 3)
        end
    end
    function SaveManager:BuildConfigSection(tab)
        local g = tab:AddRightGroupbox("Configs")
        g:AddInput("FwConfigName", { Text = "Config name" })
        g:AddDropdown("FwConfigList", { Values = {}, Default = 0, Text = "Config list" })
        local folder = self._folder
        local function refresh()
            local names = {}
            pcall(function()
                for _, f in ipairs(listfiles(folder)) do
                    local n = tostring(f):match("([^/\\]+)%.json$")
                    if n and n:sub(1, 1) ~= "_" then table.insert(names, n) end
                end
            end)
            Options.FwConfigList:SetValues(names)
        end
        g:AddButton("Save config", function()
            local name = Options.FwConfigName.Value
            if name == "" then Library:Notify("Type a config name first.", 3) return end
            local ok = self:Write(name)
            Library:Notify(ok and ("Saved " .. name) or "Save failed (executor has no file functions?)", 3)
            refresh()
        end)
        g:AddButton("Load config", function()
            local name = Options.FwConfigName.Value
            if not self:Read(name) then Library:Notify("Could not load " .. tostring(name), 3) return end
            Library:Notify("Loaded " .. name, 3)
        end)
        g:AddButton("Refresh list", refresh)
        Options.FwConfigList:OnChanged(function()
            if Options.FwConfigList.Value then Options.FwConfigName:SetValue(Options.FwConfigList.Value) end
        end)
        refresh()
    end

    local ThemeManager = {}
    function ThemeManager:SetLibrary() end
    function ThemeManager:SetFolder() end
    function ThemeManager:ApplyToTab() end

    return Library, ThemeManager, SaveManager
end)()

local Options = Library.Options or getgenv().Options
local Toggles = Library.Toggles or getgenv().Toggles

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local HAS_MOUSEMOVE = mousemoverel ~= nil
local HAS_CLICK = mouse1click ~= nil
local IS_MM2 = (game.PlaceId == 142823291) or (game.GameId == 66654135)
local IS_TRIBES = (game.GameId == 72169370437173) or (game.PlaceId == 72169370437173)
local HAS_HOOKS = hookmetamethod ~= nil and getnamecallmethod ~= nil and checkcaller ~= nil
local GuiParent = (gethui and gethui()) or CoreGui

local Window = Library:CreateWindow({
    Title = 'FwSerial | HvH',
    Size = UDim2.fromOffset(760, 540),
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Troll = Window:AddTab('Troll'),
    Visuals = Window:AddTab('Visuals'),
    World = Window:AddTab('World'),
    MM2HVH = IS_MM2 and Window:AddTab('MM2HVH') or nil,
    Tribes = IS_TRIBES and Window:AddTab('Tribes 3v3') or nil,
    Whitelist = Window:AddTab('Whitelist'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

if IS_TRIBES then
    local TribesGroup = Tabs.Tribes:AddLeftGroupbox('Tribes 3v3')
    TribesGroup:AddLabel('coming in a bit devy... since im working for free like a slave i wont make all at once', true)
end

local function getChar(plr) return plr and plr.Character end
local function getHRP(plr)
    local c = getChar(plr)
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum(plr)
    local c = getChar(plr)
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function isAlive(plr)
    local h = getHum(plr)
    return h ~= nil and h.Health > 0
end

local friendCache = {}
local function cacheFriend(p)
    task.spawn(function()
        local ok, res = pcall(LocalPlayer.IsFriendsWith, LocalPlayer, p.UserId)
        friendCache[p] = ok and res or false
    end)
end

local function isWhitelisted(p)
    local wl = Options.Whitelist and Options.Whitelist.Value
    if wl and wl[p.Name] then return true end
    if Toggles.WLFriends and Toggles.WLFriends.Value and friendCache[p] then return true end
    return false
end

local function sameTeam(p)
    return p.Team ~= nil and p.Team == LocalPlayer.Team
end

local function playerFromInstance(inst)
    local cur = inst
    while cur and cur ~= workspace do
        local p = Players:GetPlayerFromCharacter(cur)
        if p then return p end
        cur = cur.Parent
    end
end

local hue = 0
local function col(key)
    if Toggles.RGBToggle.Value then return Color3.fromHSV(hue, 1, 1) end
    return Options[key].Value
end

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)
local errSeen = {}

local function traceback(e) return tostring(e) .. '\n' .. debug.traceback() end
local function safeCall(name, f, ...)
    local ok, err = xpcall(f, traceback, ...)
    if not ok and not errSeen[name] then
        errSeen[name] = true
        warn('[FwSerial] ' .. name .. ' error: ' .. tostring(err))
        Library:Notify(name .. ' error (see F9 console)', 10)
    end
end

local Kit = {}

function Kit.addPred(group, idx, label, default)
    local slider = group:AddSlider(idx, { Text = label, Default = default, Min = 0, Max = 1, Rounding = 3 })
    local box = group:AddInput(idx .. 'Box', { Text = label .. ' - type exact value (e.g. 0.126)', Default = tostring(default), Placeholder = '0.126' })
    box:OnChanged(function(v)
        local n = tonumber((tostring(v):gsub(',', '.')))
        if not n then
            box:SetValue(tostring(slider.Value))
            return
        end
        slider:SetValue(n)
        if tostring(slider.Value) ~= tostring(v) then box:SetValue(tostring(slider.Value)) end
    end)
    slider:OnChanged(function(v)
        if box.Value ~= tostring(v) then box:SetValue(tostring(v)) end
    end)
    return slider
end
do
    local g = Instance.new("ScreenGui")
    g.Name = "FwSerialOverlay"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = 98
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(g) end end)
    g.Parent = GuiParent
    Kit.gui = g
    Library:OnUnload(function() pcall(function() g:Destroy() end) end)

    function Kit.frame(parent, color, strokeColor, strokeThick, clear, round)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.BackgroundColor3 = color or WHITE
        f:SetAttribute("base", clear and 1 or 0)
        if clear then f.BackgroundTransparency = 1 end
        f.Visible = false
        if round then
            local uc = Instance.new("UICorner")
            uc.CornerRadius = UDim.new(1, 0)
            uc.Parent = f
        end
        local s
        if strokeColor then
            s = Instance.new("UIStroke")
            s.Color = strokeColor
            s.Thickness = strokeThick or 1
            s.Parent = f
        end
        f.Parent = parent
        return f, s
    end

    function Kit.text(parent, size)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Code
        t.TextSize = size
        t.TextColor3 = WHITE
        t.TextStrokeTransparency = 0
        t.Size = UDim2.fromOffset(220, size + 2)
        t.AnchorPoint = Vector2.new(0.5, 0)
        t.Visible = false
        t.Parent = parent
        return t
    end

    function Kit.rect(f, x, y, w, h)
        f.Rotation = 0
        f.AnchorPoint = Vector2.zero
        f.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
        f.Size = UDim2.fromOffset(math.max(math.floor(w + 0.5), 1), math.max(math.floor(h + 0.5), 1))
    end

    function Kit.line(f, a, b, thick)
        local d = b - a
        local mid = (a + b) / 2
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromOffset(mid.X, mid.Y)
        f.Size = UDim2.fromOffset(math.max(d.Magnitude, 1), thick)
        f.Rotation = math.deg(math.atan2(d.Y, d.X))
    end

    function Kit.ring(parent)
        return Kit.frame(parent, WHITE, WHITE, 1, true, true)
    end

    function Kit.setRing(f, stroke, on, radius, pos, color)
        f.Visible = on and true or false
        if on then
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.fromOffset(pos.X, pos.Y)
            f.Size = UDim2.fromOffset(radius * 2, radius * 2)
            stroke.Color = color
        end
    end

    function Kit.bright(c)
        return c:Lerp(BLACK, 1 - Options.ESPBrightness.Value / 100)
    end

    function Kit.fade(rec, vis)
        if vis >= 1 and rec.lastVis == 1 then return end
        rec.lastVis = vis
        local function one(o)
            if o:IsA("Frame") then
                local base = o:GetAttribute("base") or 0
                if base < 1 then o.BackgroundTransparency = 1 - (1 - base) * vis end
            elseif o:IsA("TextLabel") then
                o.TextTransparency = 1 - vis
                o.TextStrokeTransparency = 1 - vis
            elseif o:IsA("UIStroke") then
                o.Transparency = 1 - vis
            end
        end
        for _, f in ipairs(rec.all) do
            if f.Visible or vis >= 1 then
                one(f)
                for _, d in ipairs(f:GetDescendants()) do one(d) end
            end
        end
    end
end

local heldKeys = {}
local inputConns = {}
local keyPickers = {}
local selectedTargets = {}
local actionBinds = {}
local mm2Roles = {}
local lastRoleScan = 0
local inputBlocked, holdActive, pollKeyPickers

do
    local toggleBinds = {
        FlingKey = 'FlingToggle', AntiFlingKey = 'AntiFlingToggle', SpinKey = 'SpinToggle',
        SpeedKey = 'SpeedToggle', FlyKey = 'FlyToggle', NoclipKey = 'NoclipToggle',
        SilentKey = 'SilentToggle', ESPKey = 'ESPToggle', MM2ESPKey = 'MM2ESP',
        MM2GunESPKey = 'MM2GunESP', TargetMenuKey = 'TargetMenu',
    }

    local chatAt, chatVal = 0, false
    local function chatOpen()
        local now = os.clock()
        if now - chatAt < 0.05 then return chatVal end
        chatAt = now
        local v = UserInputService:GetFocusedTextBox() ~= nil
        if not v then
            local ok, focused = pcall(function()
                return game:GetService("TextChatService").ChatInputBarConfiguration.IsFocused
            end)
            v = ok and focused == true
        end
        chatVal = v
        return v
    end

    function inputBlocked()
        return Library:IsCapturing() or chatOpen()
    end

    local function inputName(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
        if t == Enum.UserInputType.MouseButton1 then return 'MB1' end
        if t == Enum.UserInputType.MouseButton2 then return 'MB2' end
        if t == Enum.UserInputType.MouseButton3 then return 'MB3' end
    end

    function holdActive(optName)
        if inputBlocked() then return false end
        local k = Options[optName].Value
        if k == 'None' then return true end
        return heldKeys[k] == true
    end

    function pollKeyPickers()
        for _, opt in ipairs(keyPickers) do
            if opt.Value == 'Escape' then opt:SetValue({ 'None', opt.Mode or 'Toggle' }) end
        end
    end

    local function onPress(name)
        heldKeys[name] = true

        if name == 'MB1' and Toggles.ClickTP and Toggles.ClickTP.Value
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local hrp = getHRP(LocalPlayer)
            if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
        end
        for keyOpt, toggleName in pairs(toggleBinds) do
            local opt, tg = Options[keyOpt], Toggles[toggleName]
            if opt and tg and opt.Value == name then tg:SetValue(not tg.Value) end
        end
        for keyOpt, fn in pairs(actionBinds) do
            local opt = Options[keyOpt]
            if opt and opt.Value == name then task.spawn(fn) end
        end
        if Options.AimbotKey and Options.AimKeyMode and Options.AimbotKey.Value == name
            and Options.AimKeyMode.Value == 'Toggle' and Toggles.AimbotToggle.Value and not Library.Toggled then
            heldKeys.AimLatch = not heldKeys.AimLatch
        end
    end

    local function onRelease(name)
        heldKeys[name] = nil
    end

    table.insert(inputConns, UserInputService.InputBegan:Connect(function(input, processed)
        if Library.Unloaded then return end
        if input.KeyCode == Enum.KeyCode.Escape then task.delay(0.05, pollKeyPickers) end
        local name = inputName(input)
        if not name or processed or inputBlocked() then return end
        onPress(name)
    end))

    table.insert(inputConns, UserInputService.InputEnded:Connect(function(input)
        local name = inputName(input)
        if name then onRelease(name) end
    end))

    if iskeypressed then
        local extraRaw = {}
        local extraVK = { MB3 = 0x04, MB4 = 0x05, MB5 = 0x06 }
        table.insert(inputConns, RunService.RenderStepped:Connect(function()
            if Library.Unloaded then return end
            if isrbxactive and not isrbxactive() then return end
            for name, vk in pairs(extraVK) do
                local ok, down = pcall(iskeypressed, vk)
                down = ok and down == true
                if down and not extraRaw[name] then
                    extraRaw[name] = true
                    if not inputBlocked() and not heldKeys[name] then onPress(name) end
                elseif not down and extraRaw[name] then
                    extraRaw[name] = false
                    onRelease(name)
                end
            end
        end))
    end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(part)
    local char = part.Parent
    local ignore = { getChar(LocalPlayer), Camera }
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    for _ = 1, 8 do
        rayParams.FilterDescendantsInstances = ignore
        local res = workspace:Raycast(origin, dir, rayParams)
        if not res then return true end
        local inst = res.Instance
        if inst:IsDescendantOf(char) then return true end
        if Toggles.WallIgnoreTrans.Value and (inst.Transparency >= 0.9 or not inst.CanCollide) then
            table.insert(ignore, inst)
        else
            return false
        end
    end
    return false
end

do
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Aimbot')

CombatGroup:AddToggle('AimbotToggle', { Text = 'Enable Aimbot', Default = false })
    :AddKeyPicker('AimbotKey', { Default = 'None', Mode = 'Hold', SyncToggleState = false, Text = 'Aimbot key', NoUI = true })
CombatGroup:AddDropdown('AimKeyMode', {
    Values = { 'Hold', 'Toggle' }, Default = 1, Multi = false, Text = 'Aimbot key mode',
    Tooltip = 'Hold = aim only while the key is held. Toggle = press the key to switch aimbot on / off.'
})
CombatGroup:AddDropdown('AimMode', {
    Values = { 'Camera', 'Cursor' }, Default = 1, Multi = false, Text = 'Aimbot type',
    Tooltip = 'Camera = rotates your camera. Cursor = moves your mouse (needs mousemoverel).'
})
CombatGroup:AddDropdown('AimPriority', { Values = { 'Closest to Cursor', 'Closest Distance' }, Default = 1, Multi = false, Text = 'Target priority' })
CombatGroup:AddDropdown('AimPart', { Values = { 'Head', 'HumanoidRootPart', 'UpperTorso', 'Torso', 'Random' }, Default = 1, Multi = false, Text = 'Target part' })
CombatGroup:AddToggle('AimWallCheck', { Text = 'Wall Check', Default = false })
CombatGroup:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = true })
CombatGroup:AddSlider('AimFOV', { Text = 'Aim FOV (pixels)', Default = 150, Min = 20, Max = 800, Rounding = 0 })
CombatGroup:AddSlider('AimSmooth', { Text = 'Smoothness (1 = instant)', Default = 1, Min = 1, Max = 20, Rounding = 0 })
Kit.addPred(CombatGroup, 'AimPredict', 'Prediction (seconds)', 0)

local SilentGroup = Tabs.Combat:AddRightGroupbox('Silent Aim')
SilentGroup:AddToggle('SilentToggle', { Text = 'Enable Silent Aim', Default = false,
    Tooltip = 'Redirects shots without moving your camera. Needs hookmetamethod.' })
    :AddKeyPicker('SilentKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Silent aim key', NoUI = true })
SilentGroup:AddDropdown('SilentMethods', {
    Values = { 'Mouse.Hit/Target', 'Raycast', 'FindPartOnRay', 'ScreenPointToRay' },
    Default = 0, Multi = true, Text = 'Hook methods',
    Tooltip = 'Enable the ones your game uses. If shots miss, try turning on more of them.'
})
SilentGroup:AddDropdown('SilentPart', { Values = { 'Head', 'HumanoidRootPart', 'UpperTorso', 'Torso', 'Random' }, Default = 1, Multi = false, Text = 'Silent target part' })
SilentGroup:AddToggle('SilentWall', { Text = 'Wall Check', Default = true })
SilentGroup:AddToggle('ShowSilentFOV', { Text = 'Show silent FOV circle', Default = true })
SilentGroup:AddSlider('SilentFOV', { Text = 'Silent FOV (pixels)', Default = 200, Min = 20, Max = 1000, Rounding = 0 })
SilentGroup:AddSlider('SilentHit', { Text = 'Hit chance', Default = 100, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Kit.addPred(SilentGroup, 'SilentPredict', 'Prediction (seconds)', 0)
Options.SilentMethods:SetValue({ ['Mouse.Hit/Target'] = true, Raycast = true, FindPartOnRay = true, ScreenPointToRay = true })

local FilterGroup = Tabs.Combat:AddLeftGroupbox('Target Filters (aimbot / silent / trigger)')
FilterGroup:AddToggle('TeamCheck', { Text = 'Team Check', Default = false })
FilterGroup:AddToggle('FFCheck', { Text = 'Ignore forcefielded players', Default = true })
FilterGroup:AddToggle('WallIgnoreTrans', { Text = 'Wall check sees through glass / non-collide', Default = true })

local TrigGroup = Tabs.Combat:AddRightGroupbox('Triggerbot / Hitbox')
TrigGroup:AddToggle('Trigger', { Text = 'Triggerbot', Default = false, Tooltip = 'Clicks when your cursor is over an enemy (needs mouse1click)' })
    :AddKeyPicker('TriggerKey', { Default = 'None', Mode = 'Always', SyncToggleState = false, Text = 'Triggerbot key', NoUI = true })
TrigGroup:AddSlider('TrigDelay', { Text = 'Delay between clicks (ms)', Default = 80, Min = 0, Max = 500, Rounding = 0 })
TrigGroup:AddToggle('HitboxToggle', { Text = 'Hitbox expander', Default = false, Tooltip = 'Only works on games that use client-side hit detection' })
TrigGroup:AddSlider('HitboxSize', { Text = 'Hitbox size', Default = 6, Min = 2, Max = 30, Rounding = 0 })
TrigGroup:AddSlider('HitboxAlpha', { Text = 'Hitbox transparency', Default = 70, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })

local CameraGroup = Tabs.Combat:AddRightGroupbox('Camera')
CameraGroup:AddSlider('FOVSlider', { Text = 'Camera FOV', Default = 70, Min = 50, Max = 120, Rounding = 0 })
Options.FOVSlider:OnChanged(function() Camera.FieldOfView = Options.FOVSlider.Value end)
end

local fovRing, fovStroke, silentRing, silentStroke
local validTarget, getTarget, runAimbot, runTrigger, restoreHitboxes, updateHitboxes
local silentTarget
local autoAimPos, autoAimPart

do
    fovRing, fovStroke = Kit.ring(Kit.gui)
    silentRing, silentStroke = Kit.ring(Kit.gui)

    local function pickPart(char, name)
        if name == 'Random' then
            name = (math.random() < 0.5) and 'Head' or 'HumanoidRootPart'
        end
        return char:FindFirstChild(name) or char:FindFirstChild("HumanoidRootPart")
    end

    function validTarget(p)
        if p == LocalPlayer or not isAlive(p) or isWhitelisted(p) then return false end
        if Toggles.TeamCheck.Value and sameTeam(p) then return false end
        if Toggles.FFCheck.Value and getChar(p):FindFirstChildOfClass("ForceField") then return false end
        return true
    end

    function getTarget(cfg)
        local mouse = UserInputService:GetMouseLocation()
        local camPos = Camera.CFrame.Position
        local best, bestScore
        for _, p in ipairs(Players:GetPlayers()) do
            if validTarget(p) then
                local part = pickPart(getChar(p), cfg.part)
                if part then
                    local v, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local d = (Vector2.new(v.X, v.Y) - mouse).Magnitude
                        if d <= cfg.fov and (not cfg.wall or isVisible(part)) then
                            local score = (cfg.priority == 'Closest Distance') and (part.Position - camPos).Magnitude or d
                            if not bestScore or score < bestScore then best, bestScore = part, score end
                        end
                    end
                end
            end
        end
        return best
    end

    local warnedMouse = false
    function runAimbot()
        local part = getTarget({
            fov = Options.AimFOV.Value, part = Options.AimPart.Value,
            wall = Toggles.AimWallCheck.Value, priority = Options.AimPriority.Value,
        })
        if not part then return end
        local aimPos = part.Position + part.AssemblyLinearVelocity * Options.AimPredict.Value

        if Options.AimMode.Value == 'Cursor' then
            if not HAS_MOUSEMOVE then
                if not warnedMouse then
                    warnedMouse = true
                    Library:Notify('Your executor has no mousemoverel, switch aimbot type to Camera.', 6)
                end
                return
            end
            local v = Camera:WorldToViewportPoint(aimPos)
            local delta = (Vector2.new(v.X, v.Y) - UserInputService:GetMouseLocation()) / Options.AimSmooth.Value
            mousemoverel(delta.X, delta.Y)
        else
            local goal = CFrame.new(Camera.CFrame.Position, aimPos)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 1 / Options.AimSmooth.Value)
        end
    end

    local function silentGate()
        if Library.Unloaded then return end
        if autoAimPos then return autoAimPos end
        if not Toggles.SilentToggle.Value then return end
        if inputBlocked() then return end
        local t = silentTarget
        if not t or not t.Parent then return end
        if math.random(1, 100) > Options.SilentHit.Value then return end
        return t.Position + t.AssemblyLinearVelocity * Options.SilentPredict.Value
    end

    if HAS_HOOKS then
        local wrap = newcclosure or function(f) return f end
        local ok, err = pcall(function()
            local oldIndex, oldNamecall

            oldIndex = hookmetamethod(game, "__index", wrap(function(self, key)
                if not checkcaller() and self == Mouse and (key == "Hit" or key == "Target")
                    and Options.SilentMethods.Value['Mouse.Hit/Target'] then
                    local pos = silentGate()
                    if pos then
                        if key == "Hit" then return CFrame.new(pos) end
                        return autoAimPart or silentTarget
                    end
                end
                return oldIndex(self, key)
            end))

            oldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
                local method = getnamecallmethod()
                if checkcaller() or Library.Unloaded then return oldNamecall(self, ...) end

                local m = Options.SilentMethods.Value
                local n = select('#', ...)
                local args = { ... }

                if self == workspace then
                    if method == "Raycast" and m.Raycast and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                        local pos = silentGate()
                        if pos then
                            args[2] = (pos - args[1]).Unit * args[2].Magnitude
                            return oldNamecall(self, unpack(args, 1, n))
                        end
                    elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist")
                        and m.FindPartOnRay and typeof(args[1]) == "Ray" then
                        local pos = silentGate()
                        if pos then
                            local r = args[1]
                            args[1] = Ray.new(r.Origin, (pos - r.Origin).Unit * r.Direction.Magnitude)
                            return oldNamecall(self, unpack(args, 1, n))
                        end
                    end
                elseif self == workspace.CurrentCamera and m.ScreenPointToRay
                    and (method == "ScreenPointToRay" or method == "ViewportPointToRay") then
                    local ray = oldNamecall(self, ...)
                    local pos = silentGate()
                    if pos then return Ray.new(ray.Origin, (pos - ray.Origin).Unit) end
                    return ray
                end

                return oldNamecall(self, ...)
            end))
        end)
        if not ok then
            Library:Notify('Silent aim hooks failed: ' .. tostring(err), 8)
        end
    else
        Library:Notify('Your executor lacks hookmetamethod/checkcaller, silent aim is unavailable.', 8)
    end

    local lastTrig = 0
    function runTrigger()
        if not HAS_CLICK then return end
        if os.clock() - lastTrig < Options.TrigDelay.Value / 1000 then return end
        local m = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(m.X, m.Y)
        rayParams.FilterDescendantsInstances = { getChar(LocalPlayer), Camera }
        local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
        if not res then return end
        local p = playerFromInstance(res.Instance)
        if p and validTarget(p) then
            lastTrig = os.clock()
            mouse1click()
        end
    end

    local hbOriginal = {}
    function restoreHitboxes()
        for hrp, o in pairs(hbOriginal) do
            if hrp.Parent then
                hrp.Size, hrp.Transparency, hrp.CanCollide = o[1], o[2], o[3]
            end
            hbOriginal[hrp] = nil
        end
    end

    function updateHitboxes()
        if not Toggles.HitboxToggle.Value then
            if next(hbOriginal) then restoreHitboxes() end
            return
        end
        local s = Options.HitboxSize.Value
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = getHRP(p)
                if hrp then
                    if validTarget(p) then
                        if not hbOriginal[hrp] then hbOriginal[hrp] = { hrp.Size, hrp.Transparency, hrp.CanCollide } end
                        hrp.Size = Vector3.new(s, s, s)
                        hrp.Transparency = Options.HitboxAlpha.Value / 100
                        hrp.CanCollide = false
                    elseif hbOriginal[hrp] then
                        local o = hbOriginal[hrp]
                        hrp.Size, hrp.Transparency, hrp.CanCollide = o[1], o[2], o[3]
                        hbOriginal[hrp] = nil
                    end
                end
            end
        end
    end
end

local flingTarget
local flingActive = false
local cooldown = {}
local knifeAbort = false
local specTarget
local startSpectate, stopSpectate, restoreCamera, updateSpectate
local forceStopFling, stopAllActions

do
local TrollGroup = Tabs.Troll:AddLeftGroupbox('Fling')

TrollGroup:AddToggle('FlingToggle', { Text = 'Fling', Default = false, Tooltip = 'Teleports inside targets at high velocity' })
    :AddKeyPicker('FlingKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Fling key', NoUI = true })
local flingModes = { 'Selected', 'Nearest', 'Closest to Cursor', 'Random' }
if IS_MM2 then table.insert(flingModes, 'Murderer') table.insert(flingModes, 'Sheriff') end
TrollGroup:AddDropdown('FlingTargetMode', { Values = flingModes, Default = 1, Multi = false, Text = 'Target selection', Tooltip = 'Selected = only players ticked in the Target Menu' })
TrollGroup:AddSlider('FlingPower', { Text = 'Power (x1000)', Default = 500, Min = 50, Max = 5000, Rounding = 0 })
TrollGroup:AddSlider('FlingTime', { Text = 'Max time per target (s)', Default = 2, Min = 1, Max = 15, Rounding = 0 })
TrollGroup:AddToggle('FlingReturn', { Text = 'Return to start after each target', Default = true })
TrollGroup:AddToggle('FlingSpectate', { Text = 'Camera follows target', Default = true })
TrollGroup:AddToggle('FlingNotify', { Text = 'Notify when a target is flung', Default = true })
TrollGroup:AddButton({
    Text = 'Sit On Nearest Head',
    Func = function()
        local hrp = getHRP(LocalPlayer)
        local best, bestD
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) and not isWhitelisted(p) and hrp and getHRP(p) then
                local d = (getHRP(p).Position - hrp.Position).Magnitude
                if not bestD or d < bestD then best, bestD = p, d end
            end
        end
        local head = best and getChar(best):FindFirstChild("Head")
        if hrp and head then hrp.CFrame = head.CFrame * CFrame.new(0, 1.5, 0) end
    end,
})
TrollGroup:AddButton({ Text = 'STOP everything (fling / spectate)', Func = function() stopAllActions() end })

local MoveGroup = Tabs.Troll:AddRightGroupbox('Movement / Defense')
MoveGroup:AddToggle('AntiFlingToggle', { Text = 'Anti-Fling (noclip players only)', Default = false })
    :AddKeyPicker('AntiFlingKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Anti-Fling key', NoUI = true })
MoveGroup:AddToggle('SpinToggle', { Text = 'Spinbot', Default = false })
    :AddKeyPicker('SpinKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Spinbot key', NoUI = true })
MoveGroup:AddSlider('SpinSpeed', { Text = 'Spin speed', Default = 50, Min = 5, Max = 180, Rounding = 0 })
MoveGroup:AddDivider()
MoveGroup:AddToggle('SpeedToggle', { Text = 'Speed (CFrame)', Default = false })
    :AddKeyPicker('SpeedKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Speed key', NoUI = true })
MoveGroup:AddSlider('SpeedValue', { Text = 'Speed', Default = 40, Min = 16, Max = 150, Rounding = 0 })
MoveGroup:AddToggle('FlyToggle', { Text = 'Fly', Default = false })
    :AddKeyPicker('FlyKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Fly key', NoUI = true })
MoveGroup:AddSlider('FlySpeed', { Text = 'Fly speed', Default = 60, Min = 10, Max = 120, Rounding = 0 })
MoveGroup:AddToggle('NoclipToggle', { Text = 'Noclip (walls too)', Default = false })
    :AddKeyPicker('NoclipKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Noclip key', NoUI = true })
MoveGroup:AddToggle('BhopToggle', { Text = 'Bunny hop (hold space)', Default = false })
MoveGroup:AddToggle('InfJump', { Text = 'Infinite jump', Default = false })
MoveGroup:AddToggle('ClickTP', { Text = 'Click TP (hold CTRL + click)', Default = false })

UserInputService.JumpRequest:Connect(function()
    if Library.Unloaded or not Toggles.InfJump.Value then return end
    local hum = getHum(LocalPlayer)
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

Toggles.FlyToggle:OnChanged(function()
    if not Toggles.FlyToggle.Value then
        local hrp = getHRP(LocalPlayer)
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
end)

local function pickFlingTarget()
    local myHRP = getHRP(LocalPlayer)
    if not myHRP then return end
    local mode = Options.FlingTargetMode.Value
    local mouse = UserInputService:GetMouseLocation()
    local best, bestScore
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) and not isWhitelisted(p) and (cooldown[p] or 0) < os.clock()
            and (mode ~= 'Selected' or selectedTargets[p.Name])
            and (mode ~= 'Murderer' or mm2Roles[p] == 'Murderer')
            and (mode ~= 'Sheriff' or mm2Roles[p] == 'Sheriff') then
            local hrp = getHRP(p)
            if hrp then
                local score
                if mode == 'Nearest' or mode == 'Selected' or mode == 'Murderer' or mode == 'Sheriff' then
                    score = (hrp.Position - myHRP.Position).Magnitude
                elseif mode == 'Closest to Cursor' then
                    local v, on = Camera:WorldToViewportPoint(hrp.Position)
                    score = on and (Vector2.new(v.X, v.Y) - mouse).Magnitude or math.huge
                else
                    score = math.random()
                end
                if score ~= math.huge and (not bestScore or score < bestScore) then best, bestScore = p, score end
            end
        end
    end
    return best
end

local flingRunning = false
local flingPinCF
local flingPinConn
local flingGen = 0
local flingSavedProps, flingPropsSaved = nil, false

local FLING_OFFSETS = {
    Vector3.new(0, 0, 0), Vector3.new(0, 1.6, 0), Vector3.new(0, -1.6, 0),
    Vector3.new(1.6, 0, 0), Vector3.new(-1.6, 0, 0), Vector3.new(0, 0, 1.6), Vector3.new(0, 0, -1.6),
}

local function calmCharacter(char)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.AssemblyLinearVelocity = Vector3.zero
            v.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function releaseFling()
    if flingPinConn then
        flingPinConn:Disconnect()
        flingPinConn = nil
    end
    flingActive, flingPinCF, flingTarget = false, nil, nil
    local char, hrp, hum = getChar(LocalPlayer), getHRP(LocalPlayer), getHum(LocalPlayer)
    if hrp then
        if flingPropsSaved then hrp.CustomPhysicalProperties = flingSavedProps end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    flingPropsSaved = false
    if char then calmCharacter(char) end
    if hum then hum.PlatformStand = false end
    if restoreCamera then restoreCamera() end
end

local function returnHome(home, gen)
    local char, hum = getChar(LocalPlayer), getHum(LocalPlayer)
    if not (char and home) then return end
    local t0 = os.clock()
    repeat
        local hrp = getHRP(LocalPlayer)
        if not hrp then break end
        hrp.CFrame = home + Vector3.new(0, 0.5, 0)
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        calmCharacter(char)
        RunService.Heartbeat:Wait()
    until os.clock() - t0 > 0.5 or (gen and gen ~= flingGen and Toggles.FlingToggle.Value)
end

local function flingPlayer(target, gen)
    local char, hrp, hum = getChar(LocalPlayer), getHRP(LocalPlayer), getHum(LocalPlayer)
    local tchar, thrp, thum = getChar(target), getHRP(target), getHum(target)
    if not (char and hrp and hum and tchar and thrp and thum) then return false end

    flingTarget = target
    if Toggles.FlingSpectate.Value then workspace.CurrentCamera.CameraSubject = thum end

    flingSavedProps, flingPropsSaved = hrp.CustomPhysicalProperties, true
    hrp.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 100, 100)
    hum.PlatformStand = true

    local power = 9e7 * (Options.FlingPower.Value / 500)
    local startPos = thrp.Position
    local flung, step, t0 = false, 0, os.clock()

    local function pin()
        if flingPinCF and hrp.Parent then
            hrp.CFrame = flingPinCF
            hrp.AssemblyLinearVelocity = Vector3.new(power, power * 10, power)
            hrp.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
    end
    flingPinConn = RunService.Stepped:Connect(pin)
    flingActive = true

    while Toggles.FlingToggle.Value and gen == flingGen and not Library.Unloaded
        and os.clock() - t0 < Options.FlingTime.Value do
        if not (hrp.Parent and hum.Parent) or hum.Health <= 0 then break end
        if getChar(target) ~= tchar or not thrp.Parent or thum.Health <= 0 then break end

        local vel = thrp.AssemblyLinearVelocity
        if vel.Magnitude > 350 or (thrp.Position - startPos).Magnitude > 150 then
            flung = true
            break
        end

        step = step % #FLING_OFFSETS + 1
        local lead = vel.Magnitude < 120 and vel * 0.08 or Vector3.zero
        flingPinCF = CFrame.new(thrp.Position + lead + FLING_OFFSETS[step]) * CFrame.Angles(math.rad(90 * (step % 4)), 0, 0)
        pin()
        RunService.Heartbeat:Wait()
    end

    releaseFling()
    return flung
end

local function flingLoop()
    if flingRunning then return end
    flingRunning = true
    local gen = flingGen
    local oldFall = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0 / 0
    local home

    local ok, err = pcall(function()
        local warned = false
        while Toggles.FlingToggle.Value and gen == flingGen and not Library.Unloaded do
            local hrp = getHRP(LocalPlayer)
            if hrp and isAlive(LocalPlayer) then
                if not home then home = hrp.CFrame end
                local target = pickFlingTarget()
                if target then
                    local flung = flingPlayer(target, gen)
                    cooldown[target] = os.clock() + (flung and 8 or 3)
                    if flung and Toggles.FlingNotify.Value then Library:Notify('Flung ' .. target.DisplayName, 2) end
                    if Toggles.FlingReturn.Value and gen == flingGen then returnHome(home, gen) end
                    task.wait(0.05)
                else
                    local mode = Options.FlingTargetMode.Value
                    if mode == 'Selected' and next(selectedTargets) == nil and not warned then
                        warned = true
                        Library:Notify('Fling: nobody selected. Open the Target Menu and pick targets.', 5)
                    end
                    task.wait(0.25)
                end
            else
                home = nil
                task.wait(0.3)
            end
        end
    end)

    releaseFling()
    workspace.FallenPartsDestroyHeight = oldFall
    if Toggles.FlingReturn.Value and home then pcall(returnHome, home) end
    flingRunning = false
    if not ok then
        Library:Notify('Fling error: ' .. tostring(err), 6)
        if Toggles.FlingToggle.Value then Toggles.FlingToggle:SetValue(false) end
    end
end

forceStopFling = function()
    flingGen += 1
    if Toggles.FlingToggle.Value then Toggles.FlingToggle:SetValue(false) end
    releaseFling()
end

Toggles.FlingToggle:OnChanged(function()
    flingGen += 1
    if Toggles.FlingToggle.Value then
        task.spawn(function()
            local t0 = os.clock()
            while flingRunning and os.clock() - t0 < 3 do task.wait() end
            if Toggles.FlingToggle.Value and not flingRunning then flingLoop() end
        end)
    else
        releaseFling()
    end
end)
end

do
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')
ESPGroup:AddToggle('ESPToggle', { Text = 'Enable ESP', Default = false })
    :AddKeyPicker('ESPKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'ESP key', NoUI = true })
ESPGroup:AddToggle('BoxESP', { Text = 'Box ESP', Default = true })
ESPGroup:AddDropdown('BoxStyle', { Values = { 'Full', 'Corner' }, Default = 1, Multi = false, Text = 'Box style' })
ESPGroup:AddToggle('FillBox', { Text = 'Filled box', Default = false })
ESPGroup:AddSlider('FillAlpha', { Text = 'Fill opacity', Default = 20, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })
ESPGroup:AddToggle('NameESP', { Text = 'Names', Default = true })
ESPGroup:AddToggle('DistESP', { Text = 'Distance', Default = true })
ESPGroup:AddToggle('HealthText', { Text = 'Health text', Default = false })
ESPGroup:AddToggle('ToolESP', { Text = 'Held tool', Default = false })
ESPGroup:AddToggle('HealthBar', { Text = 'Health bar', Default = true })
ESPGroup:AddToggle('SkeletonESP', { Text = 'Skeleton ESP', Default = false })
ESPGroup:AddToggle('HeadDot', { Text = 'Head dot', Default = false })
ESPGroup:AddToggle('LookESP', { Text = 'Look direction', Default = false })
ESPGroup:AddSlider('LookLen', { Text = 'Look line length', Default = 8, Min = 2, Max = 30, Rounding = 0 })
ESPGroup:AddToggle('Tracers', { Text = 'Tracers', Default = false })
ESPGroup:AddDropdown('TracerOrigin', { Values = { 'Bottom', 'Center', 'Cursor', 'Top' }, Default = 1, Multi = false, Text = 'Tracer origin' })
ESPGroup:AddToggle('Arrows', { Text = 'Off-screen arrows', Default = false })
ESPGroup:AddSlider('ArrowRadius', { Text = 'Arrow radius', Default = 200, Min = 50, Max = 500, Rounding = 0 })
ESPGroup:AddSlider('ArrowSize', { Text = 'Arrow size', Default = 14, Min = 6, Max = 40, Rounding = 0 })

local ColorGroup = Tabs.Visuals:AddRightGroupbox('Colors / Filters')
ColorGroup:AddToggle('RGBToggle', { Text = 'RGB mode (all visuals)', Default = false })
ColorGroup:AddSlider('RGBSpeed', { Text = 'RGB speed', Default = 10, Min = 1, Max = 60, Rounding = 0 })
ColorGroup:AddSlider('ESPBrightness', { Text = 'ESP brightness (all ESP)', Default = 100, Min = 10, Max = 100, Rounding = 0, Suffix = '%' })
ColorGroup:AddSlider('ESPOpacity', { Text = 'ESP visibility (all ESP)', Default = 100, Min = 5, Max = 100, Rounding = 0, Suffix = '%' })
ColorGroup:AddLabel('Box / name / arrow'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 60, 60), Title = 'Box color' })
ColorGroup:AddLabel('Skeleton / look'):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Skeleton color' })
ColorGroup:AddLabel('Tracers'):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 200, 0), Title = 'Tracer color' })
ColorGroup:AddLabel('Whitelisted players'):AddColorPicker('WLColor', { Default = Color3.fromRGB(80, 255, 120), Title = 'Whitelist color' })
ColorGroup:AddToggle('VisColors', { Text = 'Visible / hidden box colors (wall check)', Default = false })
ColorGroup:AddLabel('Visible'):AddColorPicker('VisColor', { Default = Color3.fromRGB(80, 255, 80), Title = 'Visible color' })
ColorGroup:AddLabel('Hidden'):AddColorPicker('HidColor', { Default = Color3.fromRGB(255, 60, 60), Title = 'Hidden color' })
ColorGroup:AddToggle('TeamColor', { Text = 'Use team colors', Default = false })
ColorGroup:AddToggle('ESPTeamCheck', { Text = 'Hide teammates', Default = false })
ColorGroup:AddToggle('HideWL', { Text = 'Hide whitelisted players', Default = false })
ColorGroup:AddSlider('ESPDistance', { Text = 'Max distance', Default = 2000, Min = 100, Max = 5000, Rounding = 0, Suffix = 'm' })

local ChamsGroup = Tabs.Visuals:AddRightGroupbox('Chams')
ChamsGroup:AddToggle('ChamsToggle', { Text = 'Chams (highlight)', Default = false })
ChamsGroup:AddToggle('ChamsWalls', { Text = 'Visible through walls', Default = true })
ChamsGroup:AddLabel('Fill'):AddColorPicker('ChamsFill', { Default = Color3.fromRGB(255, 60, 60), Title = 'Chams fill' })
ChamsGroup:AddLabel('Outline'):AddColorPicker('ChamsOutline', { Default = Color3.fromRGB(255, 255, 255), Title = 'Chams outline' })
ChamsGroup:AddSlider('ChamsAlpha', { Text = 'Fill transparency', Default = 50, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })

local RadarGroup = Tabs.Visuals:AddLeftGroupbox('Radar')
RadarGroup:AddToggle('Radar', { Text = 'Radar', Default = false })
RadarGroup:AddSlider('RadarSize', { Text = 'Radar size', Default = 70, Min = 40, Max = 150, Rounding = 0 })
RadarGroup:AddSlider('RadarRange', { Text = 'Radar range (studs)', Default = 300, Min = 50, Max = 1000, Rounding = 0 })
end

local restoreLighting

do
local WorldGroup = Tabs.World:AddLeftGroupbox('Lighting')
WorldGroup:AddToggle('Fullbright', { Text = 'Fullbright', Default = false })
WorldGroup:AddToggle('NoFog', { Text = 'No fog', Default = false })
WorldGroup:AddToggle('CustomTime', { Text = 'Custom time of day', Default = false })
WorldGroup:AddSlider('TimeSlider', { Text = 'Time (hour)', Default = 14, Min = 0, Max = 24, Rounding = 1 })

local HUDGroup = Tabs.World:AddRightGroupbox('HUD')
HUDGroup:AddToggle('Crosshair', { Text = 'Custom crosshair', Default = false })
HUDGroup:AddLabel('Crosshair color'):AddColorPicker('CrossColor', { Default = Color3.fromRGB(0, 255, 255), Title = 'Crosshair color' })
HUDGroup:AddSlider('CrossSize', { Text = 'Size', Default = 8, Min = 2, Max = 30, Rounding = 0 })
HUDGroup:AddSlider('CrossGap', { Text = 'Gap', Default = 4, Min = 0, Max = 20, Rounding = 0 })
HUDGroup:AddSlider('CrossThick', { Text = 'Thickness', Default = 1, Min = 1, Max = 4, Rounding = 0 })
HUDGroup:AddToggle('Watermark', { Text = 'Watermark (FPS / ping)', Default = true })

local MiscGroup = Tabs.World:AddLeftGroupbox('Misc')
MiscGroup:AddToggle('AntiAFK', { Text = 'Anti-AFK', Default = true })
MiscGroup:AddButton({
    Text = 'Rejoin server',
    Func = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
})

local PosGroup = Tabs.World:AddRightGroupbox('Teleport')
local savedCF
local function savePos()
    local hrp = getHRP(LocalPlayer)
    if hrp then savedCF = hrp.CFrame Library:Notify('Position saved.', 2) end
end
local function loadPos()
    local hrp = getHRP(LocalPlayer)
    if not savedCF then Library:Notify('No saved position yet.', 3) return end
    if hrp then
        hrp.CFrame = savedCF
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end
PosGroup:AddButton({ Text = 'Save position', Func = savePos })
PosGroup:AddButton({ Text = 'Teleport to saved position', Func = loadPos })
PosGroup:AddLabel('Save key'):AddKeyPicker('SavePosKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Save position key', NoUI = true })
PosGroup:AddLabel('Load key'):AddKeyPicker('LoadPosKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Load position key', NoUI = true })
actionBinds.SavePosKey = savePos
actionBinds.LoadPosKey = loadPos

LocalPlayer.Idled:Connect(function()
    if Library.Unloaded or not Toggles.AntiAFK.Value then return end
    local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
    if ok and vu then
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

local origLighting = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd,
}
function restoreLighting(keys)
    for _, k in ipairs(keys) do Lighting[k] = origLighting[k] end
end
Toggles.Fullbright:OnChanged(function()
    if not Toggles.Fullbright.Value then restoreLighting({ 'Brightness', 'GlobalShadows', 'Ambient', 'OutdoorAmbient' }) end
end)
Toggles.NoFog:OnChanged(function()
    if not Toggles.NoFog.Value then restoreLighting({ 'FogEnd' }) end
end)
Toggles.CustomTime:OnChanged(function()
    if not Toggles.CustomTime.Value then restoreLighting({ 'ClockTime' }) end
end)
end

local function refreshWL()
    local names, present = {}, {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) present[p.Name] = true end
    end
    table.sort(names)
    local keep = {}
    for n, v in pairs(Options.Whitelist.Value) do
        if v and present[n] then keep[n] = true end
    end
    Options.Whitelist:SetValues(names)
    Options.Whitelist:SetValue(keep)
end

do
local WLGroup = Tabs.Whitelist:AddLeftGroupbox('Whitelist')
WLGroup:AddLabel('Whitelisted players are ignored by aimbot, silent aim, triggerbot, hitbox, fling, auto shoot and (optionally) ESP.', true)
WLGroup:AddDropdown('Whitelist', { Values = {}, Default = 0, Multi = true, Text = 'Select players' })
WLGroup:AddToggle('WLFriends', { Text = 'Auto-whitelist Roblox friends', Default = false })

WLGroup:AddButton({ Text = 'Refresh list', Func = refreshWL })
WLGroup:AddButton({ Text = 'Clear whitelist', Func = function() Options.Whitelist:SetValue({}) end })
WLGroup:AddButton({
    Text = 'Whitelist everyone',
    Func = function()
        local all = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then all[p.Name] = true end end
        Options.Whitelist:SetValue(all)
    end,
})

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then cacheFriend(p) end end
refreshWL()
end

local updateESP, updateChams, updateCrosshair, espRemovePlayer, espCleanup

do
    local recs = {}
    local highlights = {}

    local R15 = {
        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
    }
    local R6 = {
        { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
        { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
    }

    local function playerColorRaw(p, key)
        if isWhitelisted(p) then return Options.WLColor.Value end
        if Toggles.TeamColor.Value and p.Team then return p.TeamColor.Color end
        if key == 'BoxColor' and Toggles.VisColors.Value then
            local hrp = getHRP(p)
            if hrp then
                return isVisible(hrp) and Options.VisColor.Value or Options.HidColor.Value
            end
        end
        return col(key)
    end

    local function playerColor(p, key)
        return Kit.bright(playerColorRaw(p, key))
    end

    local function shouldShow(p)
        if not isAlive(p) or not getHRP(p) then return false end
        if Toggles.HideWL.Value and isWhitelisted(p) then return false end
        if Toggles.ESPTeamCheck.Value and sameTeam(p) then return false end
        return true
    end

    local function radarGeometry()
        local r = Options.RadarSize.Value
        return Vector2.new(20 + r, 120 + r), r
    end

    local radarFrame = Kit.frame(Kit.gui, BLACK, WHITE, 1, false, true)
    radarFrame.BackgroundTransparency = 0.5
    radarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    radarFrame.ZIndex = 1
    local radarSelf = Kit.frame(Kit.gui, WHITE, nil, nil, false, true)
    radarSelf.AnchorPoint = Vector2.new(0.5, 0.5)
    radarSelf.Size = UDim2.fromOffset(5, 5)
    radarSelf.ZIndex = 2
    local crossLines = {}
    for i = 1, 4 do crossLines[i] = Kit.frame(Kit.gui, WHITE) end

    local function createRec(char)
        local root = Instance.new("Frame")
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.Size = UDim2.fromScale(1, 1)
        root.Parent = Kit.gui
        local rec = { root = root, char = char, all = {}, stamp = {}, tick = 0, corners = {}, skel = {} }
        local function add(f, z)
            f.ZIndex = z
            table.insert(rec.all, f)
            return f
        end

        rec.fill = add((Kit.frame(root, WHITE)), 1)

        local grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Transparency = NumberSequence.new(0, 0.55)
        grad.Parent = rec.fill

        rec.boxOut = add((Kit.frame(root, nil, BLACK, 3, true)), 2)
        local bf, bs = Kit.frame(root, nil, WHITE, 1, true)
        rec.box, rec.boxStroke = add(bf, 3), bs
        for i = 1, 8 do rec.corners[i] = add((Kit.frame(root, WHITE, BLACK, 1)), 3) end

        rec.hpBg = add((Kit.frame(root, Color3.fromRGB(25, 25, 25), BLACK, 1)), 4)
        local hp = Instance.new("Frame")
        hp.BorderSizePixel = 0
        hp.AnchorPoint = Vector2.new(0, 1)
        hp.Position = UDim2.new(0, 0, 1, 0)
        hp.Size = UDim2.new(1, 0, 1, 0)
        hp.BackgroundColor3 = Color3.new(0, 1, 0)
        hp.ZIndex = 5
        hp.Parent = rec.hpBg
        rec.hp = hp

        rec.name = add(Kit.text(root, 13), 6)
        rec.info = add(Kit.text(root, 12), 6)
        rec.tracer = add((Kit.frame(root, WHITE)), 2)
        rec.look = add((Kit.frame(root, WHITE)), 3)
        rec.arrow = add((Kit.frame(root, WHITE, BLACK, 1)), 3)
        for i = 1, 14 do rec.skel[i] = add((Kit.frame(root, WHITE)), 3) end
        local hf, hs = Kit.frame(root, nil, WHITE, 2, true, true)
        rec.head, rec.headStroke = add(hf, 3), hs
        rec.head.AnchorPoint = Vector2.new(0.5, 0.5)
        local rd = Kit.frame(root, WHITE, nil, nil, false, true)
        rd.AnchorPoint = Vector2.new(0.5, 0.5)
        rd.Size = UDim2.fromOffset(6, 6)
        rec.radar = add(rd, 3)
        return rec
    end

    local function dropRec(p)
        local rec = recs[p]
        if rec then
            pcall(function() rec.root:Destroy() end)
            recs[p] = nil
        end
    end

    local function drawBody(p, rec, use, char, hrp, vp, mouse, rOn, rc, rr)
        local c = playerColor(p, 'BoxColor')
        local camCF = Camera.CFrame

        if rOn then
            local rel = camCF:PointToObjectSpace(hrp.Position)
            local off = Vector2.new(rel.X, rel.Z) / Options.RadarRange.Value * rr
            if off.Magnitude > rr - 3 then off = off.Unit * (rr - 3) end
            local d = use(rec.radar)
            d.Position = UDim2.fromOffset(rc.X + off.X, rc.Y + off.Y)
            d.BackgroundColor3 = c
        end

        if not Toggles.ESPToggle.Value then return end

        local dist = (camCF.Position - hrp.Position).Magnitude
        if dist > Options.ESPDistance.Value then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local rootV, onScreen = Camera:WorldToViewportPoint(hrp.Position)

        if not onScreen then
            if Toggles.Arrows.Value then
                local rel = camCF:PointToObjectSpace(hrp.Position)
                local dir = Vector2.new(rel.X, -rel.Y)
                dir = dir.Magnitude > 1e-3 and dir.Unit or Vector2.new(0, -1)
                local tip = vp / 2 + dir * Options.ArrowRadius.Value
                local s = Options.ArrowSize.Value
                local a = use(rec.arrow)
                Kit.line(a, tip - dir * s * 1.6, tip, 5)
                a.BackgroundColor3 = c
            end
            return
        end

        local topV = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botV = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
        local h = math.abs(botV.Y - topV.Y)
        local w = h / 1.75
        local x, y = rootV.X - w / 2, topV.Y

        if Toggles.FillBox.Value then
            local f = use(rec.fill)
            Kit.rect(f, x, y, w, h)
            f.BackgroundColor3 = c
            f:SetAttribute("base", 1 - Options.FillAlpha.Value / 100)
            f.BackgroundTransparency = 1 - Options.FillAlpha.Value / 100
        end

        if Toggles.BoxESP.Value then
            if Options.BoxStyle.Value == 'Full' then
                Kit.rect(use(rec.boxOut), x, y, w, h)
                Kit.rect(use(rec.box), x, y, w, h)
                rec.boxStroke.Color = c
            else
                local t = 2
                local cl = math.clamp(math.min(w, h) * 0.34, 6, 40)
                local r = {
                    { x, y, cl, t }, { x + w - cl, y, cl, t }, { x, y + h - t, cl, t }, { x + w - cl, y + h - t, cl, t },
                    { x, y, t, cl }, { x + w - t, y, t, cl }, { x, y + h - cl, t, cl }, { x + w - t, y + h - cl, t, cl },
                }
                for i = 1, 8 do
                    local f = use(rec.corners[i])
                    Kit.rect(f, r[i][1], r[i][2], r[i][3], r[i][4])
                    f.BackgroundColor3 = c
                end
            end
        end

        if Toggles.NameESP.Value then
            local t = use(rec.name)
            t.Text = p.DisplayName
            t.Position = UDim2.fromOffset(rootV.X, y - 17)
            t.TextColor3 = c
        end

        local parts = {}
        if Toggles.DistESP.Value then table.insert(parts, math.floor(dist) .. 'm') end
        if Toggles.HealthText.Value and hum then table.insert(parts, math.floor(hum.Health) .. 'hp') end
        if Toggles.ToolESP.Value then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then table.insert(parts, tool.Name) end
        end
        if #parts > 0 then
            local t = use(rec.info)
            t.Text = table.concat(parts, ' | ')
            t.Position = UDim2.fromOffset(rootV.X, y + h + 2)
        end

        if Toggles.HealthBar.Value then
            local hpv, mx = 100, 100
            if hum then hpv, mx = hum.Health, math.max(hum.MaxHealth, 1) end
            local frac = math.clamp(hpv / mx, 0, 1)
            local bar = use(rec.hpBg)
            Kit.rect(bar, x - 9, y, 4, h)
            rec.hp.Size = UDim2.new(1, 0, math.max(frac, 0.02), 0)
            rec.hp.BackgroundColor3 = Kit.bright(Color3.fromHSV(frac * 0.33, 1, 1))
        end

        if Toggles.Tracers.Value then
            local o = Options.TracerOrigin.Value
            local from = (o == 'Bottom' and Vector2.new(vp.X / 2, vp.Y))
                or (o == 'Center' and vp / 2)
                or (o == 'Cursor' and mouse)
                or Vector2.new(vp.X / 2, 0)
            local f = use(rec.tracer)
            Kit.line(f, from, Vector2.new(rootV.X, y + h), 1)
            f.BackgroundColor3 = playerColor(p, 'TracerColor')
        end

        local head = char:FindFirstChild("Head")
        if head then
            local hv, hon = Camera:WorldToViewportPoint(head.Position)
            if hon then
                if Toggles.HeadDot.Value then
                    local rad = math.max(h / 9, 3)
                    local f = use(rec.head)
                    f.Position = UDim2.fromOffset(hv.X, hv.Y)
                    f.Size = UDim2.fromOffset(rad * 2, rad * 2)
                    rec.headStroke.Color = c
                end
                if Toggles.LookESP.Value then
                    local lv, lon = Camera:WorldToViewportPoint(head.Position + head.CFrame.LookVector * Options.LookLen.Value)
                    if lon then
                        local f = use(rec.look)
                        Kit.line(f, Vector2.new(hv.X, hv.Y), Vector2.new(lv.X, lv.Y), 2)
                        f.BackgroundColor3 = playerColor(p, 'SkeletonColor')
                    end
                end
            end
        end

        if Toggles.SkeletonESP.Value then
            local links = char:FindFirstChild("UpperTorso") and R15 or R6
            local sc = playerColor(p, 'SkeletonColor')
            for i, pair in ipairs(links) do
                local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                local line = rec.skel[i]
                if a and b and line then
                    local av, aon = Camera:WorldToViewportPoint(a.Position)
                    local bv, bon = Camera:WorldToViewportPoint(b.Position)
                    if aon and bon then
                        use(line)
                        Kit.line(line, Vector2.new(av.X, av.Y), Vector2.new(bv.X, bv.Y), 2)
                        line.BackgroundColor3 = sc
                    end
                end
            end
        end
    end

    local function drawRec(p, rec, char, hrp, vp, mouse, rOn, rc, rr)
        rec.tick += 1
        local tk = rec.tick
        local function use(f)
            rec.stamp[f] = tk
            if not f.Visible then f.Visible = true end
            return f
        end
        local ok, err = xpcall(drawBody, traceback, p, rec, use, char, hrp, vp, mouse, rOn, rc, rr)
        if not ok and not errSeen['esp_frames'] then
            errSeen['esp_frames'] = true
            warn('[FwSerial] ESP error: ' .. tostring(err))
            Library:Notify('ESP error (see F9 console)', 8)
        end

        Kit.fade(rec, Options.ESPOpacity.Value / 100)

        for _, f in ipairs(rec.all) do
            if rec.stamp[f] ~= tk and f.Visible then f.Visible = false end
        end
    end

    function updateESP()
        local vp = Camera.ViewportSize
        local mouse = UserInputService:GetMouseLocation()
        local rOn = Toggles.Radar.Value
        local rc, rr = radarGeometry()
        radarFrame.Visible = rOn
        radarSelf.Visible = rOn
        if rOn then
            radarFrame.Position = UDim2.fromOffset(rc.X, rc.Y)
            radarFrame.Size = UDim2.fromOffset(rr * 2, rr * 2)
            radarSelf.Position = UDim2.fromOffset(rc.X, rc.Y)
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getChar(p)
                local hrp = char and getHRP(p)
                local show = hrp ~= nil and shouldShow(p) and (Toggles.ESPToggle.Value or rOn)
                local rec = recs[p]
                if show then
                    if not rec or rec.char ~= char or not rec.root.Parent then
                        dropRec(p)
                        rec = createRec(char)
                        recs[p] = rec
                    end
                    drawRec(p, rec, char, hrp, vp, mouse, rOn, rc, rr)
                elseif rec then
                    dropRec(p)
                end
            end
        end
    end

    function updateChams()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getChar(p)
                local want = Toggles.ChamsToggle.Value and char ~= nil and shouldShow(p)
                local hl = highlights[p]
                if want then
                    if not hl or not hl.Parent or hl.Adornee ~= char then
                        if hl then hl:Destroy() end
                        hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.Parent = GuiParent
                        highlights[p] = hl
                    end
                    local wl = isWhitelisted(p)
                    hl.FillColor = Kit.bright(wl and Options.WLColor.Value or col('ChamsFill'))
                    hl.OutlineColor = Kit.bright(wl and Options.WLColor.Value or col('ChamsOutline'))
                    hl.FillTransparency = Options.ChamsAlpha.Value / 100
                    hl.DepthMode = Toggles.ChamsWalls.Value and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                elseif hl then
                    hl:Destroy()
                    highlights[p] = nil
                end
            end
        end
    end

    function updateCrosshair()
        local on = Toggles.Crosshair.Value
        local center = Camera.ViewportSize / 2
        local s, g, t = Options.CrossSize.Value, Options.CrossGap.Value, Options.CrossThick.Value
        local color = col('CrossColor')
        local cx, cy = center.X, center.Y
        local r = {
            { cx - t / 2, cy - g - s, t, s },
            { cx - t / 2, cy + g, t, s },
            { cx - g - s, cy - t / 2, s, t },
            { cx + g, cy - t / 2, s, t },
        }
        for i, l in ipairs(crossLines) do
            l.Visible = on
            if on then
                Kit.rect(l, r[i][1], r[i][2], r[i][3], r[i][4])
                l.BackgroundColor3 = color
            end
        end
    end

    function espRemovePlayer(p)
        dropRec(p)
        if highlights[p] then highlights[p]:Destroy() highlights[p] = nil end
    end

    function espCleanup()
        for p in pairs(recs) do dropRec(p) end
        for _, h in pairs(highlights) do h:Destroy() end
    end
end

local refreshRoles, holdsTool, updateMM2ESP, updateMM2Chams, updateGuns
local updateMM2Hitboxes, restoreMM2Hitboxes, removeMM2Player
local grabGun, knifeKillSelected, tpToRole, checkProximity, mm2Cleanup
local mm2Conns = {}

do
    local MurdLabel, SherLabel, InnoLabel
    if IS_MM2 then
    local DetectGroup = Tabs.MM2HVH:AddLeftGroupbox('Role Detection')
    MurdLabel = DetectGroup:AddLabel('Murderer: none', true)
    SherLabel = DetectGroup:AddLabel('Sheriff / Hero: none', true)
    InnoLabel = DetectGroup:AddLabel('Innocents: 0', true)
    DetectGroup:AddToggle('MM2Notify', { Text = 'Notify when roles are assigned', Default = true })
    DetectGroup:AddLabel('Roles are detected by who holds a Knife (murderer) or Gun (sheriff / hero). Before a round everyone shows as Innocent.', true)

    local MM2ESPGroup = Tabs.MM2HVH:AddLeftGroupbox('MM2HvH ESP')
    MM2ESPGroup:AddToggle('MM2ESP', { Text = 'MM2HvH ESP', Default = false })
        :AddKeyPicker('MM2ESPKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'MM2 ESP key', NoUI = true })
    MM2ESPGroup:AddToggle('MM2Box', { Text = 'Boxes', Default = true })
    MM2ESPGroup:AddDropdown('MM2BoxStyle', { Values = { 'Full', 'Corner' }, Default = 2, Multi = false, Text = 'Box style' })
    MM2ESPGroup:AddToggle('MM2Names', { Text = 'Role + name labels', Default = true })
    MM2ESPGroup:AddToggle('MM2Dist', { Text = 'Distance', Default = true })
    MM2ESPGroup:AddToggle('MM2Tracers', { Text = 'Tracers', Default = false })
    MM2ESPGroup:AddDropdown('MM2TracerOrigin', { Values = { 'Bottom', 'Center', 'Cursor', 'Top' }, Default = 1, Multi = false, Text = 'Tracer origin' })
    MM2ESPGroup:AddToggle('MM2Chams', { Text = 'Chams (role colored)', Default = false })
    MM2ESPGroup:AddToggle('MM2ShowInnocent', { Text = 'Show innocents', Default = true })
    MM2ESPGroup:AddLabel('Murderer'):AddColorPicker('MM2MurdererColor', { Default = Color3.fromRGB(255, 40, 40), Title = 'Murderer color' })
    MM2ESPGroup:AddLabel('Sheriff / Hero'):AddColorPicker('MM2SheriffColor', { Default = Color3.fromRGB(40, 140, 255), Title = 'Sheriff color' })
    MM2ESPGroup:AddLabel('Innocent'):AddColorPicker('MM2InnocentColor', { Default = Color3.fromRGB(60, 255, 120), Title = 'Innocent color' })
    MM2ESPGroup:AddLabel('Brightness / visibility sliders are in Visuals > Colors / Filters.', true)

    local GunGroup = Tabs.MM2HVH:AddRightGroupbox('Gun ESP')
    GunGroup:AddToggle('MM2GunESP', { Text = 'Gun ESP (dropped gun)', Default = false })
        :AddKeyPicker('MM2GunESPKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Gun ESP key', NoUI = true })
    GunGroup:AddToggle('MM2GunChams', { Text = 'Highlight through walls', Default = true })
    GunGroup:AddToggle('MM2GunTracer', { Text = 'Tracer to gun', Default = true })
    GunGroup:AddToggle('MM2GunNotify', { Text = 'Notify when gun drops', Default = true })
    GunGroup:AddLabel('Gun color'):AddColorPicker('MM2GunColor', { Default = Color3.fromRGB(255, 220, 0), Title = 'Gun color' })

    local MM2HitGroup = Tabs.MM2HVH:AddRightGroupbox('MM2 Hitbox Expander')
    MM2HitGroup:AddToggle('MM2Hitbox', { Text = 'Hitbox expander', Default = false,
        Tooltip = 'Turn off the Combat tab hitbox expander first, they share the same part.' })
    MM2HitGroup:AddDropdown('MM2HitboxTarget', { Values = { 'Murderer', 'Sheriff', 'Murderer + Sheriff', 'Everyone' }, Default = 1, Multi = false, Text = 'Expand who' })
    MM2HitGroup:AddDropdown('MM2HitboxPart', { Values = { 'HumanoidRootPart', 'Head' }, Default = 1, Multi = false, Text = 'Part to expand' })
    MM2HitGroup:AddSlider('MM2HitboxSize', { Text = 'Hitbox size', Default = 8, Min = 2, Max = 40, Rounding = 0 })
    MM2HitGroup:AddToggle('MM2HitboxVisible', { Text = 'Hitbox visible', Default = true, Tooltip = 'Off = invisible hitbox' })
    MM2HitGroup:AddSlider('MM2HitboxAlpha', { Text = 'Visible transparency', Default = 70, Min = 0, Max = 95, Rounding = 0, Suffix = '%' })
    MM2HitGroup:AddToggle('MM2HitboxCollide', { Text = 'Collisions on', Default = false, Tooltip = 'Off = you walk through the hitbox' })
    end

    local lastMurd, lastSher, lastInno = '', '', -1

    function holdsTool(p, name)
        local char = getChar(p)
        local t = char and char:FindFirstChild(name)
        if t and t:IsA("Tool") then return true end
        local bp = p:FindFirstChildOfClass("Backpack")
        t = bp and bp:FindFirstChild(name)
        return t ~= nil and t:IsA("Tool")
    end

    function refreshRoles()
        local murd, sher, inno = {}, {}, 0
        for _, p in ipairs(Players:GetPlayers()) do
            if isAlive(p) then
                local r = 'Innocent'
                if holdsTool(p, 'Knife') then r = 'Murderer' elseif holdsTool(p, 'Gun') then r = 'Sheriff' end
                mm2Roles[p] = r
                if r == 'Murderer' then table.insert(murd, p.DisplayName)
                elseif r == 'Sheriff' then table.insert(sher, p.DisplayName)
                else inno += 1 end
            else
                mm2Roles[p] = nil
            end
        end
        local m = #murd > 0 and table.concat(murd, ', ') or 'none'
        local s = #sher > 0 and table.concat(sher, ', ') or 'none'
        if m ~= lastMurd then
            MurdLabel:SetText('Murderer: ' .. m)
            if m ~= 'none' and Toggles.MM2Notify.Value then Library:Notify('Murderer: ' .. m, 5) end
            lastMurd = m
        end
        if s ~= lastSher then
            SherLabel:SetText('Sheriff / Hero: ' .. s)
            if s ~= 'none' and Toggles.MM2Notify.Value then Library:Notify('Sheriff: ' .. s, 5) end
            lastSher = s
        end
        if inno ~= lastInno then
            InnoLabel:SetText('Innocents: ' .. inno)
            lastInno = inno
        end
    end

    local function roleOf(p)
        return mm2Roles[p] or (isAlive(p) and 'Innocent' or nil)
    end

    local mm2Recs, mm2Highlights = {}, {}

    local function createMM2Rec(char)
        local root = Instance.new("Frame")
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.Size = UDim2.fromScale(1, 1)
        root.Parent = Kit.gui
        local rec = { root = root, char = char, all = {}, stamp = {}, tick = 0, corners = {} }
        local function add(f, z)
            f.ZIndex = z
            table.insert(rec.all, f)
            return f
        end
        rec.boxOut = add((Kit.frame(root, nil, BLACK, 3, true)), 2)
        local bf, bs = Kit.frame(root, nil, WHITE, 1, true)
        rec.box, rec.boxStroke = add(bf, 3), bs

        for i = 1, 8 do rec.corners[i] = add((Kit.frame(root, WHITE, BLACK, 1)), 3) end
        rec.text = add(Kit.text(root, 13), 6)
        rec.tracer = add((Kit.frame(root, WHITE)), 2)
        return rec
    end

    local function dropMM2Rec(p)
        local rec = mm2Recs[p]
        if rec then
            pcall(function() rec.root:Destroy() end)
            mm2Recs[p] = nil
        end
    end

    local function drawMM2Body(p, rec, use, char, hrp, vp, mouse, role)
        local rootV, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then return end
        local c = Kit.bright(Options['MM2' .. role .. 'Color'].Value)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        local topV = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botV = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
        local h = math.abs(botV.Y - topV.Y)
        local w = h / 1.75
        local x, y = rootV.X - w / 2, topV.Y

        if Toggles.MM2Box.Value then
            if Options.MM2BoxStyle.Value == 'Full' then
                Kit.rect(use(rec.boxOut), x, y, w, h)
                Kit.rect(use(rec.box), x, y, w, h)
                rec.boxStroke.Color = c
            else
                local t = 2
                local cl = math.clamp(math.min(w, h) * 0.34, 6, 40)
                local r = {
                    { x, y, cl, t }, { x + w - cl, y, cl, t }, { x, y + h - t, cl, t }, { x + w - cl, y + h - t, cl, t },
                    { x, y, t, cl }, { x + w - t, y, t, cl }, { x, y + h - cl, t, cl }, { x + w - t, y + h - cl, t, cl },
                }
                for i = 1, 8 do
                    local f = use(rec.corners[i])
                    Kit.rect(f, r[i][1], r[i][2], r[i][3], r[i][4])
                    f.BackgroundColor3 = c
                end
            end
        end
        if Toggles.MM2Names.Value then
            local t = use(rec.text)
            local label = ('[%s] %s'):format(role, p.DisplayName)
            if Toggles.MM2Dist.Value then label = label .. (' %dm'):format(math.floor(dist)) end
            t.Text = label
            t.Position = UDim2.fromOffset(rootV.X, y - 17)
            t.TextColor3 = c
        end
        if Toggles.MM2Tracers.Value then
            local o = Options.MM2TracerOrigin.Value
            local from = (o == 'Bottom' and Vector2.new(vp.X / 2, vp.Y))
                or (o == 'Center' and vp / 2)
                or (o == 'Cursor' and mouse)
                or Vector2.new(vp.X / 2, 0)
            local f = use(rec.tracer)
            Kit.line(f, from, Vector2.new(rootV.X, y + h), 1)
            f.BackgroundColor3 = c
        end
    end

    function updateMM2ESP()
        local vp = Camera.ViewportSize
        local mouse = UserInputService:GetMouseLocation()
        local on = Toggles.MM2ESP.Value
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char, hrp = getChar(p), getHRP(p)
                local role = roleOf(p)
                local show = on and char and hrp and role and (role ~= 'Innocent' or Toggles.MM2ShowInnocent.Value)
                local rec = mm2Recs[p]
                if show then
                    if not rec or rec.char ~= char or not rec.root.Parent then
                        dropMM2Rec(p)
                        rec = createMM2Rec(char)
                        mm2Recs[p] = rec
                    end
                    rec.tick += 1
                    local tk = rec.tick
                    local function use(f)
                        rec.stamp[f] = tk
                        if not f.Visible then f.Visible = true end
                        return f
                    end
                    local ok, err = xpcall(drawMM2Body, traceback, p, rec, use, char, hrp, vp, mouse, role)
                    if not ok and not errSeen['mm2_frames'] then
                        errSeen['mm2_frames'] = true
                        warn('[FwSerial] MM2 ESP error: ' .. tostring(err))
                        Library:Notify('MM2 ESP error (see F9 console)', 8)
                    end

                    Kit.fade(rec, Options.ESPOpacity.Value / 100)
                    for _, f in ipairs(rec.all) do
                        if rec.stamp[f] ~= tk and f.Visible then f.Visible = false end
                    end
                elseif rec then
                    dropMM2Rec(p)
                end
            end
        end
    end

    function updateMM2Chams()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getChar(p)
                local role = roleOf(p)
                local want = Toggles.MM2Chams.Value and char ~= nil and role ~= nil
                    and (role ~= 'Innocent' or Toggles.MM2ShowInnocent.Value)
                local hl = mm2Highlights[p]
                if want then
                    if not hl or not hl.Parent or hl.Adornee ~= char then
                        if hl then hl:Destroy() end
                        hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.Parent = GuiParent
                        mm2Highlights[p] = hl
                    end
                    hl.FillColor = Kit.bright(Options['MM2' .. role .. 'Color'].Value)
                elseif hl then
                    hl:Destroy()
                    mm2Highlights[p] = nil
                end
            end
        end
    end

    local gunDrops = {}
    local gunScanDone = false

    local function removeGun(inst)
        local g = gunDrops[inst]
        if not g then return end
        if g.hl then g.hl:Destroy() end
        if g.text then pcall(function() g.text:Destroy() end) end
        if g.tracer then pcall(function() g.tracer:Destroy() end) end
        gunDrops[inst] = nil
    end

    local function trackGun(inst)
        if inst.Name == "GunDrop" and inst:IsA("BasePart") and not gunDrops[inst] then
            gunDrops[inst] = {}
            if gunScanDone then
                if Toggles.MM2GunNotify.Value then Library:Notify('Gun dropped!', 4) end
                if Toggles.MM2AutoGrab and Toggles.MM2AutoGrab.Value and grabGun then task.delay(0.3, grabGun, true) end
            end
        end
    end

    if IS_MM2 then
        for _, d in ipairs(workspace:GetDescendants()) do trackGun(d) end
        gunScanDone = true
        table.insert(mm2Conns, workspace.DescendantAdded:Connect(trackGun))
        table.insert(mm2Conns, workspace.DescendantRemoving:Connect(function(inst)
            if gunDrops[inst] then removeGun(inst) end
        end))
    end

    function updateGuns()
        local vp = Camera.ViewportSize
        local on = Toggles.MM2GunESP.Value
        local color = Options.MM2GunColor.Value
        for inst, g in pairs(gunDrops) do
            if not inst.Parent then
                removeGun(inst)
            else
                if on and Toggles.MM2GunChams.Value then
                    if not g.hl then
                        g.hl = Instance.new("Highlight")
                        g.hl.Adornee = inst
                        g.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        g.hl.FillTransparency = 0.3
                        g.hl.OutlineColor = Color3.new(1, 1, 1)
                        g.hl.Parent = GuiParent
                    end
                    g.hl.FillColor = color
                elseif g.hl then
                    g.hl:Destroy()
                    g.hl = nil
                end

                if not g.text then
                    g.text = Kit.text(Kit.gui, 14)
                    g.tracer = Kit.frame(Kit.gui, WHITE)
                    g.text.ZIndex, g.tracer.ZIndex = 6, 2
                end
                g.text.Visible, g.tracer.Visible = false, false
                if on then
                    local v, onScreen = Camera:WorldToViewportPoint(inst.Position)
                    if onScreen then
                        local dist = (Camera.CFrame.Position - inst.Position).Magnitude
                        g.text.Text = ('Gun [%dm]'):format(math.floor(dist))
                        g.text.Position = UDim2.fromOffset(v.X, v.Y - 16)
                        g.text.TextColor3 = color
                        g.text.Visible = true
                        if Toggles.MM2GunTracer.Value then
                            Kit.line(g.tracer, Vector2.new(vp.X / 2, vp.Y), Vector2.new(v.X, v.Y), 1)
                            g.tracer.BackgroundColor3 = color
                            g.tracer.Visible = true
                        end
                    end
                end
            end
        end
    end

    local mm2Orig = {}

    function restoreMM2Hitboxes()
        for part, o in pairs(mm2Orig) do
            if part.Parent then
                part.Size, part.Transparency, part.CanCollide = o[1], o[2], o[3]
            end
            mm2Orig[part] = nil
        end
    end
    if IS_MM2 then Options.MM2HitboxPart:OnChanged(restoreMM2Hitboxes) end

    local function mm2Wants(p)
        local role = mm2Roles[p]
        if not role or isWhitelisted(p) then return false end
        local mode = Options.MM2HitboxTarget.Value
        if mode == 'Everyone' then return true end
        if mode == 'Murderer' then return role == 'Murderer' end
        if mode == 'Sheriff' then return role == 'Sheriff' end
        return role == 'Murderer' or role == 'Sheriff'
    end

    function updateMM2Hitboxes()
        if not Toggles.MM2Hitbox.Value or Toggles.HitboxToggle.Value then
            if next(mm2Orig) then restoreMM2Hitboxes() end
            return
        end
        local s = Options.MM2HitboxSize.Value
        local partName = Options.MM2HitboxPart.Value
        local transp = Toggles.MM2HitboxVisible.Value and (Options.MM2HitboxAlpha.Value / 100) or 1
        local collide = Toggles.MM2HitboxCollide.Value
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getChar(p)
                local part = char and char:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    if mm2Wants(p) then
                        if not mm2Orig[part] then mm2Orig[part] = { part.Size, part.Transparency, part.CanCollide } end
                        part.Size = Vector3.new(s, s, s)
                        part.Transparency = transp
                        part.CanCollide = collide
                    elseif mm2Orig[part] then
                        local o = mm2Orig[part]
                        part.Size, part.Transparency, part.CanCollide = o[1], o[2], o[3]
                        mm2Orig[part] = nil
                    end
                end
            end
        end
    end

    function removeMM2Player(p)
        dropMM2Rec(p)
        if mm2Highlights[p] then mm2Highlights[p]:Destroy() mm2Highlights[p] = nil end
        mm2Roles[p] = nil
    end

    function mm2Cleanup()
        for inst in pairs(gunDrops) do removeGun(inst) end
        for p in pairs(mm2Recs) do dropMM2Rec(p) end
        for p in pairs(mm2Highlights) do removeMM2Player(p) end
    end

    local grabBusy = false
    grabGun = function(auto)
        if grabBusy then return end
        if Toggles.FlingToggle.Value then
            if not auto then Library:Notify('Turn fling off first.', 3) end
            return
        end
        if auto and mm2Roles[LocalPlayer] == 'Murderer' then return end
        local hrp, hum = getHRP(LocalPlayer), getHum(LocalPlayer)
        if not hrp or not hum or hum.Health <= 0 then return end
        if holdsTool(LocalPlayer, 'Gun') then
            if not auto then Library:Notify('You already have the gun.', 3) end
            return
        end

        local gun, best
        for inst in pairs(gunDrops) do
            if inst.Parent then
                local d = (inst.Position - hrp.Position).Magnitude
                if not best or d < best then gun, best = inst, d end
            end
        end
        if not gun then
            if not auto then Library:Notify('No gun on the ground.', 3) end
            return
        end

        grabBusy = true
        local home = hrp.CFrame
        local t0 = os.clock()
        while gun.Parent and os.clock() - t0 < 1.5 and not Library.Unloaded do
            hrp = getHRP(LocalPlayer)
            if not hrp or holdsTool(LocalPlayer, 'Gun') then break end
            hrp.CFrame = gun.CFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            if firetouchinterest then
                pcall(function()
                    firetouchinterest(hrp, gun, 0)
                    firetouchinterest(hrp, gun, 1)
                end)
            end
            RunService.Heartbeat:Wait()
        end
        hrp = getHRP(LocalPlayer)
        if hrp then
            hrp.CFrame = home
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        grabBusy = false
        task.wait(0.15)
        if holdsTool(LocalPlayer, 'Gun') then Library:Notify('Got the gun!', 3) end
    end

    local knifeBusy = false
    function knifeKillSelected()
        if knifeBusy then return end
        local char, hrp, hum = getChar(LocalPlayer), getHRP(LocalPlayer), getHum(LocalPlayer)
        if not (char and hrp and hum) then return end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local knife = char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
        if not knife then
            Library:Notify('You have no knife (you have to be the murderer).', 4)
            return
        end
        if next(selectedTargets) == nil then
            Library:Notify('Nobody selected in the Target Menu.', 4)
            return
        end

        knifeAbort = false
        knifeBusy = true
        local home = hrp.CFrame
        if knife.Parent ~= char then hum:EquipTool(knife) end
        for _, p in ipairs(Players:GetPlayers()) do
            if knifeAbort then break end
            if selectedTargets[p.Name] and p ~= LocalPlayer and not isWhitelisted(p) then
                local t0 = os.clock()
                while isAlive(p) and isAlive(LocalPlayer) and not knifeAbort and os.clock() - t0 < 2.5 and not Library.Unloaded do
                    local thrp, myHRP = getHRP(p), getHRP(LocalPlayer)
                    if not thrp or not myHRP then break end
                    myHRP.CFrame = CFrame.lookAt(thrp.Position - thrp.CFrame.LookVector * 2, thrp.Position)
                    myHRP.AssemblyLinearVelocity = Vector3.zero
                    knife:Activate()
                    RunService.Heartbeat:Wait()
                end
            end
        end
        local myHRP = getHRP(LocalPlayer)
        if myHRP then
            myHRP.CFrame = home
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
        knifeBusy = false
    end

    function tpToRole(role)
        local hrp = getHRP(LocalPlayer)
        for p, r in pairs(mm2Roles) do
            local thrp = getHRP(p)
            if r == role and p ~= LocalPlayer and thrp and hrp then
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                return
            end
        end
        Library:Notify('No ' .. role .. ' found.', 3)
    end

    local lastProx = 0
    function checkProximity()
        if not Toggles.MM2Proximity.Value then return end
        local hrp = getHRP(LocalPlayer)
        if not hrp or mm2Roles[LocalPlayer] == 'Murderer' then return end
        for p, r in pairs(mm2Roles) do
            if r == 'Murderer' and p ~= LocalPlayer then
                local mh = getHRP(p)
                if mh then
                    local d = (mh.Position - hrp.Position).Magnitude
                    if d <= Options.MM2ProxRange.Value and os.clock() - lastProx > 3 then
                        lastProx = os.clock()
                        Library:Notify(('Murderer %s is %d studs away!'):format(p.DisplayName, math.floor(d)), 3)
                    end
                end
            end
        end
    end

    if IS_MM2 then
    local GrabGroup = Tabs.MM2HVH:AddRightGroupbox('Gun Grabber')
    GrabGroup:AddButton({ Text = 'Grab gun (TP there and back)', Func = function() task.spawn(grabGun) end })
    GrabGroup:AddLabel('Grab key'):AddKeyPicker('GunGrabKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Grab gun key', NoUI = true })
    GrabGroup:AddToggle('MM2AutoGrab', { Text = 'Auto grab when gun drops', Default = false, Tooltip = 'Skipped if you are the murderer' })

    local AlertGroup = Tabs.MM2HVH:AddLeftGroupbox('Alerts / Teleports')
    AlertGroup:AddToggle('MM2Proximity', { Text = 'Murderer proximity alert', Default = false })
    AlertGroup:AddSlider('MM2ProxRange', { Text = 'Alert range (studs)', Default = 40, Min = 10, Max = 150, Rounding = 0 })
    AlertGroup:AddButton({ Text = 'TP to Murderer', Func = function() tpToRole('Murderer') end })
    AlertGroup:AddButton({ Text = 'TP to Sheriff / Hero', Func = function() tpToRole('Sheriff') end })

    local function startRoleFling(role)
        table.clear(cooldown)
        Options.FlingTargetMode:SetValue(role)
        Toggles.FlingToggle:SetValue(true)
    end
    local MM2Fling = Tabs.MM2HVH:AddLeftGroupbox('MM2 Fling / Kill')
    MM2Fling:AddButton({ Text = 'Fling Murderer', Func = function() startRoleFling('Murderer') end })
    MM2Fling:AddButton({ Text = 'Fling Sheriff / Hero', Func = function() startRoleFling('Sheriff') end })
    MM2Fling:AddButton({ Text = 'Stop fling', Func = function() forceStopFling() end })

    local ShootGroup = Tabs.MM2HVH:AddRightGroupbox('Auto Shoot')
    ShootGroup:AddToggle('MM2AutoShoot', { Text = 'Auto shoot', Default = false,
        Tooltip = 'Detects the target role, teleports above them and shoots. Pre-round everyone is Innocent so nothing happens until roles are assigned.' })
        :AddKeyPicker('MM2AutoShootKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Auto shoot key', NoUI = true })
    ShootGroup:AddDropdown('MM2ShootRole', { Values = { 'Murderer', 'Sheriff', 'Both' }, Default = 1, Multi = false, Text = 'Target role' })
    ShootGroup:AddDropdown('MM2ShootWeapon', { Values = { 'Auto', 'Gun', 'Knife' }, Default = 1, Multi = false, Text = 'Weapon',
        Tooltip = 'Auto = Gun if you have one, otherwise Knife' })
    ShootGroup:AddDropdown('MM2ShootPart', { Values = { 'HumanoidRootPart', 'Head', 'UpperTorso', 'Torso' }, Default = 1, Multi = false, Text = 'Aim part' })
    ShootGroup:AddToggle('MM2ShootTP', { Text = 'Teleport above target', Default = true })
    ShootGroup:AddSlider('MM2ShootHeight', { Text = 'Height above target (studs)', Default = 10, Min = 3, Max = 40, Rounding = 0 })
    ShootGroup:AddToggle('MM2ShootReturn', { Text = 'Return to start when done', Default = true })
    ShootGroup:AddToggle('MM2ShootWall', { Text = 'Wall check', Default = false,
        Tooltip = 'Leave off while teleporting above, ceilings would block it.' })
    ShootGroup:AddToggle('MM2ShootEquip', { Text = 'Auto equip weapon', Default = true })
    ShootGroup:AddToggle('MM2ShootLook', { Text = 'Snap camera to target', Default = true,
        Tooltip = 'Turn on if your game reads the camera / mouse direction instead of Mouse.Hit' })
    ShootGroup:AddToggle('MM2ShootClick', { Text = 'Also send mouse click', Default = false,
        Tooltip = 'Needs mouse1click. Use if Tool:Activate() alone does not fire.' })
    ShootGroup:AddSlider('MM2ShootRange', { Text = 'Max range (no teleport)', Default = 150, Min = 20, Max = 500, Rounding = 0 })
    ShootGroup:AddSlider('MM2ShootDelay', { Text = 'Delay between shots (ms)', Default = 250, Min = 0, Max = 1500, Rounding = 0 })
    Kit.addPred(ShootGroup, 'MM2ShootPredict', 'Prediction (seconds)', 0.08)

    actionBinds.MM2AutoShootKey = function() Toggles.MM2AutoShoot:SetValue(not Toggles.MM2AutoShoot.Value) end

    local lastShot, shootHome, lastLock = 0, nil, nil
    local function releaseHome()
        if shootHome then
            local hrp = getHRP(LocalPlayer)
            if hrp and Toggles.MM2ShootReturn.Value then
                hrp.CFrame = shootHome
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            shootHome = nil
        end
        lastLock = nil
    end

    local function shootStep()
        autoAimPos, autoAimPart = nil, nil
        if Library.Unloaded or not Toggles.MM2AutoShoot.Value then releaseHome() return end
        if inputBlocked() or Toggles.FlingToggle.Value then return end

        local char, hrp, hum = getChar(LocalPlayer), getHRP(LocalPlayer), getHum(LocalPlayer)
        if not (char and hrp and hum) or hum.Health <= 0 then
            shootHome, lastLock = nil, nil
            return
        end

        local want = Options.MM2ShootWeapon.Value
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local function find(name)
            local t = char:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
            return (t and t:IsA("Tool")) and t or nil
        end
        local tool
        if want == 'Gun' then tool = find('Gun')
        elseif want == 'Knife' then tool = find('Knife')
        else tool = find('Gun') or find('Knife') end
        if not tool then releaseHome() return end
        if tool.Parent ~= char then
            if Toggles.MM2ShootEquip.Value then hum:EquipTool(tool) end
            return
        end

        local roleSel = Options.MM2ShootRole.Value
        local tpOn = Toggles.MM2ShootTP.Value
        local best, bestPart, bestD
        for p, r in pairs(mm2Roles) do
            if p ~= LocalPlayer and isAlive(p) and not isWhitelisted(p)
                and ((roleSel == 'Both' and (r == 'Sheriff' or r == 'Murderer')) or r == roleSel) then
                local pc = getChar(p)
                local part = pc and (pc:FindFirstChild(Options.MM2ShootPart.Value) or pc:FindFirstChild("HumanoidRootPart"))
                if part then
                    local d = (part.Position - hrp.Position).Magnitude
                    if (tpOn or d <= Options.MM2ShootRange.Value) and (not bestD or d < bestD)
                        and (not Toggles.MM2ShootWall.Value or isVisible(part)) then
                        best, bestPart, bestD = p, part, d
                    end
                end
            end
        end
        if not best then releaseHome() return end

        if lastLock ~= best then
            lastLock = best
            Library:Notify(('Auto shoot: locked on %s (%s)'):format(best.DisplayName, mm2Roles[best] or '?'), 3)
        end

        if tpOn then
            if not shootHome then shootHome = hrp.CFrame end
            hrp.CFrame = CFrame.new(bestPart.Position + Vector3.new(0, Options.MM2ShootHeight.Value, 0))
                * (hrp.CFrame - hrp.CFrame.Position)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end

        local aimPos = bestPart.Position + bestPart.AssemblyLinearVelocity * Options.MM2ShootPredict.Value
        autoAimPos, autoAimPart = aimPos, bestPart
        if Toggles.MM2ShootLook.Value then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)
        end

        if os.clock() - lastShot >= Options.MM2ShootDelay.Value / 1000 then
            lastShot = os.clock()
            pcall(function() tool:Activate() end)
            if Toggles.MM2ShootClick.Value and HAS_CLICK then pcall(mouse1click) end
        end
    end
    table.insert(mm2Conns, RunService.RenderStepped:Connect(function()
        safeCall('Auto Shoot', shootStep)
    end))
    Library:OnUnload(function()
        autoAimPos, autoAimPart = nil, nil
        pcall(releaseHome)
    end)
    end
end

do
    startSpectate = function(p)
        if not p then return end
        specTarget = p
        local h = getHum(p)
        if h then workspace.CurrentCamera.CameraSubject = h end
        Library:Notify('Spectating ' .. p.DisplayName, 2)
    end

    stopSpectate = function()
        specTarget = nil
        local h = getHum(LocalPlayer)
        if h then workspace.CurrentCamera.CameraSubject = h end
    end

    restoreCamera = function()
        local h = (specTarget and getHum(specTarget)) or getHum(LocalPlayer)
        if h then workspace.CurrentCamera.CameraSubject = h end
    end

    updateSpectate = function()
        if not specTarget then return end
        if not specTarget.Parent then stopSpectate() return end
        if flingActive and Toggles.FlingSpectate.Value then return end
        local h = getHum(specTarget)
        if not h then return end
        local cam = workspace.CurrentCamera
        if cam.CameraSubject ~= h then cam.CameraSubject = h end
    end

    stopAllActions = function()
        knifeAbort = true
        forceStopFling()
        stopSpectate()
    end
end

local TargetGui, restyleRows

do
    local tween, animate = Library.Tween, Library.Animate

    local TargetGroup = Tabs.Troll:AddRightGroupbox('Target Menu')
    TargetGroup:AddToggle('TargetMenu', { Text = 'Show target menu', Default = true })
        :AddKeyPicker('TargetMenuKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Target menu key', NoUI = true })
    TargetGroup:AddLabel('Knife kill key'):AddKeyPicker('KnifeKillKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Knife kill key', NoUI = true })
    TargetGroup:AddLabel('Kill selected key'):AddKeyPicker('KillKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Kill selected key', NoUI = true })
    TargetGroup:AddLabel('Stop all key'):AddKeyPicker('StopKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Stop all key', NoUI = true })
    TargetGroup:AddButton({ Text = 'Knife kill selected', Func = function() task.spawn(function() if knifeKillSelected then knifeKillSelected() end end) end })
    TargetGroup:AddButton({ Text = 'Clear selection', Func = function() table.clear(selectedTargets) end })

    actionBinds.GunGrabKey = function() if grabGun then grabGun() end end
    actionBinds.KnifeKillKey = function() if knifeKillSelected then knifeKillSelected() end end
    actionBinds.StopKey = function() stopAllActions() end

    local BG, BG2, BG3 = Color3.fromRGB(16, 16, 20), Color3.fromRGB(24, 24, 30), Color3.fromRGB(40, 40, 52)
    local ACCENT, TXT, DIM = Color3.fromRGB(88, 101, 242), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
    local STOPRED = Color3.fromRGB(190, 55, 70)
    Library:OnTheme(function(t)
        BG, BG2, BG3, ACCENT, TXT, DIM = t.BG, t.BG2, t.BG3, t.ACCENT, t.TXT, t.DIM
    end)
    local FONT = Enum.Font.Code
    local LEFT = Enum.TextXAlignment.Left

    local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
    end
    local function round(parent, r)
        return mk("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
    end

    TargetGui = Instance.new("ScreenGui")
    TargetGui.Name = "FwSerialTargets"
    TargetGui.ResetOnSpawn = false
    TargetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    TargetGui.DisplayOrder = 99
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(TargetGui) end end)
    TargetGui.Parent = GuiParent
    Library:AddThemeRoot(TargetGui)

    local FULL_H, MIN_H = 430, 40
    local TFrame = mk("CanvasGroup", {
        Size = UDim2.fromOffset(260, FULL_H), Position = UDim2.new(0, 20, 0.3, 0),
        BackgroundColor3 = BG, BorderSizePixel = 0, Visible = false, GroupTransparency = 1,
    }, TargetGui)
    round(TFrame, 16)
    mk("UIStroke", { Color = ACCENT, Thickness = 1.5 }, TFrame)
    local TScale = mk("UIScale", { Scale = 0.92 }, TFrame)

    local TTitle = mk("TextLabel", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 28), BackgroundColor3 = BG2, BorderSizePixel = 0,
        Text = "  FwSerial | Targets", TextColor3 = TXT, Font = FONT, TextSize = 14, TextXAlignment = LEFT, Active = true,
    }, TFrame)
    round(TTitle, 10)

    local TBody = mk("Frame", {
        Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 1, -38), BackgroundTransparency = 1,
    }, TFrame)

    local TCollapse = mk("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(24, 22),
        BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "-", TextColor3 = TXT, Font = FONT, TextSize = 16,
    }, TTitle)
    round(TCollapse, 8)
    animate(TCollapse, BG3)

    local collapsed = false
    TCollapse.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        TCollapse.Text = collapsed and "+" or "-"
        if collapsed then
            local tw = tween(TFrame, 0.22, { Size = UDim2.fromOffset(260, MIN_H) }, Enum.EasingStyle.Quint)
            tw.Completed:Connect(function() if collapsed then TBody.Visible = false end end)
        else
            TBody.Visible = true
            tween(TFrame, 0.28, { Size = UDim2.fromOffset(260, FULL_H) }, Enum.EasingStyle.Back)
        end
    end)

    local TSearch = mk("TextBox", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 24), BackgroundColor3 = BG3, BorderSizePixel = 0,
        Font = FONT, TextSize = 12, TextColor3 = TXT, Text = "", PlaceholderText = " search players...",
        PlaceholderColor3 = DIM, ClearTextOnFocus = false, TextXAlignment = LEFT,
    }, TBody)
    round(TSearch, 8)

    local TList = mk("ScrollingFrame", {
        Position = UDim2.fromOffset(6, 34), Size = UDim2.new(1, -12, 0, 190), BackgroundColor3 = BG2, BorderSizePixel = 0,
        ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, TBody)
    round(TList, 10)
    mk("UIListLayout", { Padding = UDim.new(0, 3) }, TList)
    mk("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3) }, TList)

    local TStatus = mk("TextLabel", {
        Position = UDim2.fromOffset(6, 228), Size = UDim2.new(1, -12, 0, 16), BackgroundTransparency = 1,
        TextColor3 = DIM, Font = FONT, TextSize = 11, TextXAlignment = LEFT, Text = "Sel: 0",
    }, TBody)

    local TButtons = mk("Frame", {
        Position = UDim2.fromOffset(6, 248), Size = UDim2.new(1, -12, 0, 108), BackgroundTransparency = 1,
    }, TBody)
    mk("UIGridLayout", {
        CellSize = UDim2.new(0.25, -3, 0, 24), CellPadding = UDim2.fromOffset(4, 4), SortOrder = Enum.SortOrder.LayoutOrder,
    }, TButtons)

    local btnOrder = 0
    local function makeTButton(label, cb, color)
        btnOrder += 1
        local b = mk("TextButton", {
            LayoutOrder = btnOrder, BackgroundColor3 = color or BG3, BorderSizePixel = 0, Text = label,
            TextColor3 = TXT, Font = FONT, TextSize = 12,
        }, TButtons)
        round(b, 8)
        animate(b, color or BG3)
        b.MouseButton1Click:Connect(function() cb() end)
        return b
    end

    local TStop = mk("TextButton", {
        Position = UDim2.fromOffset(6, 362), Size = UDim2.new(1, -12, 0, 28), BackgroundColor3 = STOPRED,
        BorderSizePixel = 0, Text = "STOP ALL (fling / spectate / knife)", TextColor3 = Color3.new(1, 1, 1),
        Font = FONT, TextSize = 12,
    }, TBody)
    round(TStop, 10)
    animate(TStop, STOPRED)

    local rows = {}
    local filter = ""

    local function matches(p)
        if filter == "" then return true end
        return p.Name:lower():find(filter, 1, true) ~= nil or p.DisplayName:lower():find(filter, 1, true) ~= nil
    end

    local function styleRow(p)
        local r = rows[p]
        if not r then return end
        local role = mm2Roles[p]
        local wl = isWhitelisted(p)
        local want = selectedTargets[p.Name] and ACCENT or BG3
        if r.st.base ~= want then r.st.set(want) end
        local tag = (wl and '[WL] ') or (role == 'Murderer' and '[M] ') or (role == 'Sheriff' and '[S] ') or ''
        local nm = (p.DisplayName ~= p.Name) and (p.DisplayName .. ' (@' .. p.Name .. ')') or p.Name
        r.name.Text = tag .. nm
        r.name.TextColor3 = (wl and Color3.fromRGB(80, 255, 120))
            or (role == 'Murderer' and Color3.fromRGB(255, 110, 110))
            or (role == 'Sheriff' and Color3.fromRGB(110, 170, 255)) or TXT
        local myHRP, hrp = getHRP(LocalPlayer), getHRP(p)
        r.dist.Text = (myHRP and hrp) and (math.floor((hrp.Position - myHRP.Position).Magnitude) .. 'm') or '-'
        r.btn.Visible = matches(p)
    end

    local function addRow(p)
        if p == LocalPlayer or rows[p] then return end
        local b = mk("TextButton", {
            Size = UDim2.new(1, -9, 0, 24), BorderSizePixel = 0, BackgroundColor3 = BG3, Text = "", AutoButtonColor = false,
        }, TList)
        round(b, 8)
        local st = animate(b, BG3)
        local n = mk("TextLabel", {
            Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -56, 1, 0), BackgroundTransparency = 1, Font = FONT,
            TextSize = 12, TextXAlignment = LEFT, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = TXT, Text = "",
        }, b)
        local d = mk("TextLabel", {
            Position = UDim2.new(1, -48, 0, 0), Size = UDim2.fromOffset(42, 24), BackgroundTransparency = 1, Font = FONT,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = DIM, Text = "",
        }, b)
        rows[p] = { btn = b, name = n, dist = d, st = st }
        b.MouseButton1Click:Connect(function()
            selectedTargets[p.Name] = (not selectedTargets[p.Name]) or nil
            styleRow(p)
            restyleRows()
        end)
        styleRow(p)
    end

    local function removeRow(p)
        if rows[p] then rows[p].btn:Destroy() rows[p] = nil end
        selectedTargets[p.Name] = nil
        if specTarget == p then stopSpectate() end
    end

    function restyleRows()
        local n = 0
        for _ in pairs(selectedTargets) do n += 1 end
        for p in pairs(rows) do styleRow(p) end
        TStatus.Text = ('Sel: %d | Fling: %s | Spec: %s'):format(
            n, Toggles.FlingToggle.Value and 'ON' or 'off', specTarget and specTarget.DisplayName or 'off')
    end

    for _, p in ipairs(Players:GetPlayers()) do addRow(p) end
    table.insert(mm2Conns, Players.PlayerAdded:Connect(addRow))
    table.insert(mm2Conns, Players.PlayerRemoving:Connect(removeRow))

    TSearch:GetPropertyChangedSignal("Text"):Connect(function()
        filter = TSearch.Text:lower()
        restyleRows()
    end)

    local function firstSelected()
        local myHRP = getHRP(LocalPlayer)
        local best, bestD
        for _, pl in ipairs(Players:GetPlayers()) do
            if selectedTargets[pl.Name] and pl ~= LocalPlayer and isAlive(pl) then
                local h = getHRP(pl)
                local d = (h and myHRP) and (h.Position - myHRP.Position).Magnitude or math.huge
                if not bestD or d < bestD then best, bestD = pl, d end
            end
        end
        return best
    end

    local function nearestPlayer()
        local myHRP = getHRP(LocalPlayer)
        local best, bestD
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and isAlive(pl) and not isWhitelisted(pl) then
                local h = getHRP(pl)
                if h and myHRP then
                    local d = (h.Position - myHRP.Position).Magnitude
                    if not bestD or d < bestD then best, bestD = pl, d end
                end
            end
        end
        return best
    end

    local function smartKill()
        if next(selectedTargets) == nil then
            Library:Notify('Select someone in the target menu first.', 3)
            return
        end
        if IS_MM2 and holdsTool(LocalPlayer, 'Knife') then
            task.spawn(knifeKillSelected)
        else
            table.clear(cooldown)
            Options.FlingTargetMode:SetValue('Selected')
            Toggles.FlingToggle:SetValue(true)
        end
    end

    local function tpToSelected()
        local pl = firstSelected()
        local hrp, thrp = getHRP(LocalPlayer), pl and getHRP(pl)
        if hrp and thrp then
            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
        else
            Library:Notify('No selected player to teleport to.', 3)
        end
    end

    local function sitOnSelected()
        local pl = firstSelected() or nearestPlayer()
        local hrp = getHRP(LocalPlayer)
        local head = pl and getChar(pl) and getChar(pl):FindFirstChild("Head")
        if hrp and head then hrp.CFrame = head.CFrame * CFrame.new(0, 1.5, 0) end
    end

    local function specList()
        local sel, all = {}, {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and isAlive(pl) then
                table.insert(all, pl)
                if selectedTargets[pl.Name] then table.insert(sel, pl) end
            end
        end
        local l = #sel > 0 and sel or all
        table.sort(l, function(a, b) return a.Name < b.Name end)
        return l
    end

    local function stepSpec(dir)
        local l = specList()
        if #l == 0 then Library:Notify('Nobody to spectate.', 2) return end
        local idx = 0
        for i, pl in ipairs(l) do if pl == specTarget then idx = i end end
        if idx == 0 then idx = (dir > 0) and #l or 1 end
        startSpectate(l[((idx - 1 + dir) % #l) + 1])
        restyleRows()
    end

    local function whitelistSelected(on)
        if next(selectedTargets) == nil then Library:Notify('Select someone first.', 2) return end
        local d = {}
        for k, v in pairs(Options.Whitelist.Value) do if v then d[k] = true end end
        for name in pairs(selectedTargets) do d[name] = on or nil end
        Options.Whitelist:SetValue(d)
        if on then table.clear(selectedTargets) end
        restyleRows()
    end

    makeTButton("All", function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not isWhitelisted(p) then selectedTargets[p.Name] = true end
        end
        restyleRows()
    end)
    makeTButton("None", function() table.clear(selectedTargets) restyleRows() end)
    makeTButton("Invert", function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not isWhitelisted(p) then
                selectedTargets[p.Name] = (not selectedTargets[p.Name]) or nil
            end
        end
        restyleRows()
    end)
    makeTButton("Near", function()
        local p = nearestPlayer()
        if p then selectedTargets[p.Name] = (not selectedTargets[p.Name]) or nil end
        restyleRows()
    end)

    makeTButton("Fling", function()
        if Toggles.FlingToggle.Value then
            forceStopFling()
        else
            table.clear(cooldown)
            Options.FlingTargetMode:SetValue('Selected')
            Toggles.FlingToggle:SetValue(true)
        end
        restyleRows()
    end)
    makeTButton("Kill", function() smartKill() restyleRows() end)
    makeTButton("TP", tpToSelected)
    makeTButton("Sit", sitOnSelected)

    makeTButton("Spec", function()
        local p = firstSelected() or specList()[1]
        if p then startSpectate(p) else Library:Notify('Nobody to spectate.', 2) end
        restyleRows()
    end)
    makeTButton("Prev", function() stepSpec(-1) end)
    makeTButton("Next", function() stepSpec(1) end)
    makeTButton("Unspec", function() stopSpectate() restyleRows() end)

    makeTButton("WL", function() whitelistSelected(true) end)
    makeTButton("UnWL", function() whitelistSelected(false) end)
    if IS_MM2 then
        makeTButton("Knife", function() task.spawn(knifeKillSelected) end)
        makeTButton("Gun", function() task.spawn(grabGun) end)
    end

    TStop.MouseButton1Click:Connect(function()
        stopAllActions()
        restyleRows()
        Library:Notify('Stopped.', 1.5)
    end)

    actionBinds.KillKey = smartKill

    local tOpen = false
    local function setTargetOpen(v)
        tOpen = v and true or false
        if tOpen then
            TFrame.Visible = true
            tween(TFrame, 0.2, { GroupTransparency = 0 })
            tween(TScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
        else
            tween(TFrame, 0.15, { GroupTransparency = 1 })
            local tw = tween(TScale, 0.16, { Scale = 0.92 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tw.Completed:Connect(function() if not tOpen then TFrame.Visible = false end end)
        end
    end
    Toggles.TargetMenu:OnChanged(function() setTargetOpen(Toggles.TargetMenu.Value) end)
    setTargetOpen(Toggles.TargetMenu.Value)

    do
        local dragging, dragStart, startPos
        TTitle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, TFrame.Position
            end
        end)
        table.insert(mm2Conns, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                TFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
        table.insert(mm2Conns, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end
end

do
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddToggle('KeybindList', { Text = 'Show keybind list', Default = false })
Toggles.KeybindList:OnChanged(function()
    if Library.KeybindFrame then Library.KeybindFrame.Visible = Toggles.KeybindList.Value end
end)
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Panic key'):AddKeyPicker('PanicKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = false, Text = 'Panic key', NoUI = true })
MenuGroup:AddLabel('Menu bind (show / hide)'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

local ThemeGroup = Tabs['UI Settings']:AddRightGroupbox('GUI Colors')
local THEME_PRESETS = {
    ['Default']  = { Color3.fromRGB(88, 101, 242),  Color3.fromRGB(16, 16, 20), Color3.fromRGB(235, 235, 240) },
    ['Crimson']  = { Color3.fromRGB(220, 50, 70),   Color3.fromRGB(18, 12, 14), Color3.fromRGB(240, 232, 234) },
    ['Emerald']  = { Color3.fromRGB(40, 200, 120),  Color3.fromRGB(12, 18, 15), Color3.fromRGB(232, 242, 236) },
    ['Ocean']    = { Color3.fromRGB(40, 150, 230),  Color3.fromRGB(10, 16, 24), Color3.fromRGB(230, 238, 245) },
    ['Sunset']   = { Color3.fromRGB(255, 120, 60),  Color3.fromRGB(20, 14, 12), Color3.fromRGB(245, 236, 230) },
    ['Purple']   = { Color3.fromRGB(170, 80, 230),  Color3.fromRGB(16, 12, 22), Color3.fromRGB(240, 232, 246) },
    ['Pink']     = { Color3.fromRGB(240, 90, 170),  Color3.fromRGB(20, 12, 17), Color3.fromRGB(245, 234, 240) },
    ['Mono']     = { Color3.fromRGB(210, 210, 215), Color3.fromRGB(14, 14, 14), Color3.fromRGB(235, 235, 235) },
    ['Light']    = { Color3.fromRGB(70, 90, 230),   Color3.fromRGB(240, 240, 245), Color3.fromRGB(30, 30, 40) },
}
local themeNames = { 'Default', 'Crimson', 'Emerald', 'Ocean', 'Sunset', 'Purple', 'Pink', 'Mono', 'Light' }

local function deriveTheme(accent, bg, txt)
    local lum = 0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B
    local toward = lum < 0.5 and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    return {
        BG = bg, BG2 = bg:Lerp(toward, 0.05), BG3 = bg:Lerp(toward, 0.14),
        ACCENT = accent, TXT = txt, DIM = txt:Lerp(bg, 0.45),
    }
end

local themeApplying = false
local function applyThemeFromPickers()
    if themeApplying then return end
    Library:ApplyTheme(deriveTheme(Options.ThemeAccent.Value, Options.ThemeBG.Value, Options.ThemeText.Value))
end

ThemeGroup:AddDropdown('ThemePreset', { Values = themeNames, Default = 1, Multi = false, Text = 'Preset' })
ThemeGroup:AddLabel('Accent color'):AddColorPicker('ThemeAccent', { Default = THEME_PRESETS.Default[1], Title = 'Accent' })
ThemeGroup:AddLabel('Background color'):AddColorPicker('ThemeBG', { Default = THEME_PRESETS.Default[2], Title = 'Background' })
ThemeGroup:AddLabel('Text color'):AddColorPicker('ThemeText', { Default = THEME_PRESETS.Default[3], Title = 'Text' })
for _, k in ipairs({ 'ThemeAccent', 'ThemeBG', 'ThemeText' }) do Options[k]:OnChanged(applyThemeFromPickers) end
Options.ThemePreset:OnChanged(function()
    local p = THEME_PRESETS[Options.ThemePreset.Value]
    if not p then return end
    themeApplying = true
    Options.ThemeAccent:SetValue(p[1])
    Options.ThemeBG:SetValue(p[2])
    Options.ThemeText:SetValue(p[3])
    themeApplying = false
    applyThemeFromPickers()
end)
ThemeGroup:AddButton('Reset colors', function() Options.ThemePreset:SetValue('Default') end)

local connections = {}
local fpsTimer, frames = 0, 0

do
    local function aimStep()
        if Library.Unloaded then return end
        if not Toggles.AimbotToggle.Value then
            heldKeys.AimLatch = false
            return
        end
        if Library.Toggled then return end
        local active
        if Options.AimKeyMode.Value == 'Toggle' then
            active = not inputBlocked() and (Options.AimbotKey.Value == 'None' or heldKeys.AimLatch == true)
        else
            active = holdActive('AimbotKey')
        end
        if active then
            Camera = workspace.CurrentCamera
            pcall(runAimbot)
        end
    end
    pcall(function() RunService:UnbindFromRenderStep('FwSerialAim') end)
    RunService:BindToRenderStep('FwSerialAim', Enum.RenderPriority.Camera.Value + 1, aimStep)
end

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
    if Library.Unloaded then return end
    Camera = workspace.CurrentCamera
    hue = (os.clock() * Options.RGBSpeed.Value / 20) % 1

    if Toggles.SilentToggle.Value then
        silentTarget = getTarget({
            fov = Options.SilentFOV.Value, part = Options.SilentPart.Value,
            wall = Toggles.SilentWall.Value, priority = Options.AimPriority.Value,
        })
    else
        silentTarget = nil
    end

    local mousePos = UserInputService:GetMouseLocation()
    Kit.setRing(fovRing, fovStroke, Toggles.AimbotToggle.Value and Toggles.ShowFOV.Value,
        Options.AimFOV.Value, mousePos, col('BoxColor'))
    Kit.setRing(silentRing, silentStroke, Toggles.SilentToggle.Value and Toggles.ShowSilentFOV.Value,
        Options.SilentFOV.Value, mousePos, silentTarget and Color3.fromRGB(80, 255, 80) or col('SkeletonColor'))

    if Toggles.Trigger.Value and holdActive('TriggerKey') then runTrigger() end

    local hrp = getHRP(LocalPlayer)
    if Toggles.SpinToggle.Value and hrp and not Toggles.FlingToggle.Value then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Options.SpinSpeed.Value), 0)
    end

    updateSpectate()

    safeCall('ESP', updateESP)
    safeCall('Crosshair', updateCrosshair)
    safeCall('Chams', updateChams)

    if os.clock() - lastRoleScan > 0.25 then
        lastRoleScan = os.clock()
        if IS_MM2 then
            safeCall('Roles', refreshRoles)
            safeCall('Proximity', checkProximity)
        end
        restyleRows()
        pollKeyPickers()
    end
    if IS_MM2 then
        safeCall('MM2 ESP', updateMM2ESP)
        safeCall('MM2 chams', updateMM2Chams)
        safeCall('Gun ESP', updateGuns)
    end

    if Toggles.Fullbright.Value then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    end
    if Toggles.NoFog.Value then Lighting.FogEnd = 1e9 end
    if Toggles.CustomTime.Value then Lighting.ClockTime = Options.TimeSlider.Value end

    frames += 1
    fpsTimer += dt
    if fpsTimer >= 0.5 then
        local fps = math.floor(frames / fpsTimer)
        frames, fpsTimer = 0, 0
        Library:SetWatermarkVisibility(Toggles.Watermark.Value)
        if Toggles.Watermark.Value then
            local ping = 0
            pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            Library:SetWatermark(('FwSerial | %d fps | %d ms'):format(fps, ping))
        end
    end
end))

table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if Library.Unloaded then return end

    updateHitboxes()
    if IS_MM2 then updateMM2Hitboxes() end

    local hrp = getHRP(LocalPlayer)
    if not hrp then return end

    if Toggles.FlingToggle.Value then return end

    if Toggles.AntiFlingToggle.Value then
        if hrp.AssemblyLinearVelocity.Magnitude > 150 then hrp.AssemblyLinearVelocity = Vector3.zero end
        if hrp.AssemblyAngularVelocity.Magnitude > 50 then hrp.AssemblyAngularVelocity = Vector3.zero end
    end

    local hum = getHum(LocalPlayer)
    local typing = inputBlocked()

    if Toggles.FlyToggle.Value and not typing then
        local cf = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
        hrp.AssemblyLinearVelocity = dir.Magnitude > 0 and dir.Unit * Options.FlySpeed.Value or Vector3.zero
    end

    if Toggles.SpeedToggle.Value and hum and not Toggles.FlyToggle.Value then
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + md * (Options.SpeedValue.Value - hum.WalkSpeed) * dt
        end
    end

    if Toggles.BhopToggle.Value and hum and not typing and UserInputService:IsKeyDown(Enum.KeyCode.Space)
        and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

table.insert(connections, RunService.Stepped:Connect(function()
    if Library.Unloaded then return end

    if Toggles.AntiFlingToggle.Value and not Toggles.FlingToggle.Value then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getChar(p)
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end

    if Toggles.NoclipToggle.Value and not flingActive then
        local char = getChar(LocalPlayer)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

table.insert(connections, Players.PlayerAdded:Connect(function(p)
    cacheFriend(p)
    task.delay(0.5, refreshWL)
end))
table.insert(connections, Players.PlayerRemoving:Connect(function(p)
    espRemovePlayer(p)
    removeMM2Player(p)
    friendCache[p], cooldown[p] = nil, nil
    if flingTarget == p then flingTarget = nil end
    task.delay(0.2, refreshWL)
end))

Library:OnUnload(function()
    pcall(function() RunService:UnbindFromRenderStep('FwSerialAim') end)
    pcall(stopAllActions)
    for _, c in ipairs(connections) do c:Disconnect() end
    restoreHitboxes()
    restoreMM2Hitboxes()
    for _, c in ipairs(inputConns) do c:Disconnect() end
    if TargetGui then TargetGui:Destroy() end
    for _, c in ipairs(mm2Conns) do c:Disconnect() end
    mm2Cleanup()
    espCleanup()
    restoreLighting({ 'Brightness', 'ClockTime', 'GlobalShadows', 'Ambient', 'OutdoorAmbient', 'FogEnd' })
end)

local keybindIndexes = {}
for idx, opt in pairs(Options) do
    if type(opt) == 'table' and opt.Type == 'KeyPicker' then
        table.insert(keyPickers, opt)
        table.insert(keybindIndexes, idx)
        opt:OnChanged(function()
            if opt.Value == 'Escape' then opt:SetValue({ 'None', opt.Mode or 'Toggle' }) end
        end)
    end
end

local function clearAllKeybinds()
    for _, opt in ipairs(keyPickers) do
        if opt ~= Options.MenuKeybind then
            opt:SetValue({ 'None', opt.Mode or 'Toggle' })
        end
    end
    table.clear(heldKeys)
end
MenuGroup:AddButton('Clear all keybinds', function()
    clearAllKeybinds()
    Library:Notify('All keybinds removed.', 3)
end)

local panicList = {
    'AimbotToggle', 'SilentToggle', 'Trigger', 'FlingToggle', 'SpinToggle', 'FlyToggle',
    'SpeedToggle', 'NoclipToggle', 'HitboxToggle', 'MM2Hitbox', 'MM2AutoShoot',
}
local function panic()
    stopAllActions()
    for _, n in ipairs(panicList) do
        if Toggles[n] and Toggles[n].Value then Toggles[n]:SetValue(false) end
    end
    Library:Notify('Panic: features disabled', 3)
end
actionBinds.PanicKey = panic
MenuGroup:AddButton('Panic (disable all features)', panic)

MenuGroup:AddToggle('AutoLoadLast', { Text = 'Auto load last settings', Default = false,
    Tooltip = 'Keeps your current settings saved and loads them every time the script starts (good for queueing).' })
MenuGroup:AddToggle('AutoExecute', { Text = 'Auto execute on teleport', Default = false,
    Tooltip = 'Re-runs the script after you teleport / join a match from the queue. Needs queue_on_teleport.' })
MenuGroup:AddInput('AutoExecSource', { Text = 'Auto execute source (raw link or workspace file name)', Placeholder = 'https://.../FwSerial.lua  or  FwSerial.lua' })

do
    local MARKER = 'FwSerial/autoload_last.txt'
    local queueFn = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

    local function saveLast()
        if Toggles.AutoLoadLast.Value then SaveManager:Write('_last') end
    end

    local function buildAutoExec()
        local src = tostring(Options.AutoExecSource.Value or ''):match('^%s*(.-)%s*$')
        if src == '' then return nil end
        if src:find('loadstring', 1, true) then return src end
        if src:match('^https?://') then return ('loadstring(game:HttpGet(%q))()'):format(src) end
        return ('loadstring(readfile(%q))()'):format(src)
    end

    Toggles.AutoLoadLast:OnChanged(function()
        pcall(function()
            if not isfolder('FwSerial') then makefolder('FwSerial') end
            if Toggles.AutoLoadLast.Value then
                writefile(MARKER, '1')
                saveLast()
            elseif isfile(MARKER) then
                delfile(MARKER)
            end
        end)
    end)

    Toggles.AutoExecute:OnChanged(function()
        if not Toggles.AutoExecute.Value then return end
        if not queueFn then
            Library:Notify('Your executor has no queue_on_teleport, auto execute will not work.', 5)
        elseif not buildAutoExec() then
            Library:Notify('Auto execute: fill in the source (raw link or file name) below.', 5)
        end
    end)

    table.insert(connections, LocalPlayer.OnTeleport:Connect(function(state)
        if Library.Unloaded or state ~= Enum.TeleportState.Started then return end
        pcall(saveLast)
        if Toggles.AutoExecute.Value and queueFn then
            local code = buildAutoExec()
            if code then pcall(queueFn, code) end
        end
    end))

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(10)
            pcall(saveLast)
        end
    end)

    Library:OnUnload(function() pcall(saveLast) end)
end

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes(keybindIndexes)
SaveManager:SetIgnoreIndexes({ 'ThemePreset' })
ThemeManager:SetFolder('FwSerial')
SaveManager:SetFolder('FwSerial/hvh')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
clearAllKeybinds()

Library:Notify(IS_MM2 and 'FwSerial loaded (MM2 detected) - press END to hide / show' or 'FwSerial loaded - press END to hide / show', 5)
end
