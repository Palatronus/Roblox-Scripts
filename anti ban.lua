local chatbypassharder = true

local replace = {
	[" "] = "\x0A",
	["~"] = "\xe2\x81\x93",
}
local replace2 = {
	[" "] = "\x0A",
	["~"] = "\xe2\x81\x93",
	["("] = ")",
	[")"] = "(",
	["<"] = ">",
	[">"] = "<",
	["["] = "]",
	["]"] = "[",
	["{"] = "}",
	["}"] = "{",
	["!"] = "\xc7\x83",
	["\""] = "\xe2\x80\x9c",
}
local swears = {
	"fuck", "shit", "bitch", "dick",
	"kill urself", "kill yourself", "backshot",
	"kys", "faggot", "nigg", "cig",
	"slave", "slut", "bastard", "republican",
	"democrat", "kill myself", "self harm",
	"moron", "hitler", "nazi", "pedophile",
	"kill himself", "cum", "condo", "rule 34",
	"pussy", "ass", "gay", "balls", "horny",
	"sex", "porn", "twink", "sybau", "stfu",
	"discord", "ignore", "job", "bust", "nut",
	"deez", "goon", "rape", "groom", "predator",
	"furry", "femboy", "hoe", "retard",
	"instagram", "yt", "youtube", "alcohol",
	"addict", "wine", "vagina"
}
local splitthis = {
	"fu", "ck", "uc", "ni", "ig", "dc", "po", "di",
	"ci", "cg", "na", "az", "sh", "it", "hi", "bi",
	"ch", "tc", "ky", "ys", "sl", "la", "ve", "cu",
	"um", "pu", "ga", "as", "ss", "mo", "le", "ba",
	"ur", "se", "ex", "ho", "co", "ig"
}
local function randomString()
	local s = ""
	for _=1, math.random(32, 128) do s ..= string.char(math.random(32, 126)) end
	return s
end
local patternmatch = ""
for k,_ in pairs(replace) do
	if k == "." then
		patternmatch ..= "%."
	elseif k == "%" then
		patternmatch ..= "%%"
	elseif k == "(" then
		patternmatch ..= "%("
	elseif k == ")" then
		patternmatch ..= "%)"
	elseif k == "[" then
		patternmatch ..= "%["
	elseif k == "]" then
		patternmatch ..= "%]"
	else
		patternmatch ..= k
	end
end
patternmatch = "[" .. patternmatch .. "]"
local function badboy(content)
	local kys = ({"\xef\xb9\xb6", "\xef\xb9\xb8", "\xef\xb9\xba"})[math.random(1, 3)]
	local first = content:sub(1, 1)
	local reverses = ""
	local woah = {utf8.codepoint(content, 1, -1)}
	for i=1, math.floor(#woah / 2) do
		local j = #woah - i + 1
		woah[i], woah[j] = woah[j], woah[i]
	end
	local i = 1
	while i <= #woah do
		local a = utf8.char(woah[i])
		if i < #woah then
			local b = utf8.char(woah[i + 1])
			local c = b .. a
			if not table.find(splitthis, c:lower()) and not c:find("[^%a+]") then
				i += 2
				reverses ..= kys .. c
				continue
			end
		end
		a = replace2[a] or a
		i += 1
		reverses ..= kys .. a
	end
	return reverses .. kys
end
local function goodboy(content)
	-- spiky bypass
	if chatbypassharder then
		local kill = false
		for _,swear in pairs(swears) do
			kill = kill or content:lower():find(swear) ~= nil
		end
		if kill then
			return badboy(content)
		end
	end
	-- fluffy bypass
	content = content:gsub(patternmatch, function(c)
		local a = replace[c] or c
		if type(a) == "table" then
			a = a[math.random(1, #a)]
		end
		return a
	end)
	return content
end
local tcs = game:GetService("TextChatService")
local chatinputbar = tcs:FindFirstChildOfClass("ChatInputBarConfiguration")
local chatbox = game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container
local box = chatbox.TextContainer.TextBoxContainer.TextBox
local send = chatbox.SendButton
local function hooksignal(sig)
	local ev = Instance.new("BindableEvent")
	local fs = {}
	local GC = getconnections or get_signal_cons
	if GC then
		fs = GC(sig)
		for _,v in fs do
			if v.Function then
				ev.Event:Connect(v.Function)
			elseif v.Fire then
				ev.Event:Connect(function(...)
					v:Fire(...)
				end)
			end
			if v.Disable then
				v.Disable(v)
			elseif v.Disconnect then
				v.Disconnect(v)
			end
		end
	end
	return function(...)
		ev:Fire(...)
	end
end
local function sendchat(content)
	if content ~= "" then
		if content:sub(1, 2) == "--" then
			content = content:sub(3)
		elseif content:sub(1, 2) == "-#" then
			content = badboy(content:sub(3))
		elseif content:sub(1, 1) ~= "/" then
			content = goodboy(content)
		end
		chatinputbar.TargetTextChannel:SendAsync(content, randomString())
	end
end
local chgtxt = box:GetPropertyChangedSignal("Text")
local foc = hooksignal(box.Focused)
local chg = hooksignal(chgtxt)
local flo = hooksignal(box.FocusLost)
box.Focused:Connect(function()
	foc()
	box.PlaceholderText = ""
end)
chgtxt:Connect(chg)
box.FocusLost:Connect(function(enter)
	local content = box.Text
	if enter then
		sendchat(content)
		content = ""
	end
	box.PlaceholderText = content
	box.Text = ""
	flo(false)
	task.wait()
	box.Text = content
	box.PlaceholderText = "IY Lite lessfilter enabled"
end)
box.PlaceholderText = "IY Lite lessfilter enabled"
hooksignal(send.Activated)
send.Activated:Connect(function()
	sendchat(box.Text)
	box.Text = ""
end)
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Portable Lessfilter",
	Text = "Chat Bypass: " .. (chatbypassharder and "ON" or "OFF"),
	Duration = 5
})
