-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Lang = {
  -- Menu Text:
  ['button_yes']         	    = 'Yes',
  ['button_no']         	    = 'No',
  ['button_return']         	= 'Return',
  ['rename_mech_shop']        = 'Rename Mech Shop',
  ['sell_mech_shop']          = 'Sell Mech Shop',
  ['employees_action']        = 'Employees',
  ['hire_employee']           = 'Reqruit Employee',
  ['employee_list']           = 'Employee List',
  ['fire_employee']           = 'Fire Employee',
  ['employee_job_grade']      = 'Job Grade Manage',
  ['accounts_action']         = 'Accounts',
  ['account_withdraw']        = 'Withdraw Money',
  ['account_deposit']         = 'Deposit Money',
  ['storage_withdraw']        = 'Withdraw Items',
  ['storage_deposit']         = 'Deposit Items',
  ['craft_item']              = 'Craft Item',
  ['view_recipe']             = 'View Recipe',

  -- GENERAL | NOTIFICATIONS
  ['not_enough_money']        = 'You do not have enough money.',
  ['mech_shop_bought']        = 'You purchased a ~b~mechanic shop~s~ and paid ~g~$%s~s~',
  ['mech_shop_sold']          = 'You sold your ~b~Mech Shop~s~ and received ~g~$%s~s~',
  ['not_your_mech_shop']      = 'You do not own this mech shop',
  ['mech_shop_renamed']       = 'You renamed your mech shop to: ~b~%s~s~',
  ['no_access']               = 'No Access',
  ['invalid_amount']          = 'Invalid Amount',
  ['repair_kit_broke']        = 'Repair Kit got destroyed.',
  ['repairkit_veh_repaired']  = 'Vehicle engine is now repaired, get to the nearest mech shop.',
  ['no_vehicle_nearby']       = 'No vehicle nearby.',
  ['no_players_nearby']       = 'No players nearby.',

  -- EMPLOYEE | NOTIFICATIONS
  ['no_employees_hired']      = 'No Employees hired at your shop',
  ['mech_employee_fired']     = 'You have been fired from the mech shop.',
  ['target_alrdy_has_job_g']  = '%s already has that job grade.',
  ['your_job_grade_updated']  = 'Your job grade has been updated to: %s.',
  ['you_updat_job_grade_for'] = 'You updated job grade for: %s to: %s.',
  ['mix_max_job_grade']       = 'Min Job Grade: 0 | Max Job Grade: %s.',
  ['already_hired']           = 'Player is already hired.',
  ['you_recruited_x']         = 'You reqruited: %s.',
  ['you_have_been_recruited'] = 'You have been reqruited to the mech shop.',

  -- ACCOUNTS & STORAGE & WORKBENCH | NOTIFICATIONS
  ['you_withdrew_x_amount']   = 'You withdrew ~g~$%s~s~.',
  ['withdrawal_denied']       = 'Withdrawal denied, insufficient account balance.',
  ['you_deposited_x_amount']  = 'You deposited ~g~$%s~s~.',
  ['storage_inv_empty']       = 'Storage Inventory is Empty.',
  ['storage_deposited_x']     = 'You deposited: %sx %s to the storage.',
  ['not_enough_items']        = 'Not enough items to deposit.',
  ['storage_withdrew_x']      = 'You withdrew: %sx %s from the storage.',
  ['too_high_count']          = 'Requested amount too high compared to storage inventory',
  ['not_enough_materials']    = 'You need some more materials, check the recipe!',
  ['crafting_in_progress']    = 'Already Crafting, please wait!',

  -- VEHICLE BODY REPAIRS | NOTIFICATIONS
  ['car_jack_carry']          = 'You need to carry a car jack on you.',
  ['raise_and_analyze']       = 'Raise the vehicle on a jack and analyse the vehicle, before you install parts.',
  ['analyze_veh_first']       = 'Analyze vehicle before installing parts.',
  ['all_doors_intact']        = 'All doors are repaired & intact.',
  ['trunk_already_installed'] = 'Trunk already installed.',
  ['hood_already_installed']  = 'Hood already installed.',
  ['all_wheels_intact']       = 'All wheels are repaired & intact.',
  ['all_body_repairs_done']   = 'All body repairs are done. Lower the vehicle!',
  ['finish_current_install']  = 'Finish your current installation',
  ['veh_already_analyzed']    = 'Vehicle already analysed, do your work!',
  ['raise_veh_b4_analyze']    = 'Raise the vehicle on a jack before you analyse the vehicle.',

  -- LIFT REPAIRS & HEALTH PARTS | NOTIFICATIONS
  ['lift_cannot_go_higher']   = 'Lift cannot go higher!',
  ['lift_cannot_go_lower']    = 'Lift cannot go lower!',
  ['veh_must_be_on_lift']     = 'Vehicle must be attached to a lift.',
  ['veh_must_be_inspected']   = 'Inspect the vehicle before repairing health parts.',
  ['health_part_exceeded']    = 'Health Part Value cannot exceed 10.0',
  ['not_decrease_health_val'] = 'You cannot decrease the current Health Part Value.',
  ['not_decrse_or_same_val']  = 'You cannot decrease or set the same health value, must be higher value!',
  ['need_more_materials']     = 'You need more materials for repairing to the selected value.',
  ['you_rep_health_part']     = 'You repaired: %s. New value is: %s',

  -- NPC JOB | NOTIFICATIONS
  ['npc_shout_msg']           = 'Hey! Can you repair my car please?',
  ['npc_need_repair_kit']     = 'You need a repairkit.',
  ['npc_kit_broke']           = 'During reparation, your kit broke.',
  ['npc_veh_repaired']        = 'Vehicle repaired. Collect the cash from the NPC.',
  ['npc_thanking_msg']        = 'Thank you very much, adios!',
  ['npc_cancel_job_death']    = 'You died! Job has been cancelled.',
  ['npc_job_cancel_by_ply']   = 'You cancelled your current ongoing job.',
  ['npc_job_cash_reward']     = 'You received: ~g~$%s~s~ from the NPC.',

  -- Draw 3D texts:
  ['mech_shop_manage']        = '~r~[E]~s~ Manage Shop',
  ['no_access_to_shop']       = 'No Shop Access',
  ['press_to_buy_shop']       = '~r~[E]~s~ Buy Mech Shop',
  ['only_one_mech_shop']      = 'ONLY OWN 1 MECH SHOP',
  ['repair_here']             = '~g~[E]~s~ REPAIR VEHICLE',
  ['press_to_storage']        = '~r~[E]~s~ Storage',
  ['press_to_workbench']      = '~r~[E]~s~ Workbench',
  ['lower_jack']              = 'Lower Jack',
  ['raise_jack']              = 'Raise Jack',
  ['analyze_here']            = '~r~[E]~s~ Analyze Here',
  ['install_body_part']       = '~r~[G]~s~ Install Body Part',
  ['park_on_lift']            = '~r~[E]~s~ Park on Lift',
  ['lift_occupied']           = 'Lift Occupied',
  ['remove_or_move_veh']      = '~r~[G]~s~ Remove Veh | ~y~[Arrow Up/Dn]~s~ Move Veh',
  ['no_veh_to_control']       = 'No Veh to Control',
  ['health_rep_here']         = '~r~[E]~s~ Repair Here',
  ['inspect_here']            = '~r~[E]~s~ Inspect Here',
  ['repair_engine']           = '~r~[E]~s~ Repair Engine',
  ['npc_repair_veh']          = '~r~[E]~s~ Repair Vehicle',
  ['npc_collect_cash']        = '~r~[E]~s~ Collect Cash',
  
  -- Progress Bar Texts:
  ['repairing_veh_kit']       = 'REPAIRING VEHICLE',
  ['crafting_item']           = 'CRAFTING: %s',
  ['progbar_lowering_jack']   = 'LOWERING JACK',
  ['progbar_raising_jack']    = 'RAISING JACK',
  ['progbar_inspecting_veh']  = 'INSPECTING VEHICLE',
  ['progbar_analyzing_veh']   = 'ANALYZING VEHICLE',
  ['lift_repairing_veh']      = 'REPAIRING: %s',
  ['progbar_npc_fix']         = 'REPAIRING NPC VEHICLE',
  ['progbar_npc_cash']        = 'COLLECTING CASH',

  -- Blip Texts:
  ['vacant_shops']            = 'Vacant Mech Shop',
  ['npc_repair_job']          = 'Repair NPC Vehicle',
  
}
