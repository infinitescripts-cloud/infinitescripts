--[[ Obfuscated bihhh ]]
(function()
    local function _D(s)
        local t={}
        for i=1,#s,2 do
            t[#t+1]=string.char(tonumber(s:sub(i,i+1),16))
        end
        return table.concat(t)
    end

    local _0 = {
        TextColor = Color3.fromRGB(255,255,255),
        Background = Color3.fromRGB(15,15,20),
        Topbar = Color3.fromRGB(25,25,32),
        Shadow = Color3.fromRGB(10,10,15),
        NotificationBackground = Color3.fromRGB(22,22,30),
        NotificationActionsBackground = Color3.fromRGB(138,92,246),
        TabBackground = Color3.fromRGB(35,35,45),
        TabStroke = Color3.fromRGB(60,60,80),
        TabBackgroundSelected = Color3.fromRGB(124,58,237),
        TabTextColor = Color3.fromRGB(200,200,220),
        SelectedTabTextColor = Color3.fromRGB(255,255,255),
        ElementBackground = Color3.fromRGB(28,28,38),
        ElementBackgroundHover = Color3.fromRGB(38,38,52),
        SecondaryElementBackground = Color3.fromRGB(20,20,28),
        ElementStroke = Color3.fromRGB(55,55,75),
        SecondaryElementStroke = Color3.fromRGB(45,45,65),
        SliderBackground = Color3.fromRGB(40,40,55),
        SliderProgress = Color3.fromRGB(14,165,233),
        SliderStroke = Color3.fromRGB(56,189,248),
        ToggleBackground = Color3.fromRGB(30,30,40),
        ToggleEnabled = Color3.fromRGB(37,99,235),
        ToggleDisabled = Color3.fromRGB(70,70,85),
        ToggleEnabledStroke = Color3.fromRGB(96,165,250),
        ToggleDisabledStroke = Color3.fromRGB(90,90,110),
        ToggleEnabledOuterStroke = Color3.fromRGB(59,130,246),
        ToggleDisabledOuterStroke = Color3.fromRGB(40,40,55),
        DropdownSelected = Color3.fromRGB(109,40,217),
        DropdownUnselected = Color3.fromRGB(28,28,38),
        InputBackground = Color3.fromRGB(25,25,35),
        InputStroke = Color3.fromRGB(99,102,241),
        PlaceholderColor = Color3.fromRGB(160,160,185)
    }

    local _1 = loadstring(game:HttpGet(_D("68747470733a2f2f7369726975732e6d656e752f7261796669656c64")))()
    if false then local _dead = 1 + 2 end

    local _2 = _1:CreateWindow({
        Name = _D("496e66696e6974652773204d4d32207c204c6f61646572"),
        Icon = _D("63726f737368616972"),
        LoadingTitle = _D("496e66696e697465204d4d3220536372697074"),
        LoadingSubtitle = _D("746865206e6577206572612021"),
        Theme = _0,
        ShowText = _D("496e66696e6974652773204d4d32"),
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = _D("496e66696e6974654d4d32"),
            FileName = _D("4c6f61646572436f6e666967")
        },
        KeySystem = false
    })

    local _3 = _2:CreateTab(_D("53637269707420457865637574696f6e"), _D("706c6179"))
    local _ = 5 + 5 -- dead const

    _3:CreateSection(_D("4f6666696369616c20536f75726365205761726e696e67"))

    _3:CreateLabel(
        _D("49662074686973207363726970742063616d652066726f6d206f74686572207369746573206f74686572207468616e2072736372697074732c20506c656173652064657374726f792069742e"),
        _D("747269616e676c652d616c657274"),
        Color3.fromRGB(120,20,20),
        true
    )

    _3:CreateParagraph({
        Title = _D("41757468656e7469636174696f6e204e6f74696365"),
        Content = _D("48656c6c6f2120506c6561736520636c69636b205665726966792053637269707420666f722061757468656e7469636174696f6e2e204966204f6666696369616c2c207363726f6c6c20646f776e20616e6420636c69636b20224578656375746520496e66696e6974652773204d4d3222205468616e6b7321")
    })

    _3:CreateButton({
        Name = _D("56657269667920536372697074"),
        Callback = function()
            local _4 = game:GetService(_D("506c6179657273"))
            local _5 = _4.LocalPlayer
            local _6 = _5 and _5.Name or _D("")
            local _7 = (_6:lower() == _D("706f7070696e6769726c78") or _6:lower() == _D("617368795f61736837343734"))
            local _8 = debug.info(1, _D("73")) or _D("")
            local _9 = string.find(_8:lower(), _D("72736372697074732e6e6574")) ~= nil
            if false then local _dead2 = 10 * 2 end

            if _7 then
                _1:Notify({
                    Title = _D("57656c636f6d652043726561746f72"),
                    Content = _D("546865206f776e6572212057656c636f6d652e20436f6d706c6574656c7920666f7220796f7520746f20656e6a6f792e"),
                    Duration = 5,
                    Image = _D("63726f776e")
                })
            elseif _9 then
                _1:Notify({
                    Title = _D("566572696669636174696f6e2053756363657373"),
                    Content = _D("54686973207363726970742069732031303025206f6666696369616c2c205468616e6b7321"),
                    Duration = 5,
                    Image = _D("636865636b2d636972636c65")
                })
            else
                _1:Notify({
                    Title = _D("4175746f2053656c662d446573747275637420496e69746961746564"),
                    Content = _D("54686973205549206973206175746f2073656c66206465737472756374696e672c2073696e63652069742063616d652066726f6d20616e20756e6f6666696369616c20736974652e0a4369616f21"),
                    Duration = 5 + 5,
                    Image = _D("74726173682d32")
                })
                task.delay(5 + 5, function()
                    _1:Destroy()
                end)
            end
        end
    })

    _3:CreateSection(_D("53637269707420436f6e74726f6c73"))

    _3:CreateButton({
        Name = _D("4578656375746520496e66696e697465204d4d32"),
        Callback = function()
            _1:Notify({
                Title = _D("4c6f6164696e6720536372697074"),
                Content = _D("496e66696e697465204d4d3220697320657865637574696e672e2e2e"),
                Duration = 4,
                Image = _D("636865636b2d636972636c65")
            })
            loadstring(game:HttpGet(_D("68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f696e66696e697465736372697074732d636c6f75642f696e66696e697465736372697074732f6d61696e2f696e66696e697465736d6d322e6c7561")))()
        end
    })
end)()