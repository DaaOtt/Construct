include("shared.lua")
net.Receive("lot_menu", function()
	local owner = net.ReadEntity()
	local owners = net.ReadTable()
	print(owner)
	PrintTable(owners)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Lot Menu")
	frame:SetSize(800, 600)
	frame:Center()
	frame:MakePopup(true)
	local info = vgui.Create("DCollapsibleCategory", frame)
	info:Dock(TOP)
	info:SetLabel("Information")
		local p = vgui.Create("DPanel", info)
			local own = vgui.Create("DLabel", p)
			own:SetText("Owner: " .. tostring(owner))
			own:SetDark(true)
			own:Dock(TOP)
			local co = vgui.Create("DLabel", p)
			co:SetText("Co-owners: ")
			co:SetDark(true)
			co:Dock(TOP)
			for i = 1, #owners do
				local a = vgui.Create("DLabel", p)
				a:SetText(owners[i]:Nick())
				a:SetDark(true)
				a:Dock(TOP)
			end
		p:Dock(TOP)
		p:SetSize(0, 350)
		p:SizeToChildren()
		print(p:InvalidateLayout(true))
		
	local cats = vgui.Create("DCollapsibleCategory", frame)
	cats:Dock(TOP)
	cats:SetLabel("Actions")
		local buy = vgui.Create("DButton", cats)
		if owner:IsPlayer() then
			buy:SetText("Sell this lot")
		else
			buy:SetText("Buy this lot")
		end
		buy:Dock(TOP)
		buy.DoClick = function()
			net.Start("lot_buy")
			net.SendToServer()
			frame:Close()
		end
		if owner:IsPlayer() then
			local add = vgui.Create("DButton", cats)
			add:SetText("Add a co-owner...")
			add:Dock(TOP)
			add.DoClick = function()
				local menu = DermaMenu()
				for _, ply in ipairs(player.GetAll()) do
					if ply ~= LocalPlayer() then
						if not table.HasValue(owners, ply) then
							menu:AddOption(ply:Nick(), function()
								net.Start("lot_addowner")
									net.WriteEntity(ply)
								net.SendToServer()
								menu:Hide()
								menu:Remove()
								frame:Close()
							end)
						end
					end
				end
				menu:Open()	
			end
		end
end)