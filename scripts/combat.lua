--Here: functions relating to combat, repair packs
--Does not include event handlers, guns and equipment maanagement

local util = require("util")
local fa_graphics = require("scripts.graphics")
local fa_mouse = require("scripts.mouse")
local fa_equipment = require("scripts.equipment")

local mod = {}

--One-click repair pack usage.
function mod.repair_pack_used(ent, pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Repair the entity found
   if
      ent
      and ent.valid
      and ent.is_entity_with_health
      and ent.get_health_ratio() < 1
      and ent.type ~= "resource"
      and not ent.force.is_enemy(p.force)
      and ent.name ~= "character"
   then
      p.play_sound({ path = "utility/default_manual_repair" })
      local health_diff = ent.prototype.max_health - ent.health
      local dura = stack.durability or 0
      if health_diff < 10 then --free repair for tiny damages
         ent.health = ent.prototype.max_health
         printout("Fully repaired " .. ent.name, pindex)
      elseif health_diff < dura then
         ent.health = ent.prototype.max_health
         stack.drain_durability(health_diff)
         printout("Fully repaired " .. ent.name, pindex)
      else --if health_diff >= dura then
         stack.drain_durability(dura)
         ent.health = ent.health + dura
         printout("Partially repaired " .. ent.name .. " and consumed a repair pack", pindex)
         --Note: This automatically subtracts correctly and decerements the pack in hand.
      end
   end
   --Note: game.get_player(pindex).use_from_cursor{players[pindex].cursor_pos.x,players[pindex].cursor_pos.y}--This does not work.
end

--Tries to repair all relevant entities within a certain distance from the player
function mod.repair_area(radius_in, pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local repaired_count = 0
   local packs_used = 0
   local radius = math.min(radius_in, 25)
   if stack.count < 2 then
      --If you are low on repair packs, stop
      printout("You need at least 2 repair packs to repair the area.", pindex)
      return
   end
   local ents = p.surface.find_entities_filtered({ position = p.position, radius = radius })
   for i, ent in ipairs(ents) do
      --Repair the entity found
      if
         ent
         and ent.valid
         and ent.is_entity_with_health
         and ent.get_health_ratio() < 1
         and ent.type ~= "resource"
         and not ent.force.is_enemy(p.force)
         and ent.name ~= "character"
      then
         p.play_sound({ path = "utility/default_manual_repair" })
         local health_diff = ent.prototype.max_health - ent.health
         local dura = stack.durability or 0
         if health_diff < 10 then --free repair for tiny damages
            ent.health = ent.prototype.max_health
            repaired_count = repaired_count + 1
         elseif health_diff < dura then
            ent.health = ent.prototype.max_health
            stack.drain_durability(health_diff)
            repaired_count = repaired_count + 1
         elseif stack.count < 2 then
            --If you are low on repair packs, stop
            printout(
               "Repaired "
                  .. repaired_count
                  .. " structures using "
                  .. packs_used
                  .. " repair packs, stopped because you are low on repair packs.",
               pindex
            )
            return
         else
            --Finish the current repair pack
            stack.drain_durability(dura)
            packs_used = packs_used + 1
            ent.health = ent.health + dura

            --Repeat unhtil fully repaired or out of packs
            while ent.get_health_ratio() < 1 do
               health_diff = ent.prototype.max_health - ent.health
               dura = stack.durability or 0
               if health_diff < 10 then --free repair for tiny damages
                  ent.health = ent.prototype.max_health
                  repaired_count = repaired_count + 1
               elseif health_diff < dura then
                  ent.health = ent.prototype.max_health
                  stack.drain_durability(health_diff)
                  repaired_count = repaired_count + 1
               elseif stack.count < 2 then
                  --If you are low on repair packs, stop
                  printout(
                     "Repaired "
                        .. repaired_count
                        .. " structures using "
                        .. packs_used
                        .. " repair packs, stopped because you are low on repair packs.",
                     pindex
                  )
                  return
               else
                  --Finish the current repair pack
                  stack.drain_durability(dura)
                  packs_used = packs_used + 1
                  ent.health = ent.health + dura
               end
            end
         end
      end
   end
   if repaired_count == 0 then
      printout("Nothing to repair within " .. radius .. " tiles of you.", pindex)
      return
   end
   printout(
      "Repaired all "
         .. repaired_count
         .. " structures within "
         .. radius
         .. " tiles of you, using "
         .. packs_used
         .. " repair packs.",
      pindex
   )
end

--Plays enemy proximity alert sounds. Frequency is determined by distance andmode, and intensity is determined by the threat level.
function mod.check_and_play_enemy_alert_sound(mode_in)
   for pindex, player in pairs(players) do
      local mode = mode_in or 1
      local p = game.get_player(pindex)
      if p ~= nil and p.valid then
         local nearest_enemy =
            p.surface.find_nearest_enemy({ position = p.position, max_distance = 100, force = p.force })
         local dist = -1
         if nearest_enemy ~= nil and nearest_enemy.valid then
            dist = math.floor(util.distance(nearest_enemy.position, p.position))
         else
            return
         end
         --Attempt to detect if west or east
         local diffx = nearest_enemy.position.x - p.position.x
         local diffy = nearest_enemy.position.y - p.position.y
         local x_offset = 0
         if math.abs(diffx) > 2 * math.abs(diffy) then
            --Counts as east or west
            if diffx > 0 then
               x_offset = 7
            elseif diffx < 0 then
               x_offset = -7
            end
         end
         local pos = { x = p.position.x + x_offset, y = p.position.y }

         --Play sounds according tomode
         if mode == 1 then -- Nearest enemy is far (lowest freq)
            if dist < 100 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
            --Additional alert if there are more than 5 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 5 then
               p.play_sound({ path = "alert-enemy-presence-high", position = pos })
            else
               for i, enemy in ipairs(enemies) do
                  --Also check for strong enemies: big/huge biters, huge spitters, medium or larger worms, not spawners
                  if enemy.prototype.max_health > 360 then
                     p.play_sound({ path = "alert-enemy-presence-high", position = pos })
                     return
                  end
               end
            end
         elseif mode == 2 then -- Nearest enemy is closer (medium freq)
            if dist < 50 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
            --Additional alert if there are more than 10 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 10 then p.play_sound({ path = "alert-enemy-presence-high", position = pos }) end
         elseif mode == 3 then -- Nearest enemy is too close (highest freq)
            if dist < 25 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
         end
      end
   end
end

--Locks the cursor to the nearest enemy within 50 tiles. Also plays a sound if the enemy is within range of the gun in hand.
function mod.aim_gun_at_nearest_enemy(pindex, enemy_in)
   local p = game.get_player(pindex)
   if p == nil or p.character == nil or p.character.valid == false then return end
   local gun_index = p.character.selected_gun_index
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local gun_stack = guns_inv[gun_index]
   local ammo_stack = ammo_inv[gun_index]
   local enemy = enemy_in
   --Return if missing a gun or ammo
   if gun_stack == nil or not gun_stack.valid_for_read or not gun_stack.valid then return false end
   if ammo_stack == nil or not ammo_stack.valid_for_read or not ammo_stack.valid then return false end
   --Return if in Cursormode
   if players[pindex].cursor then return false end
   --Return if in a menu
   if players[pindex].in_menu then return false end
   --Check for nearby enemies
   if enemy_in == nil or not enemy_in.valid then
      enemy = p.surface.find_nearest_enemy({ position = p.position, max_distance = 50, force = p.force })
   end
   if enemy == nil or not enemy.valid then return false end
   --Play a sound when the enemy is within range of the gun
   local range = gun_stack.prototype.attack_parameters.range
   local dist = util.distance(p.position, enemy.position)
   if dist < range and p.character.can_shoot(enemy, enemy.position) then
      p.play_sound({ path = "player-aim-locked", volume_modifier = 0.5 })
   end
   --Return if there is a gun and ammo combination that already aims by itself
   if gun_stack.name == "pistol" or gun_stack.name == "submachine-gun" and dist < 10 then --or ammo_stack.name == "rocket" or ammo_stack.name == "explosive-rocket" then
      --**Note: normal/explosive rockets only fire when they lock on a target anyway. Meanwhile the SMG auto-aims only when close enough
      return true
   end
   --If in range, move the cursor onto the enemy to aim the gun
   if dist < range then
      players[pindex].cursor_pos = enemy.position
      fa_mouse.move_mouse_pointer(enemy.position, pindex)
      fa_graphics.draw_cursor_highlight(pindex, nil, nil, true)
   end
   return true
end

--Checks if the conditions are valid for shooting an atomic bomb
--laterdo review
function mod.run_atomic_bomb_checks(pindex)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   --local main_inv = p.get_inventory(defines.inventory.character_main)
   --local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local ammo_inv = p.get_inventory(defines.inventory.character_ammo)
   local selected_ammo = ammo_inv[p.character.selected_gun_index]
   local target_pos = p.shooting_state.position
   local abort_missle = false
   local abort_message = ""

   if selected_ammo == nil or selected_ammo.valid_for_read == false then return end

   --Stop checking if atomic bombs are not equipped
   if selected_ammo.name ~= "atomic-bomb" then return end

   --Stop checking if vanilla mode
   if players[pindex].vanilla_mode == true then return end

   --If the target position is shown as the center of the screen where the player stands, it means the cursor is not on screen
   if target_pos == nil or util.distance(p.position, target_pos) < 1.5 then
      target_pos = players[pindex].cursor_pos
      p.shooting_state.position = players[pindex].cursor_pos
      if selected_ammo.name == "atomic-bomb" then
         abort_missle = true
         abort_message = "Aiming alert, scroll mouse wheel to zoom out."
      end
   end

   --If the target position is shown as the center of the screen where the player stands, it means the cursor is not on screen
   local aim_dist_1 = util.distance(p.position, target_pos)
   local aim_dist_2 = util.distance(p.position, players[pindex].cursor_pos)
   if aim_dist_1 < 1.5 then
      abort_missle = true
      abort_message = "Aiming alert, scroll mouse wheel to zoom out."
   elseif util.distance(target_pos, players[pindex].cursor_pos) > 2 then
      abort_missle = true
      abort_message = "Aiming alert, move cursor to sync mouse."
   end
   if aim_dist_1 < 35 or aim_dist_2 < 35 then
      abort_missle = true
      abort_message = "Range alert, target too close, hold to fire anyway."
   end
   --p.print("abort check")

   --Take actions to abort the firing
   if abort_missle then
      --Remove all atomic bombs
      fa_equipment.delete_equipped_atomic_bombs(pindex)

      --Warn the player
      p.play_sound({ path = "utility/cannot_build" })
      printout(abort_message, pindex)

      --Schedule to restore the items on a later tick
      schedule(310, "call_to_restore_equipped_atomic_bombs", pindex)
   else
      --Suppress alerts for 10 seconds?
   end
end

return mod
