-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

player = nil
coords = {}
curVehicle = nil
driver = nil

Citizen.CreateThread(function()
    while true do
		player = GetPlayerPed(-1)
		coords = GetEntityCoords(player)
        curVehicle = GetVehiclePedIsIn(player, false)
        driver = GetPedInVehicleSeat(curVehicle, -1)
        Citizen.Wait(500)
    end
end)

plyShopID 	= 0
emptyShops 	= {}
RegisterNetEvent('t1ger_mechanicjob:fetchMechShopsCL')
AddEventHandler('t1ger_mechanicjob:fetchMechShopsCL', function(shopID)
	plyShopID = shopID
	for k,v in pairs(shopBlips) do RemoveBlip(v) end
	ESX.TriggerServerCallback('t1ger_mechanicjob:getTakenShops', function(ownedShops)
		for k,v in pairs(ownedShops) do
			if v.id ~= plyShopID then
				emptyShops[v.id] = v.id
			end
		end
		for k,v in ipairs(Config.MechanicShops) do
			if plyShopID == k then
				for _,y in pairs(ownedShops) do
					if y.id == plyShopID then
						CreateShopBlips(k,v,y.name)
						break
					end
				end
			else
				if emptyShops[k] == k then
					for _,y in pairs(ownedShops) do
						if y.id == k then
							CreateShopBlips(k,v,y.name)
						end
					end
				else
					if Config.PurchasableMechBlip then
						CreateShopBlips(k,v,Lang["vacant_shops"])
					end
				end
			end
		end
	end)
end)

-- ## BOSS MENU START ## --
bossMenu, storageMenu, workbenchMenu = nil, nil, nil
distance = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		for k,v in pairs(Config.MechanicShops) do
			-- Boss Menu:
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.menuPos[1], v.menuPos[2], v.menuPos[3], false)
			if distance <= 6.0 then 
				bossMenuFunction(k,v,distance)
			end
			-- Storage Menu:
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.storage[1], v.storage[2], v.storage[3], false)
			if distance <= 6.0 then 
				storageMenuFunction(k,v,distance)
			end
			-- Workbench Menu:
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.workbench[1], v.workbench[2], v.workbench[3], false)
			if distance <= 6.0 then 
				workbenchMenuFunction(k,v,distance)
			end
		end
	end
end)

-- Boss Menu:
function bossMenuFunction(k,v,distToBoss)
	if bossMenu ~= nil then
		distToBoss = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, bossMenu.menuPos[1], bossMenu.menuPos[2], bossMenu.menuPos[3], false)
		while bossMenu ~= nil and distToBoss > 2.0 do
			bossMenu = nil
			Citizen.Wait(1)
		end
		if bossMenu == nil then
			ESX.UI.Menu.CloseAll()
		end
	else
		local mk = Config.MarkerSettings
		if distToBoss <= 10.0 and distToBoss >= 2.0 then
			if mk.enable then
				DrawMarker(mk.type, v.menuPos[1], v.menuPos[2], v.menuPos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
			end
		elseif distToBoss <= 2.0 then
			if plyShopID == k then
				DrawText3Ds(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang['mech_shop_manage'])
				if IsControlJustPressed(0, Config.KeyToManageShop) then
					bossMenu = v
					MechShopManageMenu(k,v)
				end
			else
				if emptyShops[k] == k then
					DrawText3Ds(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang['no_access_to_shop'])
				else
					if plyShopID == 0 then
						DrawText3Ds(v.menuPos[1], v.menuPos[2], v.menuPos[3], (Lang['press_to_buy_shop']:format(math.floor(v.price))))
						if IsControlJustPressed(0, Config.KeyToBuyMechShop) then
							bossMenu = v
							BuyMechShopMenu(k,v)
						end
					else
						DrawText3Ds(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang['only_one_mech_shop'])
					end
				end
			end
		end
	end
end

-- Manage Mech Shop Menu:
function MechShopManageMenu(id,val)
	local elements = {
		{ label = Lang['rename_mech_shop'], value = "rename_mech_shop" },
		{ label = Lang['sell_mech_shop'], value = "sell_mech_shop" },
		{ label = Lang['employees_action'], value = "employees_menu" },
		{ label = Lang['accounts_action'], value = "accounts_menu" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_manage_menu",
		{
			title    = "Mech Shop ["..tostring(id).."]",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'rename_mech_shop') then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_shop_rename', {
				title = "Rename Mech Shop"
			}, function(data2, menu2)
				menu2.close()
				local shopName = tostring(data2.value)
				ESX.TriggerServerCallback('t1ger_mechanicjob:renameMechShop', function(renamed)
					if renamed then
						ShowNotifyESX((Lang['mech_shop_renamed']):format(shopName))
						TriggerServerEvent('t1ger_mechanicjob:fetchMechShops')
						menu.close()
						bossMenu = nil
					else
						ShowNotifyESX(Lang['not_your_mech_shop'])
						menu.close()
						bossMenu = nil
					end
				end, id, val, shopName)
			end,
			function(data2, menu2)
				menu2.close()	
			end)
		end
        if(data.current.value == 'sell_mech_shop') then
			SellMechShopMenu(id,val)
			menu.close()
			bossMenu = nil
		end
        if(data.current.value == 'employees_menu') then
			EmployeesMainMenu(id,val)
			menu.close()
		end
        if(data.current.value == 'accounts_menu') then
			AccountsMainMenu(id,val)
			menu.close()
		end
		menu.close()
	end, function(data, menu)
		menu.close()
		bossMenu = nil
	end)
end

-- Acounts Main Menu:
function AccountsMainMenu(id,val)
	local elements = {
		{ label = Lang['account_withdraw'], value = "account_withdraw" },
		{ label = Lang['account_deposit'], value = "account_deposit" },
	}
	ESX.TriggerServerCallback('t1ger_mechanicjob:getShopAccounts', function(account)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_employees_list",
			{
				title    = "Account [$"..account.."]",
				align    = "center",
				elements = elements
			},
		function(data, menu)
			if(data.current.value == 'account_withdraw') then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_shop_withdraw_money', {
					title = "Account Money: $"..account
				}, function(data2, menu2)
					menu2.close()
					local withdrawAmount = tonumber(data2.value)
					TriggerServerEvent('t1ger_mechanicjob:withdrawMoney',id,withdrawAmount)
					MechShopManageMenu(id,val)
				end,
				function(data2, menu2)
					menu2.close()	
					AccountsMainMenu(id,val)
				end)
			end
			if(data.current.value == 'account_deposit') then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_shop_deposit_money', {
					title = "Account Money: $"..account
				}, function(data2, menu2)
					menu2.close()
					local depositAmount = tonumber(data2.value)
					TriggerServerEvent('t1ger_mechanicjob:depositMoney',id,depositAmount)
					MechShopManageMenu(id,val)
				end,
				function(data2, menu2)
					menu2.close()	
					AccountsMainMenu(id,val)
				end)
			end
			menu.close()
		end, function(data, menu)
			menu.close()
			MechShopManageMenu(id,val)
		end)
	end, id)
end

-- Employees Main Menu:
function EmployeesMainMenu(id,val)
	local elements = {
		{ label = Lang['hire_employee'], value = "reqruit_employee" },
		{ label = Lang['employee_list'], value = "employee_list" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_employees_main",
		{
			title    = "Mech Shop [Employees]",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'reqruit_employee') then
			menu.close()
			ESX.TriggerServerCallback('t1ger_mechanicjob:getOnlinePlayers', function(players)
				local elements = {}
				for i=1, #players, 1 do
					table.insert(elements, {
						label = players[i].name,
						value = players[i].source,
						name = players[i].name,
						identifier = players[i].identifier
					})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mech_shop_reqruit_player', {
					title    = "Recruit Employee",
					align    = 'center',
					elements = elements
				}, function(data2, menu2)
					-- YES / NO OPTION:
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mech_shop_reqruit_confirm', {
						title    = "Recruit: "..data2.current.name,
						align    = 'center',
						elements = {
							{label = Lang['button_no'],  value = 'no'},
							{label = Lang['button_yes'], value = 'yes'}
						}
					}, function(data3, menu3)
						menu2.close()
						if data3.current.value == 'yes' then
							menu3.close()
							local jobGrade = 0
							TriggerServerEvent('t1ger_mechanicjob:reqruitEmployee',id,data2.current.identifier,jobGrade,data2.current.name)
							EmployeesMainMenu(id,val)
						end
					end, function(data3, menu3)
						menu3.close()
						EmployeesMainMenu(id,val)
					end)

				end, function(data2, menu2)
					menu2.close()
					EmployeesMainMenu(id,val)
				end)
			end)
		end
        if(data.current.value == 'employee_list') then
			OpenEmployeeListMenu(id,val)
			menu.close()
		end
	end, function(data, menu)
		menu.close()
		MechShopManageMenu(id,val)
	end)
end

-- Employe List Menu
function OpenEmployeeListMenu(id,val)
	local elements = {}
	ESX.TriggerServerCallback('t1ger_mechanicjob:getEmployees', function(employees)
		if employees ~= nil then 
			for k,v in pairs(employees) do
				table.insert(elements,{label = v.firstname.." "..v.lastname, identifier = v.identifier, jobGrade = v.jobGrade, data = v})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_employees_list",
				{
					title    = "Employee List",
					align    = "center",
					elements = elements
				},
			function(data, menu)
				OpenEmployeeData(data.current,data.current.data,id,val)
				menu.close()
			end, function(data, menu)
				menu.close()
				EmployeesMainMenu(id,val)
			end)
		else
			ShowNotifyESX(Lang['no_employees_hired'])
		end

	end, id)
end

-- Get Employee Menu Data
function OpenEmployeeData(info,user,id,val)
	local elements = {
		{ label = Lang['fire_employee'], value = "fire_employee" },
		{ label = Lang['employee_job_grade'], value = "job_grade_manage" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_employee_data_menu",
		{
			title    = "Employee: "..user.firstname,
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'fire_employee') then
			TriggerServerEvent('t1ger_mechanicjob:fireEmployee',id,user.identifier)
			menu.close()
			EmployeesMainMenu(id,val)
		end
		if(data.current.value == 'job_grade_manage') then
			menu.close()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_shop_update_new_job_grade', {
				title = "Current Job Grade: "..user.jobGrade
			}, function(data2, menu2)
				menu2.close()
				local newJobGrade = tonumber(data2.value)
				TriggerServerEvent('t1ger_mechanicjob:updateEmployeJobGrade',id,user.identifier,newJobGrade)
				EmployeesMainMenu(id,val)
			end,
			function(data2, menu2)
				menu2.close()	
				EmployeesMainMenu(id,val)
			end)
		end
	end, function(data, menu)
		menu.close()
		OpenEmployeeListMenu(id,val)
	end)
end

-- Sell Mech Shop:
function SellMechShopMenu(id,val)
	local sellPrice = (val.price * Config.SellPercent)
	local elements = {
		{ label = Lang['button_yes'], value = "confirm_sale" },
		{ label = Lang['button_no'], value = "decline_sale" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_sell_menu",
		{
			title    = "Confirm Sale | Price: $"..math.floor(sellPrice),
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'confirm_sale') then
			ESX.TriggerServerCallback('t1ger_mechanicjob:sellMechShop', function(sold)
				if sold then
					TriggerServerEvent('t1ger_mechanicjob:fetchMechShops')
					ShowNotifyESX((Lang['mech_shop_sold']):format(math.floor(sellPrice)))
				else
					ShowNotifyESX(Lang['not_your_mech_shop'])
				end
			end, id, val, math.floor(sellPrice))
			menu.close()
		end
		if(data.current.value == 'decline_sale') then
			menu.close()
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

-- Buy Mech Shop:
function BuyMechShopMenu(id,val)
	local elements = {
		{ label = Lang['button_yes'], value = "confirm_purchase" },
		{ label = Lang['button_no'], value = "decline_purchase" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_purchase",
		{
			title    = "Confirm | Price: $"..math.floor(val.price),
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'confirm_purchase') then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_shop_choose_name', {
				title = "Enter Name For Mech Shop"
			}, function(data2, menu2)
				menu2.close()
				local shopName = tostring(data2.value)
				ESX.TriggerServerCallback('t1ger_mechanicjob:buyMechShop', function(purchased)
					if purchased then
						ShowNotifyESX((Lang['mech_shop_bought']):format(math.floor(val.price)))
						TriggerServerEvent('t1ger_mechanicjob:fetchMechShops')
						menu.close()
						bossMenu = nil
					else
						ShowNotifyESX(Lang['not_enough_money'])
						menu.close()
						bossMenu = nil
					end
				end, id, val, shopName)
			end,
			function(data2, menu2)
				menu2.close()	
			end)
		end
		if(data.current.value == 'decline_purchase') then
			menu.close()
			bossMenu = nil
		end
		menu.close()
	end, function(data, menu)
		menu.close()
		bossMenu = nil
	end)
end
-- ## BOSS MENU END ## --

-- ## STORAGE MENU START ## --
function storageMenuFunction(k,v,distToStorage)
	if storageMenu ~= nil then
		distToStorage = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, storageMenu.storage[1], storageMenu.storage[2], storageMenu.storage[3], false)
		while storageMenu ~= nil and distToStorage > 2.0 do
			storageMenu = nil
			Citizen.Wait(1)
		end
		if storageMenu == nil then
			ESX.UI.Menu.CloseAll()
		end
	else
		local mk = Config.MarkerSettings
		if distToStorage <= 10.0 and distToStorage >= 2.0 then
			if mk.enable then
				DrawMarker(mk.type, v.storage[1], v.storage[2], v.storage[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
			end
		elseif distToStorage <= 2.0 then
			DrawText3Ds( v.storage[1], v.storage[2], v.storage[3], Lang['press_to_storage'])
			if IsControlJustPressed(0, 38) then
				ESX.TriggerServerCallback('t1ger_mechanicjob:checkAccess', function(hasAccess)
					if hasAccess then 
						storageMenu = v
						MechShopStorageMenu(k,v)
					else
						ShowNotifyESX(Lang['no_access'])
					end
				end, k)
			end
		end
	end
end

-- Storage Menu:
function MechShopStorageMenu(id, val)
    if not IsEntityPlayingAnim(player, 'mini@repair', 'fixing_a_player', 3) then
        LoadAnim('mini@repair') 
        TaskPlayAnim(player, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
	local keyPressed = false
    ESX.UI.Menu.CloseAll()
	local elements = {
		{ label = Lang['storage_deposit'], value = "storage_deposit" },
		{ label = Lang['storage_withdraw'], value = "storage_withdraw" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_storage_menu",
		{
			title    = "Storage ["..id.."]",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'storage_deposit') then
			ESX.TriggerServerCallback('t1ger_mechanicjob:getUserInventory', function(inventory)
				local invItems = {}
				for k,v in pairs(inventory) do
					if v.count > 0 then 
						table.insert(invItems, {label = v.count.."x "..v.label, value = v.name})
					end
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_storage_deposit",
					{
						title    = "User Inventory",
						align    = "center",
						elements = invItems
					},
				function(data2, menu2)
					menu2.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'storage_deposit_dialog', {title = "Enter Amount"}, function(data3, menu3)
                        local count = tonumber(data3.value)

                        if count == nil then
                            ShowNotifyESX(Lang['invalid_amount'])
                        else
							if count > 0 then
								menu3.close()
								if not keyPressed then
									keyPressed = true
									TriggerServerEvent('t1ger_mechanicjob:depositItem', data2.current.value, tonumber(data3.value), id)
								end
								Wait(500)
								MechShopStorageMenu(id, val)
                            else
                                ShowNotifyESX(Lang['invalid_amount'])
                            end
                        end
                    end, function(data3, menu3)
                        menu3.close()
						MechShopStorageMenu(id, val)
                    end)
				end, function(data2, menu2)
                    menu2.close()
					MechShopStorageMenu(id, val)
                end)
			end)
		end
		if(data.current.value == 'storage_withdraw') then
			ESX.TriggerServerCallback('t1ger_mechanicjob:getStorageInventory', function(inventory)
				if inventory ~= nil then 
					local invItems = {}
					for k,v in pairs(inventory) do
						table.insert(invItems, {label = v.count.."x "..v.label, value = v.item, amount = v.count})
					end
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_shop_storage_withdraw",
						{
							title    = "Storage Inventory",
							align    = "center",
							elements = invItems
						},
					function(data2, menu2)
						menu2.close()
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'storage_withdraw_dialog', {title = "Enter Amount"}, function(data3, menu3)
							local count = tonumber(data3.value)

							if count == nil then
								ShowNotifyESX(Lang['invalid_amount'])
							else
								if count > 0 then
									menu3.close()
									if count <= data2.current.amount then
										if not keyPressed then 
											keyPressed = true
											TriggerServerEvent('t1ger_mechanicjob:withdrawItem', data2.current.value, tonumber(data3.value), id)
										end
									else
										ShowNotifyESX(Lang['too_high_count'])
									end
									Wait(500)
									MechShopStorageMenu(id, val)
								else
									ShowNotifyESX(Lang['invalid_amount'])
								end
							end
						end, function(data3, menu3)
							menu3.close()
							MechShopStorageMenu(id, val)
						end)
					end, function(data2, menu2)
						menu2.close()
						MechShopStorageMenu(id, val)
					end)
				else
					ShowNotifyESX(Lang['storage_inv_empty'])
				end
			end, id)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
		storageMenu = nil
		ClearPedSecondaryTask(player)
	end)
end
-- ## STORAGE MENU END ## --

-- ## WORKBENCH MENU START ## --
function workbenchMenuFunction(k,v,distToWorkbench)
	if workbenchMenu ~= nil then
		distToWorkbench = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, workbenchMenu.workbench[1], workbenchMenu.workbench[2], workbenchMenu.workbench[3], false)
		while workbenchMenu ~= nil and distToWorkbench > 2.0 do
			workbenchMenu = nil
			Citizen.Wait(1)
		end
		if workbenchMenu == nil then ESX.UI.Menu.CloseAll() end
	else
		local mk = Config.MarkerSettings
		if distToWorkbench <= 10.0 and distToWorkbench >= 2.0 then
			if mk.enable then
				DrawMarker(mk.type, v.workbench[1], v.workbench[2], v.workbench[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
			end
		elseif distToWorkbench <= 2.0 then
			DrawText3Ds( v.workbench[1], v.workbench[2], v.workbench[3], Lang['press_to_workbench'])
			if IsControlJustPressed(0, 38) then
				ESX.TriggerServerCallback('t1ger_mechanicjob:checkAccess', function(hasAccess)
					if hasAccess then 
						workbenchMenu = v
						MechShopWorkbenchMenu(k,v)
					else
						ShowNotifyESX(Lang['no_access'])
					end
				end, k)
			end
		end
	end
end

-- Workbench Menu:
function MechShopWorkbenchMenu(id,val)
    if not IsEntityPlayingAnim(player, 'mini@repair', 'fixing_a_player', 3) then
        LoadAnim('mini@repair') 
        TaskPlayAnim(player, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
	local keyPressed = false
	ESX.UI.Menu.CloseAll()
	
	local elements = {}
	for k,v in ipairs(Config.Workbench) do
		table.insert(elements, {label = v.label, item = v.item, recipe = v.recipe})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_workbench_menu",
		{
			title    = "Select Craftable",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		local selected = data.current
		local craftOptions = {
			{ label = Lang['craft_item'], value = "craft_item" },
			{ label = Lang['view_recipe'], value = "view_recipe" },
		}
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_workbench_options_menu",
			{
				title    = "Craftable: "..data.current.label,
				align    = "center",
				elements = craftOptions
			},
		function(data2, menu2)
			if data2.current.value == "craft_item" then 
				menu2.close()
				if not keyPressed then 
					keyPressed = true
					exports['progressBars']:startUI((Config.CraftTime * 1000), (Lang['crafting_item']:format(string.upper(selected.label))))
					Citizen.Wait((Config.CraftTime * 1000))
					TriggerServerEvent('t1ger_mechanicjob:craftItem', selected.label, selected.item, selected.recipe, id, val)
					Wait(500)
					ESX.UI.Menu.CloseAll()
					workbenchMenu = nil
					ClearPedSecondaryTask(player)
				else
					MechShopWorkbenchMenu(id,val)
					ShowNotifyESX(Lang['crafting_in_progress'])
				end
			elseif data2.current.value == "view_recipe" then
				menu2.close()
				ViewCraftingRecipe(selected.label, selected.item, selected.recipe, id, val)
			end
		end, function(data2, menu2)
            menu2.close()
			MechShopWorkbenchMenu(id, val)
        end)
		menu.close()
	end, function(data, menu)
		menu.close()
		workbenchMenu = nil
		ClearPedSecondaryTask(player)
	end)
end

-- View Recipe Function:
function ViewCraftingRecipe(item_label, item, recipe, id, val)
	local elements = {}
	for k,v in ipairs(recipe) do
		local material = Config.Materials[v.id]
		table.insert(elements, {label = material.label.." ["..v.qty.." pcs]", name = material.label, item = material.item, amount = v.qty})
	end
	table.insert(elements, {label = Lang['button_return'], value = "menu_return"})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_workbench_recipe_menu",
		{
			title    = "Recipe for: "..item_label,
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if data.current.value == "menu_return" then 
			menu.close()
			MechShopWorkbenchMenu(id, val)
		end
	end, function(data, menu)
		menu.close()
		MechShopWorkbenchMenu(id, val)
	end)
end

-- ## WORKBENCH MENU END ## --

vehOnLift = {}
-- Lift Thread Function:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if PlayerData.job and PlayerData.job.name == 'mechanic' then
			for num,shop in pairs(Config.MechanicShops) do
				local shopDist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, shop.menuPos[1], shop.menuPos[2], shop.menuPos[3], false)
				if shopDist < 20.0 then
					for k,v in pairs(shop.lifts) do
						local mk = v.marker
						-- Attach Vehicle to Lift:
						local liftDist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.entry[1], v.entry[2], v.entry[3], false)
						if liftDist < mk.drawDist and IsPedInAnyVehicle(player, 1) then
							if mk.enable and liftDist > 2.0 then
								DrawMarker(mk.type, v.entry[1], v.entry[2], v.entry[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
							end
							if liftDist < 2.0 then
								if not v.inUse then 
									DrawText3Ds(v.entry[1], v.entry[2], v.entry[3], Lang['park_on_lift'])
									if IsControlJustPressed(0, 38) then
										local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
										v.currentVeh = curVehicle
										v.inUse = true
										TaskLeaveVehicle(player, v.currentVeh, 0)
										Citizen.Wait(2000)
										SetEntityCoordsNoOffset(v.currentVeh, v.pos[1], v.pos[2], v.pos[3], true, false, false, true)
										SetEntityHeading(v.currentVeh, v.pos[4])
										SetVehicleOnGroundProperly(v.currentVeh)
										FreezeEntityPosition(v.currentVeh, true)
										local newVehPos = GetEntityCoords(v.currentVeh)
										v.pos[3] = newVehPos.z
										vehOnLift[plate] = {entity = v.currentVeh, pos = v.pos, plate = plate, health = {}}
										TriggerServerEvent('t1ger_mechanicjob:liftStateSV', num, k, v, v.currentVeh, true)
										break
									end
								else
									DrawText3Ds(v.entry[1], v.entry[2], v.entry[3], Lang['lift_occupied'])
								end
							end
						end
						-- Detach Vehicle or Move Up/Down:
						local controlDist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.control[1], v.control[2], v.control[3], false)
						if controlDist < mk.drawDist and not IsPedInAnyVehicle(player, 1) then 
							if mk.enable and controlDist > 1.5 then
								DrawMarker(mk.type, v.control[1], v.control[2], v.control[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
							end
							if controlDist < 1.5 then
								if v.inUse then 
									DrawText3Ds(v.control[1], v.control[2], v.control[3], Lang['remove_or_move_veh'])
									if IsControlJustPressed(0, 47) then
										Citizen.Wait(1000)
										FreezeEntityPosition(v.currentVeh, false)
										SetEntityCoords(v.currentVeh, v.entry[1], v.entry[2], v.entry[3], 1, 0, 0, 1)
										local plate = GetVehicleNumberPlateText(v.currentVeh):gsub("^%s*(.-)%s*$", "%1")
										vehOnLift[plate] = nil
										v.currentVeh = nil
										v.inUse = false
										TriggerServerEvent('t1ger_mechanicjob:liftStateSV', num, k, v, v.currentVeh, false)
										break
									elseif IsControlJustPressed(0, 172) then 
										if v.pos[3] < v.maxValue then 
											v.pos[3] = v.pos[3] + 0.1
											SetEntityCoordsNoOffset(v.currentVeh, v.pos[1], v.pos[2], v.pos[3], 1, 0, 0, 1)
											Wait(100)
										else
											ShowNotifyESX(Lang['lift_cannot_go_higher'])
										end
									elseif IsControlJustPressed(0, 173) then 
										if v.pos[3] > v.minValue then
											v.pos[3] = v.pos[3] - 0.1
											SetEntityCoordsNoOffset(v.currentVeh, v.pos[1], v.pos[2], v.pos[3], 1, 0, 0, 1)
											Wait(100)
										else
											ShowNotifyESX(Lang['lift_cannot_go_lower'])
										end
									end
								else
									DrawText3Ds(v.control[1], v.control[2], v.control[3], Lang['no_veh_to_control'])
								end
							end
						end
					end
				end
			end
		end
	end
end)

-- Mechanic Action Thread:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if IsControlJustPressed(0, Config.KeyToMechActionMenu) then
			if PlayerData.job and PlayerData.job.name == 'mechanic' then
				OpenMechanicActionMenu()
			end
		end
	end
end)

-- Mechanic Action Menu:
function OpenMechanicActionMenu()
	if PlayerData.job and PlayerData.job.name == "mechanic" then
		local elements = {
			{ label = "Billing", value = "mech_billing" },
			{ label = "Use Car Jack", value = "use_car_jack" },
			{ label = "Inspect Vehicle", value = "inspect_vehicle" },
			{ label = "Repair Health Parts", value = "repair_health_parts" },
			{ label = "Vehicle Engine Repair", value = "veh_engine_repair" },
			{ label = "Vehicle Body Repair", value = "veh_body_repair" },
			{ label = "Prop Emotes", value = "prop_emotes" },
			{ label = "NPC Jobs", value = "npc_jobs" },
		}
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mechanic_action_main_menu",
			{
				title    = "Mechanic Menu",
				align    = "center",
				elements = elements
			},
		function(data, menu)
			if(data.current.value == 'mech_billing') then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mechanic_billing_dialog', {
					title = "Invoice Amount"
				}, function(data2, menu2)
					menu2.close()
					local amount = tonumber(data2.value)
					if amount ~= nil then 
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ShowNotifyESX(Lang['no_players_nearby'])
						else
							TriggerServerEvent('t1ger_mechanicjob:sendBill', GetPlayerServerId(closestPlayer), amount)
						end
					else
						ShowNotifyESX(Lang['invalid_amount'])
					end
				end,
				function(data2, menu2)
					menu2.close()	
					OpenMechanicActionMenu()
				end)
			end
			if(data.current.value == 'inspect_vehicle') then
				menu.close()
				InspectVehicleFunction()
			end
			if(data.current.value == 'veh_engine_repair') then
				menu.close()
				RepairVehicleEngine()
			end
			if(data.current.value == 'repair_health_parts') then
				menu.close()
				RepairVehicleHealthPart()
			end
			if(data.current.value == 'veh_body_repair') then
				menu.close()
				CarJackFunction('analyse')
			end
			if(data.current.value == 'use_car_jack') then
				menu.close()
				CarJackFunction('interact')
			end
			if(data.current.value == 'prop_emotes') then
				if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
					menu.close()
					CarryObjectsMainMenu()
				else
					ShowNotifyESX("Does not work inside vehicle")
				end
			end
			if(data.current.value == 'npc_jobs') then
				menu.close()
				ManageNpcJobs()
			end
		end, function(data, menu)
			menu.close()
		end)
	end
end

carryModel = 0
holdingObj = false
function CarryObjectsMainMenu()
	local elements = {}
	for k,v in pairs(Config.PropEmotes) do
		table.insert(elements, {label = v.label, prop = v.model, bone = v.bone, pos = v.pos, rot = v.rot})
	end
	table.insert(elements, {label = "Remove Obj", value = "remove_obj"})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mechanic_prop_emotes_menu",
		{
			title    = "Prop Emotes",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if data.current.value == "remove_obj" then
			menu.close()
			local coords = GetEntityCoords(GetPlayerPed(-1))
			ClearPedTasks(PlayerPedId())
			ClearPedSecondaryTask(PlayerPedId())
			Citizen.Wait(250)
			DetachEntity(carryModel)
			local allObjects = {"prop_roadcone02a", "prop_tool_box_04", "prop_cs_trolley_01", "prop_engine_hoist"}
			for i = 1, #allObjects, 1 do
				local object = GetClosestObjectOfType(coords, 2.5, GetHashKey(allObjects[i]), false, false, false)
				if DoesEntityExist(object) then
					DeleteObject(object)
				end
			end
			CarryObjectsMainMenu()
		else
			menu.close()
			local coords = GetEntityCoords(GetPlayerPed(-1))
			local selct = data.current
			carryModel = 0
			holdingObj = true
			if selct.prop == "prop_cs_trolley_01" or selct.prop == "prop_engine_hoist" then PlayPushObjAnim() end
			ESX.Game.SpawnObject(selct.prop, {x = coords.x, y = coords.y, z = coords.z}, function(spawnModel)
				carryModel = spawnModel
				local boneIndex = GetPedBoneIndex(PlayerPedId(), selct.bone)
				local pX, pY, pZ, rX, rY, rZ = round(selct.pos[1],2), round(selct.pos[2],2), round(selct.pos[3],2), round(selct.rot[1],2), round(selct.rot[2],2), round(selct.rot[3],2)
				AttachEntityToEntity(carryModel, PlayerPedId(), boneIndex, pX, pY, pZ, rX, rY, rZ, true, true, false, true, 2, 1)
			end)
		end
	end, function(data, menu)
		menu.close()
		OpenMechanicActionMenu()
	end)
end

Citizen.CreateThread( function()
    while true do 
		Citizen.Wait(5)
		if IsControlJustPressed(0, Config.KeyToPushPickUpObjs) and carryModel ~= 0 then
			if PlayerData.job and PlayerData.job.name == 'mechanic' then
				local placedObjs = {"prop_roadcone02a", "prop_tool_box_04", "prop_cs_trolley_01", "prop_engine_hoist"}
				local coords, nearDist = GetEntityCoords(GetPlayerPed(-1)), -1
				carryModel = nil
				local objName, zk = nil, Config.PropEmotes
				for i = 1, #placedObjs, 1 do
					local object = GetClosestObjectOfType(coords, 1.5, GetHashKey(placedObjs[i]), false, false, false)
					if DoesEntityExist(object) then
						local objCoords = GetEntityCoords(object)
						local objDist  = GetDistanceBetweenCoords(coords, objCoords, true)
						if nearDist == -1 or nearDist > objDist then nearDist = objDist; carryModel = object; objName = placedObjs[i] end
					end
				end
				if holdingObj then 
					holdingObj = false
					if (objName == 'prop_roadcone02a') or (objName == 'prop_tool_box_04') then PlayPickUpAnim() end
					Citizen.Wait(250)
					DetachEntity(carryModel)
					ClearPedTasks(PlayerPedId())
					ClearPedSecondaryTask(PlayerPedId())
				else
					local Dist = GetDistanceBetweenCoords(GetEntityCoords(carryModel), GetEntityCoords(PlayerPedId()), true)
					if Dist < 1.75 then
						holdingObj = true
						if (objName == 'prop_roadcone02a') or (objName == 'prop_tool_box_04') then PlayPickUpAnim() end
						Citizen.Wait(250)
						ClearPedTasks(PlayerPedId())
						ClearPedSecondaryTask(PlayerPedId())
						if (objName == 'prop_cs_trolley_01') or (objName == 'prop_engine_hoist') then 
							PlayPushObjAnim()
						end
						Citizen.Wait(250)
						AttachEntityToEntity(carryModel, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), zk[objName].bone), zk[objName].pos[1], zk[objName].pos[2], zk[objName].pos[3], zk[objName].rot[1], zk[objName].rot[2], zk[objName].rot[3], true, true, false, true, 2, 1)

					end
				end
			end
		end
	end
end)

function PlayPushObjAnim()
	LoadAnim("anim@heists@box_carry@")
	TaskPlayAnim((PlayerPedId()), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function PlayPickUpAnim()
	LoadAnim("random@domestic")
	TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
end

function RepairVehicleEngine()
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	local repairingEngine = false
	if vehicle ~= 0 then 
		if vehOnLift[plate] ~= nil then 
			if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then 
				local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
				local enginePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0)
				local distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true)) 

				while true do 
					Citizen.Wait(1)
					distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
					if distance < 5.0 then
						DrawText3Ds(enginePos.x, enginePos.y, enginePos.z, Lang['repair_engine'])
						if IsControlJustPressed(0, 38) and distance < 1.0 then
							-- inspect anim:
							TaskTurnPedToFaceEntity(player, vehicle, 1.0)
							Citizen.Wait(1000)
							TaskStartScenarioInPlace(player, "WORLD_HUMAN_CLIPBOARD", 0, true)
							exports['progressBars']:startUI(2000, "INSPECTING: ENGINE")
							Citizen.Wait(2000)
							ClearPedTasks(player)
							local engineValue = (round((GetVehicleEngineHealth(vehicle)/10)/10,2))
							if engineValue < 10.0 then 
								local engineMaterials = {}
								for g,h in pairs(Config.HealthParts) do 
									if h.degName == "engine" then
										local array = {}
										engineMaterials = h.materials
										for k,v in pairs(h.materials) do 
											local item = Config.Materials[v.id]
											table.insert(array, item.label)
										end
										local items = table.concat(array,", ")
										local chatMsg = "^*"..h.label.." ^5[^6"..items.."^5] ^0» ^3"..round(engineValue,2).."^0 / ^210.0^0"
										TriggerEvent('chat:addMessage', { args = { chatMsg } })
									end
								end
								local engineAddVal = 0
								local newValue = 10.0
								local difference = (newValue - engineValue)
								if difference > 0 and difference <= 1.0 then engineAddVal = 1.0 else engineAddVal = math.floor(difference + 1.0) end
								ESX.TriggerServerCallback('t1ger_mechanicjob:getMaterialsForHealthRep', function(hasMaterials)
									if hasMaterials then 
										-- repair anim:
										SetEntityHeading(player, GetEntityHeading(vehicle))
										Citizen.Wait(500)
										TaskStartScenarioInPlace(player, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
										exports['progressBars']:startUI(3500, "REPAIRING: ENGINE")
										Citizen.Wait(3500)
										SetVehicleEngineHealth(vehicle, 1000.0)
										ClearPedTasks(player)
									else
										ShowNotifyESX(Lang['need_more_materials'])
									end
								end, plate, "engine", engineMaterials, 10.0, engineAddVal, vehOnLift)
							else
								ShowNotifyESX("Engine is fully functional")
							end
							break
						end
					end
					if distance > 5.0 then 
						repairingEngine = false
						break
					end
				end
			else
				print("veh not matched, contact t1ger#9080")
			end
		else
			ShowNotifyESX(Lang['veh_must_be_on_lift'])
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
end

function RepairVehicleHealthPart()
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	if vehicle ~= 0 then 
		if vehOnLift[plate] ~= nil then 
			if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then 
				if vehOnLift[plate].health ~= nil then
					local elements = {}
					for k,v in pairs(Config.HealthParts) do
						table.insert(elements, {label = v.label, degName = v.degName, materials = v.materials})
					end
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), "veh_health_part_menu",
						{
							title    = "Select Repair Part",
							align    = "center",
							elements = elements
						},
					function(data, menu)
						menu.close()
						local selected = data.current
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mech_veh_health_part_dialog', {
							title = "Select Health Value"
						}, function(data2, menu2)
							menu2.close()
							local newValue = tonumber(data2.value)
							if vehOnLift[plate].health[selected.degName] ~= nil then 
								if newValue > 10.0 then 
									ShowNotifyESX(Lang['health_part_exceeded'])
								elseif newValue < vehOnLift[plate].health[selected.degName].value then 
									ShowNotifyESX(Lang['not_decrease_health_val'])
								else
									local difference = (newValue - vehOnLift[plate].health[selected.degName].value)
									local valueToAdd = 0
									if difference <= 0 then
										ShowNotifyESX(Lang['not_decrse_or_same_val'])
									else
										if difference > 0 and difference <= 1.0 then 
											valueToAdd = 1.0
										else 
											valueToAdd = math.floor(difference + 1.0)
										end
										RepairSelectedHealthPart(plate, selected.label, selected.degName, selected.materials, newValue, valueToAdd)
									end
								end
							else
								ShowNotifyESX(Lang['veh_must_be_inspected'])
							end
						end,
						function(data2, menu2)
							menu2.close()	
							RepairVehicleHealthPart()
						end)
					end, function(data, menu)
						menu.close()
					end)
				else
					ShowNotifyESX(Lang['veh_must_be_inspected'])
				end
			else
				print("veh not matched, contact t1ger#9080")
			end
		else
			ShowNotifyESX(Lang['veh_must_be_on_lift'])
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
end

function RepairSelectedHealthPart(plate, label, degName, materials, newValue, addValue)
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	local repairingPart = false
	if vehicle ~= 0 then 

		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local enginePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0)
		local distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true)) 

		while true do 
			Citizen.Wait(1)
			distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
			if distance < 5.0 then
				DrawText3Ds(enginePos.x, enginePos.y, enginePos.z, Lang['health_rep_here'])
				if IsControlJustPressed(0, 38) and distance < 1.0 then
					SetEntityHeading(player, GetEntityHeading(vehicle))
					Citizen.Wait(500)
					TaskStartScenarioInPlace(player, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
					exports['progressBars']:startUI(3500, (Lang['lift_repairing_veh']:format(string.upper(label))))
					Citizen.Wait(3500)
					ClearPedTasks(player)
					ESX.TriggerServerCallback('t1ger_mechanicjob:getMaterialsForHealthRep', function(hasMaterials)
						if hasMaterials then 
							vehOnLift[plate].health[degName].value = round(newValue,2)
							TriggerServerEvent('t1ger_mechanicjob:updateVehDegradation', plate, label, degName, vehOnLift)
							if degName == "engine" then
								local engineValue = round((vehOnLift[plate].health[degName].value * 10)*10,2)
								SetVehicleEngineHealth(vehicle, engineValue)
							end
						else
							ShowNotifyESX(Lang['need_more_materials'])
						end
					end, plate, degName, materials, newValue, addValue, vehOnLift)
					break
				end
			end
			if distance > 5.0 then 
				repairingPart = false
				break
			end
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
end

function InspectVehicleFunction()
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	if vehicle ~= 0 then 
		if vehOnLift[plate] ~= nil then 
			if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then 
				local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
				local spots = {
					[1] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, d2.x+0.2,0.0,0.0), scenario = "WORLD_HUMAN_CLIPBOARD", done = false},
					[2] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0), scenario = "WORLD_HUMAN_CLIPBOARD", done = false},
					[3] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, d1.x-0.2,0.0,0.0), scenario = "WORLD_HUMAN_CLIPBOARD", done = false},
				}
				local inspectingVeh = false
				while true do
					Citizen.Wait(1)
					local vehPos = GetEntityCoords(vehicle, 1)
					if not inspectingVeh then
						for k,v in pairs(spots) do
							local distance = (GetDistanceBetweenCoords(GetEntityCoords(player), vector3(v.pos.x, v.pos.y, v.pos.z), true))
							if distance < 4.0 then
								if not v.done then 
									DrawText3Ds(v.pos.x, v.pos.y, v.pos.z, Lang['inspect_here'])
									if IsControlJustPressed(0, 38) and distance < 1.0 then
										TaskTurnPedToFaceEntity(player, vehicle, 1.0)
										Citizen.Wait(1000)
										TaskStartScenarioInPlace(player, v.scenario, 0, true)
										exports['progressBars']:startUI(1500, Lang['progbar_inspecting_veh'])
										Citizen.Wait(1500)
										ClearPedTasksImmediately(player)
										v.done = true
									end
								end
							end
						end
						if spots[1].done and spots[2].done and spots[3].done then
							inspectingVeh = true
							Wait(200)
							break
						end
					end
				end

				ESX.TriggerServerCallback('t1ger_mechanicjob:getVehDegradation', function(degradation)
					local vehHealth = {}
					if degradation ~= nil then 
						-- insert values into health array:
						for k,v in pairs(degradation) do
							local partValue = (round(v.value/10,2))
							if v.part == "engine" then partValue = (round((GetVehicleEngineHealth(vehicle)/10)/10,2)) end
							-- Get materials:
							for g,h in pairs(Config.HealthParts) do 
								if h.degName == v.part then
									vehHealth[v.part] = {value = partValue, materials = h.materials}
									local array = {}
									for k,v in pairs(h.materials) do 
										local item = Config.Materials[v.id]
										table.insert(array, item.label)
									end
									local items = table.concat(array,", ")
									local chatMsg = "^*"..h.label.." ^5[^6"..items.."^5] ^0» ^3"..round(partValue,2).."^0 / ^210.0^0"
									TriggerEvent('chat:addMessage', { args = { chatMsg } })
								end
							end
						end
						vehOnLift[plate].health = vehHealth
					else
						ShowNotifyESX("Works with only player owned vehicles.")
					end
				end, plate)
			else
				print("veh not matched, contact t1ger#9080")
			end
		else
			ShowNotifyESX(Lang['veh_must_be_on_lift'])
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
end

usingJack 	= false
isJackRaised 	= false
carJackObj	= nil
vehicleData = {}
wheelProperties = {}
vehAnalysed = false
function CarJackFunction(type)
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)

	if vehicle ~= 0 then 
		if usingJack then return end 
		usingJack = true

		GetControlOfEntity(vehicle)

		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local door = GetOffsetFromEntityInWorldCoords(vehicle, d2.x+0.2,0.0,0.0)
		local vehCoords = GetEntityCoords(vehicle, 1)
		local distance = (GetDistanceBetweenCoords(coords, vector3(door.x, door.y, door.z), true)) 
		
		while true do 
			Citizen.Wait(1)
			distance = (GetDistanceBetweenCoords(coords, vector3(door.x, door.y, door.z), true))
			if distance < 6.0 then
				local label = ""
				local findObj = GetClosestObjectOfType(vehCoords.x, vehCoords.y, vehCoords.z, 1.0, GetHashKey("prop_carjack"), false, false, false)
				if DoesEntityExist(findObj) then
					isJackRaised = true
					if type == 'interact' then
						label = Lang['lower_jack']
					end
					if type == 'analyse' then
						if not vehAnalysed then 
							label = "Analyse Vehicle Body"
						else
							ShowNotifyESX(Lang['veh_already_analyzed'])
							break
						end
					end
				else
					if type == 'interact' then
						isJackRaised = false
						label = Lang['raise_jack']
					elseif type == 'analyse' then 
						ShowNotifyESX(Lang['raise_veh_b4_analyze'])
						break
					end
				end
				DrawText3Ds(door.x, door.y, door.z, "~r~[E]~s~ "..label)
				if IsControlJustPressed(0, 38) and distance < 1.0 then
					if isJackRaised then
						if type == 'interact' then
							UseTheJackFunction(vehicle)
							break
						else
							if not vehAnalysed then
								local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
								vehicleData[plate] = {report = {}, entity = nil}
								wheelProperties[plate] = {}
								for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
									wheelProperties[plate][i + 1] = {
										xOffset = GetVehicleWheelXOffset(vehicle, i),
										yRotation = GetVehicleWheelYRotation(vehicle, i)
									}
								end
								FetchVehicleBodyDamageReport(vehicle, plate)
								break
							end
						end
					else
						local item = Config.CarJackItem
						ESX.TriggerServerCallback('t1ger_mechanicjob:getInventoryItem', function(hasItem)
							if hasItem then 
								UseTheJackFunction(vehicle)
							else
								ShowNotifyESX(Lang['car_jack_carry'])
							end
						end, item)
					end
					break
				end
			end
			if distance > 6.0 then 
				usingJack = false
				break
			end
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
	usingJack = false
end

function UseTheJackFunction(vehicle)
	TaskTurnPedToFaceEntity(player, vehicle, 1.0)
	Citizen.Wait(1000)
	FreezeEntityPosition(vehicle, true)
	local vehPos = GetEntityCoords(vehicle)

	if not isJackRaised then 
		SpawnJackProp(vehicle)
		Citizen.Wait(250)
	else
		if DoesEntityExist(carJackObj) then
			GetControlOfEntity(carJackObj)
			SetEntityAsMissionEntity(carJackObj)
		else
			carJackObj = GetClosestObjectOfType(vehPos.x, vehPos.y, vehPos.z, 1.2, GetHashKey("prop_carjack"), false, false, false)
			GetControlOfEntity(carJackObj)
			SetEntityAsMissionEntity(carJackObj)
		end
	end

	local objPos = GetEntityCoords(carJackObj)
	-- Request & Load Animation:
	local anim_dict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
	local anim_lib	= "weed_crouch_checkingleaves_idle_02_inspector"
	LoadAnim(anim_dict)
	-- progbar:
	local label = ''
	if isJackRaised then label = Lang['progbar_lowering_jack'] else label = Lang['progbar_raising_jack'] end
	exports['progressBars']:startUI((6500), label)
	-- Raise Jack Task:
	TaskPlayAnim(player, anim_dict, anim_lib, 2.0, -3.5, -1, 1, false, false, false, false)
	Citizen.Wait(1000)
	ClearPedTasks(player)
	local count = 5
	while true do
		vehPos = GetEntityCoords(vehicle)
		objPos = GetEntityCoords(carJackObj)
		if count > 0 then 
			TaskPlayAnim(player, anim_dict, anim_lib, 3.5, -3.5, -1, 1, false, false, false, false)
			Citizen.Wait(1000)
			ClearPedTasks(player)
			if not isJackRaised then
				SetEntityCoordsNoOffset(vehicle, vehPos.x, vehPos.y, (vehPos.z+0.10), true, false, false, true)
				SetEntityCoordsNoOffset(carJackObj, objPos.x, objPos.y, (objPos.z+0.10), true, false, false, true)
			else
				SetEntityCoordsNoOffset(vehicle, vehPos.x, vehPos.y, (vehPos.z-0.10), true, false, false, true)
				SetEntityCoordsNoOffset(carJackObj, objPos.x, objPos.y, (objPos.z-0.10), true, false, false, true)
			end
			FreezeEntityPosition(vehicle, true)
			FreezeEntityPosition(carJackObj, true)
			count = count - 1
		end
		if count <= 0 then 
			exports['progressBars']:closeUI()
			ClearPedTasks(player)
			if isJackRaised then
				FreezeEntityPosition(vehicle, false)
				if DoesEntityExist(carJackObj) then 
					DeleteEntity(carJackObj)
					DeleteObject(carJackObj)
				end
				carJackObj = nil
				isJackRaised = false
			else
				isJackRaised = true
			end
			usingJack = false
			break
		end
	end
	ClearPedTasks(player)
end

function FetchVehicleBodyDamageReport(vehicle, plate)
	-- Interact To Veh Part:
	local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
	local spots = {
		[1] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, d2.x+0.2,0.0,0.0), scenario = "WORLD_HUMAN_WELDING", done = false},
		[2] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0), scenario = "WORLD_HUMAN_VEHICLE_MECHANIC", done = false},
		[3] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, d1.x-0.2,0.0,0.0), scenario = "WORLD_HUMAN_MAID_CLEAN", done = false},
		[4] = {pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d1.y-0.2,0.0), scenario = "WORLD_HUMAN_CLIPBOARD", done = false},
	}
	while true do
		Citizen.Wait(1)
		local vehPos = GetEntityCoords(vehicle)
		for k,v in pairs(spots) do
			local distance = (GetDistanceBetweenCoords(coords, vector3(v.pos.x, v.pos.y, v.pos.z), true))
			if distance < 4.0 then
				if not v.done then 
					DrawText3Ds(v.pos.x, v.pos.y, v.pos.z, Lang['analyze_here'])
					if IsControlJustPressed(0, 38) and distance < 1.0 then
						if k == 2 then 
							SetEntityHeading(player, GetEntityHeading(vehicle))
							Citizen.Wait(500)
						else
							TaskTurnPedToFaceEntity(player, vehicle, 1.0)
							Citizen.Wait(1000)
						end
						TaskStartScenarioInPlace(player, v.scenario, 0, true)
						exports['progressBars']:startUI(2500, Lang['progbar_analyzing_veh'])
						Citizen.Wait(2500)
						ClearPedTasks(player)
						v.done = true
					end
				end
			end
		end
		if spots[1].done and spots[2].done and spots[3].done and spots[4].done then 
			break
		end
	end
	
	local damageReport = {doors = {}, wheels = {}, engine = nil, body = nil}
	-- Doors Report:
	for i = 0, GetNumberOfVehicleDoors(vehicle) + 1 do
		if IsVehicleDoorDamaged(vehicle, i) then
			damageReport.doors[i + 1] = true
			local label, doorLabel = '', ''
			if i >= 0 and i <= 3 then 
				if i == 0 then doorLabel = 'Left Front' elseif i == 1 then doorLabel = 'Right Front' elseif i == 2 then doorLabel = 'Back Left' elseif i == 3 then doorLabel = 'Back Right' end
				label = "^*Door ^5[^6"..doorLabel.."^5] ^0» ^3 Damaged ^0» ^2Replace the Door"
			end
			if i == 4 then label = "^*Door ^5[^6Hood^5] ^0» ^3 Damaged ^0» ^2Replace the Hood"
			elseif i == 5 then label = "^*Door ^5[^6Trunk^5] ^0» ^3 Damaged ^0» ^2Replace the Trunk"
			elseif i == 6 then label = "^*Door ^5[^6Trunk2^5] ^0» ^3 Damaged ^0» ^2Replace the trunk" end
			TriggerEvent('chat:addMessage', { args = { label } })
		else
			damageReport.doors[i + 1] = false
		end
	end
	-- Wheels Report:
	for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
		if i == 0 or i == 1 then 
			if IsVehicleTyreBurst(vehicle, i) or GetVehicleWheelXOffset(vehicle, i) == 9999.0 then
				damageReport.wheels[i + 1] = true
				local label = ''
				if i == 0 then
					label = "^*Wheel ^5[^6Left Front^5] ^0» ^3 Bursted ^0» ^2Replace the Wheel"
				elseif i == 1 then 
					label = "^*Wheel ^5[^6Right Front^5] ^0» ^3 Bursted ^0» ^2Replace the Wheel"
				end
				TriggerEvent('chat:addMessage', { args = { label } })
			else
				damageReport.wheels[i + 1] = false
			end
		end
		if i == 2 then 
			if IsVehicleTyreBurst(vehicle, 4) or GetVehicleWheelXOffset(vehicle, i) == 9999.0  then
				damageReport.wheels[i + 1] = true
				local label = "^*Wheel ^5[^6Back Left^5] ^0» ^3 Bursted ^0» ^2Replace the Wheel"
				TriggerEvent('chat:addMessage', { args = { label } })
			else
				damageReport.wheels[i + 1] = false
			end
		end
		if i == 3 then 
			if IsVehicleTyreBurst(vehicle, 5) or GetVehicleWheelXOffset(vehicle, i) == 9999.0 then
				damageReport.wheels[i + 1] = true
				local label = "^*Wheel ^5[^6Back Right^5] ^0» ^3 Bursted ^0» ^2Replace the Wheel"
				TriggerEvent('chat:addMessage', { args = { label } })
			else
				damageReport.wheels[i + 1] = false
			end
		end
	end
	-- Engine Report
	damageReport.engine = GetVehicleEngineHealth(vehicle)
	-- Body Report
	damageReport.body = GetVehicleBodyHealth(vehicle)
	SetVehicleCanDeformWheels(vehicle, false)
	Wait(500)
	vehicleData[plate] = {report = damageReport, entity = vehicle}
	vehAnalysed = true
	RefreshVehicleDamage(vehicleData[plate].entity, plate)
end

installingPart = false
carryObj = nil
RegisterNetEvent('t1ger_mechanicjob:installBodyPartCL')
AddEventHandler('t1ger_mechanicjob:installBodyPartCL', function(id, val)
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	if vehicle ~= 0 then 
		if vehAnalysed then else return ShowNotifyESX(Lang['analyze_veh_first']) end
		GetControlOfEntity(vehicle)
		local vehCoords = GetEntityCoords(vehicle, 1)
		local distance = GetDistanceBetweenCoords(coords, vehCoords, false)
		if not installingPart then
			if not DoesEntityExist(carryObj) then 
				local anim_dict = "anim@heists@box_carry@"
				LoadAnim(anim_dict)
				TaskPlayAnim(player, anim_dict, "idle", 6.0, -2.0, -1, 50, 0, false, false, false)
				ESX.Game.SpawnObject(val.prop, {x = coords.x, y = coords.y, z = coords.z}, function(spawnObj)
					carryObj = spawnObj
					local boneIndex = GetPedBoneIndex(player, 28422)
					AttachEntityToEntity(spawnObj, player, boneIndex, val.pos[1], val.pos[2], val.pos[3], val.rot[1], val.rot[2], val.rot[3], true, true, false, true, 1, true)
				end)
			end
			while true do 
				Citizen.Wait(1)
				distance = GetDistanceBetweenCoords(coords, vehCoords, false)
				if distance < 4.0 then
					local findObj = GetClosestObjectOfType(vehCoords.x, vehCoords.y, vehCoords.z, 1.0, GetHashKey("prop_carjack"), false, false, false)
					if DoesEntityExist(findObj) then
						DrawText3Ds(vehCoords.x, vehCoords.y, vehCoords.z, Lang['install_body_part'])
						if IsControlJustPressed(0, 47) and distance < 1.5 then
							installingPart = true
							local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
							if id == 1 then
								for i = 0, (GetNumberOfVehicleDoors(vehicleData[plate].entity) - 2) do
									if vehicleData[plate].report.doors[i + 1] == true then
										vehicleData[plate].report.doors[i + 1] = false
										TriggerServerEvent('t1ger_mechanicjob:syncVehicleBodySV', plate)
										TriggerServerEvent('t1ger_mechanicjob:removeItem', val.item, 1)
										break
									else
										if tonumber(i + 1) == tonumber(GetNumberOfVehicleDoors(vehicleData[plate].entity) - 2) then 
											ShowNotifyESX(Lang['all_doors_intact'])
											break
										end
									end
								end
							end
							if id == 2 then 
								if vehicleData[plate].report.doors[4+1] == true then
									vehicleData[plate].report.doors[4+1] = false
									TriggerServerEvent('t1ger_mechanicjob:syncVehicleBodySV', plate)
									TriggerServerEvent('t1ger_mechanicjob:removeItem', val.item, 1)
								else
									ShowNotifyESX(Lang['hood_already_installed'])
								end
							end
							if id == 3 then 
								if vehicleData[plate].report.doors[5+1] == true then
									vehicleData[plate].report.doors[5+1] = false
									TriggerServerEvent('t1ger_mechanicjob:syncVehicleBodySV', plate)
									TriggerServerEvent('t1ger_mechanicjob:removeItem', val.item, 1)
								else
									ShowNotifyESX(Lang['trunk_already_installed'])
								end
							end
							if id == 4 then 
								for i = 0, (GetVehicleNumberOfWheels(vehicleData[plate].entity) - 1) do
									if GetVehicleWheelXOffset(vehicleData[plate].entity, i) == 9999.0 then
										if vehicleData[plate].report.wheels[i + 1] == true then 
											vehicleData[plate].report.wheels[i + 1] = false
											TriggerServerEvent('t1ger_mechanicjob:syncVehicleBodySV', plate)
											TriggerServerEvent('t1ger_mechanicjob:removeItem', val.item, 1)
											break
										end
									else
										if tonumber(i + 1) == tonumber(GetVehicleNumberOfWheels(vehicleData[plate].entity) - 1) then
											ShowNotifyESX(Lang['all_wheels_intact'])
											SetVehicleCanDeformWheels(vehicle, true)
										end
									end
								end
							end
							DetachEntity(carryObj, 1, 0)
							ESX.Game.DeleteObject(carryObj)
							carryObj = nil
							ClearPedTasks(player)
							Citizen.Wait(100)

							local progression = GetBodyRepairProgression(vehicle)
							ShowNotifyESX("Progression: ["..progression.."/100]")
							if progression >= 100 then 
								SetVehicleCanDeformWheels(vehicle, true)
								Wait(100)
								SetVehicleFixed(vehicle)
								SetVehicleBodyHealth(vehicle, 1000.0)
								vehAnalysed = false
								ShowNotifyESX(Lang['all_body_repairs_done'])
							end
							break
						end
					else
						ShowNotifyESX(Lang['raise_and_analyze'])
						break
					end
				end
				if distance > 4.0 then 
					break
				end
			end
		else
			ShowNotifyESX(Lang['finish_current_install'])
		end
	else
		ShowNotifyESX(Lang['no_vehicle_nearby'])
	end
	installingPart = false
end)

function RefreshVehicleDamage(vehicle, plate)
	SetVehicleFixed(vehicle)
	for i = 0, GetNumberOfVehicleDoors(vehicle) + 1 do
		if vehicleData[plate].report.doors[i + 1] == true then
			SetVehicleDoorBroken(vehicle, i, true)
		end
	end
	if vehicleData[plate].report.engine ~= nil then
		SetVehicleEngineHealth(vehicle, tonumber(vehicleData[plate].report.engine))
	else
		SetVehicleEngineHealth(vehicle, 0)
	end
	if vehicleData[plate].report.body ~= nil then
		SetVehicleBodyHealth(vehicle, tonumber(vehicleData[plate].report.body))
	else
		SetVehicleBodyHealth(vehicle, 800)
	end
	for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
		if vehicleData[plate].report.wheels[i + 1] == true then
			SetVehicleWheelsCanBreak(vehicle, i, 0)
			SetVehicleWheelHealth(vehicle, i, 0.0)
			SetVehicleWheelXOffset(vehicle, i, 9999.0)
			SetVehicleWheelYRotation(vehicle, i, -90.0)
		else
			SetVehicleWheelsCanBreak(vehicle, i, false)
			SetVehicleWheelHealth(vehicle, i, 100.0)
			SetVehicleWheelXOffset(vehicle, i, wheelProperties[plate][i + 1].xOffset)
			SetVehicleWheelYRotation(vehicle, i, wheelProperties[plate][i + 1].yRotation)
		end
	end
	RemoveVehicleWindow(vehicle, 0)
	RemoveVehicleWindow(vehicle, 1)
	RemoveVehicleWindow(vehicle, 2)
	RemoveVehicleWindow(vehicle, 3)
end

-- On the road repairs:
local repairing = false
RegisterNetEvent('t1ger_mechanicjob:useRepairKit')
AddEventHandler('t1ger_mechanicjob:useRepairKit', function(type, val)
	local vehicle = nil

	vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)

	if vehicle ~= 0 then
		if repairing then return end
		repairing = true

		-- Get Control of Vehicle:
		local netTime = 15
        NetworkRequestControlOfEntity(vehicle)
        while not NetworkHasControlOfEntity(vehicle) and netTime > 0 do 
            NetworkRequestControlOfEntity(vehicle)
            Citizen.Wait(100)
            netTime = netTime -1
		end

		-- Get Repair Veh Position:
		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local hood = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0)
		local distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
		local vehRepaired = false

		-- Repair thread:
        while not vehRepaired do
            Citizen.Wait(1)
            distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
			DrawText3Ds(hood.x, hood.y, hood.z, Lang['repair_here'])
			if IsControlJustPressed(0, 38) then 
				if distance < 1.0 then 
					SetVehicleDoorOpen(vehicle, 4, 0, 0)
					TaskTurnPedToFaceEntity(player, vehicle, 1.0)
					Citizen.Wait(1000)
					local animDict = "mini@repair"
					LoadAnim(animDict)
					if not IsEntityPlayingAnim(player, animDict, "fixing_a_player", 3) then
						TaskPlayAnim(player, animDict, "fixing_a_player", 5.0, -5, -1, 16, false, false, false, false)
					end
					-- repair options:
					RepairVehOptions(vehicle, type, val)
					-- Chance to destroy item:
					if math.random(100) > val.chanceToKeep then
						TriggerServerEvent('t1ger_mechanicjob:removeItem', val.item, 1)
						ShowNotifyESX(Lang['repair_kit_broke'])
					end
					-- end:
					SetVehicleDoorShut(vehicle, 4, 1, 1)
					ClearPedTasks(player)
					ShowNotifyESX(Lang['repairkit_veh_repaired'])
					vehRepaired = true
					repairing = false
					break
				else
					distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
				end
			end
        end
	end
	repairing = false
end)

-- Choose repairs with repairkit:
function RepairVehOptions(veh, type, val)
	local repairDuration = (((3000-GetVehicleEngineHealth(vehicle)) - (GetVehicleBodyHealth(vehicle)/2))*2 + val.repairTime)
	exports['progressBars']:startUI((repairDuration), val.progbar)
	Citizen.Wait(repairDuration)
	if type == 1 then 
		if GetVehicleEngineHealth(veh) < 200.0 then	SetVehicleEngineHealth(veh, 200.0) end
		if GetVehicleBodyHealth(veh) < 910.0 then SetVehicleBodyHealth(veh, 910.0) end
		for i = 0, math.random(5) do SetVehicleTyreFixed(veh, i) end
	end
	if type == 2 then 
		if GetVehicleEngineHealth(veh) < 200.0 then	SetVehicleEngineHealth(veh, 450.0) end
		if GetVehicleBodyHealth(veh) < 910.0 then SetVehicleBodyHealth(veh, 975.0) end
		for i = 0, 5 do SetVehicleTyreFixed(veh, i)  end
	end
end

-- Vehicle Value Saver:
Citizen.CreateThread(function()
	Citizen.Wait(1000)
	local count = 0
	while true do
		Citizen.Wait(1000)
		if IsPedInVehicle(player, curVehicle, false) then
			count = count + 1
			if count >= Config.WaitCountForHealth then
				if player == driver then 
					local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
					local engine = math.ceil(GetVehicleEngineHealth(curVehicle))
					local body = math.ceil(GetVehicleBodyHealth(curVehicle))
					ApplyVehicledegradation(curVehicle, plate)
				end
				count = 0
			end
		end
	end
end)

function ApplyVehicledegradation(curVehicle, plate)
	ESX.TriggerServerCallback('t1ger_mechanicjob:getIfVehicleOwned', function(vehOwned)
		if vehOwned then 
			ESX.TriggerServerCallback('t1ger_mechanicjob:getVehDegradation', function(degradation)
				if degradation ~= nil then 
					local vehHealth = {}
					-- insert values into health array:
					for k,v in pairs(degradation) do
						local partValue = (round(v.value/10,2))
						vehHealth[v.part] = v.value
					end
					-- electronics:
					if vehHealth["electronics"] <= 40 then
						local chance, electronics = math.random(1,100), vehHealth["electronics"]
						if electronics <= 40 and electronics >= 25 and chance > 85 then
							for i = 0, 10 do Citizen.Wait(50) ElectronicsEffects(curVehicle) end
						end
						if electronics <= 24 and electronics >= 10 and chance > 70 then
							for i = 0, 10 do Citizen.Wait(100) ElectronicsEffects(curVehicle) end
						end
						if electronics <= 9 and electronics >= 0 and chance > 50 then
							for i = 0, 10 do Citizen.Wait(200) ElectronicsEffects(curVehicle) end
						end
					end
					-- Fuel Injector:
					if vehHealth["fuelinjector"] <= 40 then
						local chance, fuel_injector = math.random(1,100), vehHealth["fuelinjector"]
						if fuel_injector <= 40 and fuel_injector >= 25 and chance > 85 then
							FuelInjectorEffects(curVehicle, 200)
						end
						if fuel_injector <= 24 and fuel_injector >= 10 and chance > 70 then
							FuelInjectorEffects(curVehicle, 500)
						end
						if fuel_injector <= 9 and fuel_injector >= 0 and chance > 50 then
							FuelInjectorEffects(curVehicle, 1000)
						end
					end
					-- Brakes:
					if vehHealth["brakes"] <= 40 then
						local chance, brakes = math.random(1,100), vehHealth["brakes"]
						if brakes <= 40 and brakes >= 25 and chance > 85 then
							BrakesEffects(curVehicle, 1000)
						end
						if brakes <= 24 and brakes >= 10 and chance > 70 then
							BrakesEffects(curVehicle, 4000)
						end
						if brakes <= 9 and brakes >= 0 and chance > 50 then
							BrakesEffects(curVehicle, 8000)
						end
					end
					-- Radiator:
					if vehHealth["radiator"] <= 40 then
						local chance, radiator = math.random(1,100), vehHealth["radiator"]
						if radiator <= 40 and radiator >= 25 then
							RadiatorEffects(curVehicle, chance, 1000)
						end
						if radiator <= 24 and radiator >= 10 then
							RadiatorEffects(curVehicle, chance, 3000)
						end
						if radiator <= 9 and radiator >= 0 then
							RadiatorEffects(curVehicle, chance, 5000)
						end
					end
					-- Drive Shaft / Axle:
					if vehHealth["driveshaft"] <= 40 then
						local chance, axle = math.random(1,100), vehHealth["driveshaft"]
						if axle <= 40 and axle >= 25 and chance > 85 then
							DriveShaftEffects(curVehicle, 10)
						end
						if axle <= 24 and axle >= 10 and chance > 70 then
							DriveShaftEffects(curVehicle, 20)
						end
						if axle <= 9 and axle >= 0 and chance > 50 then
							DriveShaftEffects(curVehicle, 30)
						end
					end
					-- Transmission:
					if vehHealth["transmission"] <= 40 then
						local chance, transmission = math.random(1,100), vehHealth["transmission"]
						if transmission <= 40 and transmission >= 25 and chance > 85 then
							TransmissionEffects(curVehicle, 5, 2)
						end
						if transmission <= 24 and transmission >= 10 and chance > 70 then
							TransmissionEffects(curVehicle, 10, 4)
						end
						if transmission <= 9 and transmission >= 0 and chance > 50 then
							TransmissionEffects(curVehicle, 20, 8)
						end
					end
					-- Clutch:
					if vehHealth["clutch"] <= 40 then
						local chance, clutch = math.random(1,100), vehHealth["clutch"]
						if clutch <= 40 and clutch >= 25 and chance > 85 then
							ClutchEffects(curVehicle, 1500, 75)
						end
						if clutch <= 24 and clutch >= 10 --[[and chance > 70]] then
							ClutchEffects(curVehicle, 3000, 150)
						end
						if clutch <= 9 and clutch >= 0 and chance > 50 then
							ClutchEffects(curVehicle, 6000, 300)
						end
					end
				else
					return
				end
			end, plate)
		else
			return
		end
	end, plate)
end

function ElectronicsEffects(entity)
	local radios = {"RADIO_03_HIPHOP_NEW","RADIO_04_PUNK","RADIO_05_TALK_01","RADIO_14_DANCE_02","RADIO_20_THELAB","RADIO_17_FUNK","RADIO_18_90S_ROCK"}
	SetVehicleLights(entity, 1)
	SetVehRadioStation(entity, radios[math.random(1,#radios)])
	Citizen.Wait(500)
	SetVehicleLights(entity, 0)
end

function FuelInjectorEffects(entity, timer)
	SetVehicleEngineOn(entity, 0, 0, 1)
	SetVehicleUndriveable(entity, true)
	Citizen.Wait(timer)
	SetVehicleEngineOn(entity, 1, 0, 1)
	SetVehicleUndriveable(entity, false)
end

function BrakesEffects(entity, timer)
	SetVehicleHandbrake(entity, true)
	Citizen.Wait(timer)
	SetVehicleHandbrake(entity, false)
end

function RadiatorEffects(curVehicle, chance, timer)
	local lastTemp = GetVehicleEngineTemperature(curVehicle)
	local eh = GetVehicleEngineHealth(curVehicle)
	SetVehicleEngineTemperature(curVehicle, 500.0)
	Citizen.Wait(timer + 2000)
	if eh >= 900 then SetVehicleEngineHealth(curVehicle, (eh-10)) end
	if eh >= 450 then SetVehicleEngineHealth(curVehicle, (eh-15)) end
	if eh >= 250 then SetVehicleEngineHealth(curVehicle, (eh-25)) end
	SetVehicleEngineTemperature(curVehicle, lastTemp)
end

function DriveShaftEffects(curVehicle, timer)
	local steerBias = {-1.0,-0.9,-0.8,0.8,0.9,1.0}
	local value = steerBias[math.random(#steerBias)]
	local tick = 0
	while true do	
		Citizen.Wait(timer)	
		SetVehicleSteerBias(curVehicle, value)
		tick = tick + 1
		if tick >= 20 then
			tick = 0
			break
		end
	end
end

function TransmissionEffects(curVehicle, timer, count)
	for i = 0, count do						
		Citizen.Wait(timer)
		SetVehicleHandbrake(curVehicle, true)
		Citizen.Wait(1000)
		SetVehicleHandbrake(curVehicle, false)
	end
end

function ClutchEffects(curVehicle, timer, fuelTimer)
	SetVehicleHandbrake(curVehicle, true)
	FuelInjectorEffects(curVehicle, fuelTimer)
	for i = 1, 360 do
		SetVehicleSteeringScale(curVehicle ,i)
		Citizen.Wait(5)
	end
	Citizen.Wait(timer)
	SetVehicleHandbrake(curVehicle, false)
end

-- Vehicle Collision / Damage --
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local lastVehSpeed = 0.0
	local lastVehBodyhealth = 0.0
	local multiplier = 2.236936
	if Config.UseKMH then multiplier = 3.6 end
    while true do 
        Citizen.Wait(1)
        if curVehicle ~= nil and curVehicle ~= 0 then 
            if driver == PlayerPedId() then 
				local curVehicleEngine = GetVehicleEngineHealth(curVehicle)
                if curVehicleEngine < 0.0 then 
                    SetVehicleEngineHealth(curVehicle,0.0)
                end
                local crashed = HasEntityCollidedWithAnything(curVehicle)
				if crashed then
                    Citizen.Wait(100)
                    local newVehBodyHealth = GetVehicleBodyHealth(curVehicle)
                    local newVehSpeed = (GetEntitySpeed(curVehicle) * multiplier)

                    if curVehicleEngine > 0.0 and (lastVehBodyhealth - newVehBodyHealth) > 10 then 
                        if newVehSpeed < (lastVehSpeed * 0.5) and lastVehSpeed > 180.0 then
                            applyCrashDamage(curVehicle)
                            Citizen.Wait(1000)
                            lastVehSpeed = 0.0
                            lastVehBodyhealth = newVehBodyHealth
                        end
                    else
                        if curVehicleEngine > 10.0 and (curVehicleEngine < 199.0 or newVehBodyHealth < 100.0) then
                            applyCrashDamage(curVehicle)
                            Citizen.Wait(1000)
                        end
                        lastVehSpeed = newVehSpeed
                        lastVehBodyhealth = newVehBodyHealth
                    end
                else
                    lastVehSpeed = (GetEntitySpeed(curVehicle) * multiplier)
                    lastVehBodyhealth = GetVehicleBodyHealth(curVehicle)
                    if curVehicleEngine > 10.0 and (curVehicleEngine < 199.0 or lastVehBodyhealth < 100.0) then
                        applyCrashDamage(curVehicle)
                        Citizen.Wait(1000)
                    end 
				end
            end
        end
    end
end)

function applyCrashDamage(vehicle)
	if Config.SlashTires then 
		local tyres = {0,1,4,5}
		for i = 1, math.random(#tyres) do
			local num = math.random(#tyres)
			SetVehicleTyreBurst(vehicle, tyres[num], true, 1000)
			table.remove(tyres, num)
		end 
	end
	if Config.EngineDisable then 
		SetVehicleEngineHealth(vehicle, 0)
		SetVehicleEngineOn(vehicle, false, true, true)
	end
	local takenIDs = {}
	local damageArray = {}
	for i = 1, Config.AmountPartsDamage do
		math.randomseed(GetGameTimer())
		local id = math.random(#Config.HealthParts)
		if Config.HealthParts[id].degName ~= "engine" then 
			while takenIDs[id] == id do
				id = math.random(#Config.HealthParts)
				if Config.HealthParts[id].degName == "engine" then
					id = math.random(#Config.HealthParts)
				end
			end
		end
		takenIDs[id] = id
		local vehPart = Config.HealthParts[id]
		local degVal = math.random(Config.DegradeValue.min,Config.DegradeValue.max)
		damageArray[vehPart.degName] = {label = vehPart.label, degName = vehPart.degName, degValue = degVal}
		i = i + 1
	end
	local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
	TriggerServerEvent('t1ger_mechanicjob:degradeVehHealth', plate, damageArray)
	takenIDs = {}
	damageArray = {}
    lastVehSpeed = 0.0
    lastVehBodyhealth = 0.0
end

-- ## NPC VEHICLE REPAIR JOBS ## --

jobID = nil
function ManageNpcJobs()
	local elements = {
		{ label = "Find Call", value = "find_job" },
		{ label = "Cancel Job", value = "cancel_job" },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "mech_npc_job_menu",
		{
			title    = "NPC Job Menu",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		if(data.current.value == 'find_job') then
			menu.close()
			local num = math.random(1,#Config.NPC_RepairJobs)
			local count = 0
			while Config.NPC_RepairJobs[num].inUse and count < 100 do
				count = count+1
				num = math.random(1,#Config.NPC_RepairJobs)
			end
			if count == 100 then
				ShowNotifyESX("Wait for a call")
			else
				Config.NPC_RepairJobs[num].inUse = true
				Wait(200)
				TriggerServerEvent('t1ger_mechanicjob:JobDataSV', Config.NPC_RepairJobs)
				TriggerEvent('t1ger_mechanicjob:startJobWithNPC', num)
			end
		end
		if(data.current.value == 'cancel_job') then
			menu.close()
			CancelCurrentJob()
		end
	end, function(data, menu)
		menu.close()
		OpenMechanicActionMenu()
	end)
end

CancelJob = false
JobVeh = nil
JobPed = nil
RegisterNetEvent('t1ger_mechanicjob:startJobWithNPC')
AddEventHandler('t1ger_mechanicjob:startJobWithNPC', function(num)
	local JobDone = false
	local job = Config.NPC_RepairJobs[num]
	local blip = CreateJobBlip(job.pos)
	local jobVehSpawned = false
	local vehicleRepaired = false
	local pedCreated = false
	local pedShouted = false
	local buttonClicked = false

	while not JobDone and not CancelJob do 
		Citizen.Wait(0)

		if job.inUse then

			local coords = GetEntityCoords(GetPlayerPed(-1))
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, job.pos[1], job.pos[2], job.pos[3], false)

			if distance > 50.0 then
				if DoesEntityExist(JobVeh) then
					DeleteEntity(JobVeh)
					DeleteVehicle(JobVeh)
					SetEntityAsNoLongerNeeded(JobVeh)
					JobVeh = nil
					jobVehSpawned = false
				end
			end

			if distance < 50.0 and not jobVehSpawned then
				ClearAreaOfVehicles(job.pos[1], job.pos[2], job.pos[3], 5.0, false, false, false, false, false)
				jobVehSpawned = true
				Citizen.Wait(200)
				math.randomseed(GetGameTimer())
				local vehID = math.random(#Config.RepairVehicles)
				local jobVehicle = Config.RepairVehicles[vehID]
				ESX.Game.SpawnVehicle(jobVehicle, {x = job.pos[1], y = job.pos[2], z = job.pos[3]}, job.pos[4], function(vehicle)
					SetEntityCoordsNoOffset(vehicle, job.pos[1], job.pos[2], job.pos[3])
					SetEntityHeading(vehicle, job.pos[4])
					SetVehicleOnGroundProperly(vehicle)
					SetEntityAsMissionEntity(JobVeh, true, true)
					JobVeh = vehicle
					SetVehicleEngineHealth(JobVeh, 100.0)
					SetVehicleDoorOpen(JobVeh, 4, 0, 0)
					SetPedIntoVehicle(ped, JobVeh, -1)
				end)
			end

			if distance < 10.0 then
				if not pedCreated then 
					RequestModel(job.ped)
					while not HasModelLoaded(job.ped) do
						Wait(10)
					end
					local NPC = CreatePedInsideVehicle(JobVeh, 1, job.ped, -1, true, true)
					NetworkRegisterEntityAsNetworked(NPC)
					SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(NPC), true)
					SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
					SetPedKeepTask(NPC, true)
					SetPedDropsWeaponsWhenDead(NPC, false)
					SetEntityInvincible(NPC, false)
					SetEntityVisible(NPC, true)
					JobPed = NPC
					SetEntityAsMissionEntity(JobPed)
					pedCreated = true
				end
				if not pedShouted and distance < 6.0 then
					ShowNotifyESX(Lang['npc_shout_msg'])
					pedShouted = true
				end
				local d1,d2 = GetModelDimensions(GetEntityModel(JobVeh))
				local enginePos = GetOffsetFromEntityInWorldCoords(JobVeh, 0.0,d2.y+0.2,0.0)
				local pedPos = GetEntityCoords(JobPed)
				local vehDistance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true)) 
				local pedDistance = (GetDistanceBetweenCoords(coords, vector3(pedPos.x, pedPos.y, pedPos.z), false))
				
				if vehDistance < 5.0 and not vehicleRepaired then
					DrawText3Ds(enginePos.x, enginePos.y, enginePos.z, Lang['npc_repair_veh'])
					if IsControlJustPressed(0, 38) and vehDistance < 1.0 and not buttonClicked then
						buttonClicked = true
						ESX.TriggerServerCallback('t1ger_mechanicjob:getInventoryItem', function(hasItem)
							if hasItem then 
								SetVehicleDoorOpen(JobVeh, 4, 0, 0)
								TaskTurnPedToFaceEntity(GetPlayerPed(-1), JobVeh, 1.0)
								Citizen.Wait(1000)
								local animDict = "mini@repair"
								LoadAnim(animDict)
								if not IsEntityPlayingAnim(GetPlayerPed(-1), animDict, "fixing_a_player", 3) then
									TaskPlayAnim(GetPlayerPed(-1), animDict, "fixing_a_player", 5.0, -5, -1, 16, false, false, false, false)
								end
								exports['progressBars']:startUI((4000), Lang['progbar_npc_fix'])
								Citizen.Wait(4000)
								SetVehicleEngineHealth(JobVeh, 1000.0)
								SetVehicleBodyHealth(JobVeh, 1000.0)
								SetVehicleFixed(JobVeh)
								for i = 0, 5 do SetVehicleTyreFixed(JobVeh, i) end
								if math.random(100) > 10 then
									TriggerServerEvent('t1ger_mechanicjob:removeItem', "repairkit", 1)
									ShowNotifyESX(Lang['npc_kit_broke'])
								end
								SetVehicleDoorShut(vehicle, 4, 1, 1)
								ClearPedTasks(GetPlayerPed(-1))
								ShowNotifyESX(Lang['npc_veh_repaired'])
								vehicleRepaired = true
								buttonClicked = false
							else
								ShowNotifyESX(Lang['npc_need_repair_kit'])
								buttonClicked = false
							end
						end, "repairkit")
					end
				end

				if pedDistance < 5.0 and vehicleRepaired then
					DrawText3Ds(pedPos.x, pedPos.y, pedPos.z, Lang['npc_collect_cash'])
					if IsControlJustPressed(0, 38) and pedDistance < 1.5 then
						RollDownWindow(JobVeh, 0)
						SetVehicleCanBeUsedByFleeingPeds(JobVeh, true)
						LoadAnim("mp_common")
						TaskTurnPedToFaceEntity(PlayerPedId(), JobVeh, 1.0)
						Citizen.Wait(1000)
						TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 4.0, 4.0, -1, 0, 1, 0,0,0)
						exports['progressBars']:startUI((2000), Lang['progbar_npc_cash'])
						Citizen.Wait(2000)
						ClearPedTasks(GetPlayerPed(-1))
						RollUpWindow(JobVeh, 0)
						ShowNotifyESX(Lang['npc_thanking_msg'])
						TriggerServerEvent('t1ger_mechanicjob:JobReward', job.payout)
						Wait(500)
						if DoesBlipExist(blip) then RemoveBlip(blip) end
						TaskVehicleDriveWander(JobPed, JobVeh, 80.0, 786603)
						Wait(2500)
						TaskSmartFleePed(JobPed, PlayerPedId(), 40.0, 20000)
						Wait(2500)
						CancelJob = true
					end
				end
			end

			if CancelJob then
				if DoesEntityExist(JobVeh) then DeleteVehicle(JobVeh) end
				if DoesEntityExist(JobPed) then DeleteEntity(JobPed) end
				if DoesBlipExist(blip) then RemoveBlip(blip) end
				Config.NPC_RepairJobs[num].inUse = false
				Wait(200)
				TriggerServerEvent('t1ger_mechanicjob:JobDataSV', Config.NPC_RepairJobs)
				JobVeh = nil
				JobPed = nil
				CancelJob = false
				break
			end
		end
	end
end)

-- Function for job blip in progress:
function CreateJobBlip(pos)
	local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', Lang['npc_repair_job'])
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.7) -- set scale
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 5)
	return blip
end

AddEventHandler('esx:onPlayerDeath', function(data)
	CancelJob = true
	if JobVeh ~= nil or JobPed ~= nil then 
		ShowNotifyESX(Lang['npc_cancel_job_death'])
	end
	Wait(300)
	CancelJob = false
end)

function CancelCurrentJob()
	CancelJob = true
	if JobVeh ~= nil or JobPed ~= nil then 
		ShowNotifyESX(Lang['npc_job_cancel_by_ply'])
	end
	Wait(300)
	CancelJob = false
end



