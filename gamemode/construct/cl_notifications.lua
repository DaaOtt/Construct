local notifications = {}
function notification.Get(uid)
	for k, note in ipairs(notifications) do
		if note.uid == uid then
			return note
		end
	end
end
function notification.Add(text, color, length)
	color = color or Color(0, 0, 0)
	color = Color(color.r, color.g, color.b, 128)
	local uid
	repeat
		uid = math.random()
	until not notification.Get(uid)
	
	table.insert(notifications, {
		uid = uid,
		text = text,
		color = color,
		x = 0,
		y = 0,
		lines = 1,
		dismissed = false,
	})
	if length then
		timer.Simple(length, function()
			notification.Dismiss(uid)
		end)
	end
	return uid
end
function notification.Dismiss(uid)
	local note = notification.Get(uid)
	if note then
		note.dismissed = true
	end
end
function notification.Remove(uid)
	for k, note in ipairs(notifications) do
		if note.uid == uid then
			table.remove(notifications, k)
			return
		end
	end
end

surface.CreateFont("Notification", {
	font = "Roboto",
	size = 18,
	weight = 100,
})
hook.Add("HUDPaint", "DrawNotification", function()
	local w, h = ScrW(), ScrH()
	for _, note in ipairs(notifications) do
		surface.SetDrawColor(note.color)
		surface.DrawRect(w - 350 + note.x, h - note.y, 350, 32)
		draw.DrawText(note.text, "Notification", w - 175 + note.x, h - note.y + 8, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
end)
hook.Add("Think", "NotificationThink", function()
	local queue = {}
	for index, note in ipairs(notifications) do
		local targety = note.lines * 32
		local totaly = note.lines * 32
		local done = false
		for _, n in ipairs(notifications) do
			if n ~= note and not done then
				targety = targety + n.lines * 32
			else
				done = true
			end
			totaly = totaly + n.lines * 32
		end
		note.y = Lerp(FrameTime() * 20, note.y, totaly - targety)
		if note.dismissed then
			if note.x < 350 then
				note.x = Lerp(FrameTime() * 20, note.x, 351)
			else
				queue[#queue + 1] = note.uid
			end
		end
	end
	for i = 1, #queue do
		notification.Remove(queue[i])
	end
end)