-- usage:
-- run, then start chatting.
-- put "--" before your message to send your message raw (no bypass)
-- put "-#" before your message to force the aggressive bypasser

-- configuration
-- enable the aggressive chat bypasser
local chatbypassharder = true
-- used when not bypassing, modifies the message to evade detection
local replace = {
	-- spaces become the annoying little shit windows puts in my newlines
	[" "] = "\x0A",
	-- tildes become a longer, less detected tilde
	["~"] = "\xe2\x81\x93",
}
-- used when bypassing, flip brackets to work for the arabic supplements
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
-- all the swears/possibly filtered words
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
	"addict", "wine", "vagina", "penis",
}
-- doesnt put these two letters together when aggressive bypassing
local splitthis = {
	"fu", "ck", "uc", "ni", "ig", "dc", "po", "di",
	"ci", "cg", "na", "az", "sh", "it", "hi", "bi",
	"ch", "tc", "ky", "ys", "sl", "la", "ve", "cu",
	"um", "pu", "ga", "as", "ss", "mo", "le", "ba",
	"ur", "se", "ex", "ho", "co", "ig", "is", "sc",
	"or", "rd",
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
	-- magic
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
	if chatbypassharder then
		local kill = false
		for _,swear in swears do
			kill = kill or content:lower():find(swear) ~= nil
		end
		if kill then
			return badboy(content)
		end
	end
	local newcontent = content:gsub(patternmatch, function(c)
		local a = replace[c] or c
		if type(a) == "table" then
			a = a[math.random(1, #a)]
		end
		return a
	end)
	if content == newcontent then
		return content:sub(1, 1) .. "." .. content:sub(2, -1)
	end
	return newcontent
end
local tcs = game:GetService("TextChatService")
local chatinputbar = tcs:FindFirstChildOfClass("ChatInputBarConfiguration")
local chatbox = game:GetService("CoreGui"):WaitForChild("ExperienceChat"):WaitForChild("appLayout"):WaitForChild("chatInputBar"):WaitForChild("Background"):WaitForChild("Container")
local box = chatbox:WaitForChild("TextContainer"):WaitForChild("TextBoxContainer"):WaitForChild("TextBox")
local send = chatbox:WaitForChild("SendButton")
local function killsignal(sig)
	local GC = getconnections or get_signal_cons
	if GC then
		local fs = GC(sig)
		for _,v in fs do
			if v.Disable then
				v.Disable(v)
			elseif v.Disconnect then
				v.Disconnect(v)
			end
		end
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
killsignal(box.Focused)
killsignal(box:GetPropertyChangedSignal("Text"))
killsignal(box.FocusLost)
box.Focused:Connect(function()
	box.PlaceholderText = ""
end)
box.FocusLost:Connect(function(enter)
	local content = box.Text
	if enter then
		sendchat(content)
		content = ""
	end
	box.PlaceholderText = content
	box.Text = ""
	task.wait()
	box.Text = content
	box.PlaceholderText = "IY Lite lessfilter enabled"
end)
box.PlaceholderText = "IY Lite lessfilter enabled"
send.Activated:Connect(function()
	sendchat(box.Text)
	box.Text = ""
end)
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Portable Lessfilter",
	Text = "Chat Bypass: " .. (chatbypassharder and "ON" or "OFF"),
	Duration = 5
})