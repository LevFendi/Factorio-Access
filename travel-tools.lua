--Here: Teleporting, fast travel, structure travel, etc.
local fa_utils = require("fa-utils")

--Structure travel: Moves the player cursor in the input direction.
function move_cursor_structure(pindex, dir)
   local direction = players[pindex].structure_travel.direction
   local adjusted = {}
   adjusted[0] = "north"
   adjusted[2] = "east"
   adjusted[4] = "south"
   adjusted[6] = "west"

   local network = players[pindex].structure_travel.network
   local current = players[pindex].structure_travel.current
   local index = players[pindex].structure_travel.index
   if direction == "none" then
      if #network[current][adjusted[(0 + dir) %8]] > 0 then
         players[pindex].structure_travel.direction = adjusted[(0 + dir)%8]
         players[pindex].structure_travel.index = 1
         local index = players[pindex].structure_travel.index
         local dx = network[current][adjusted[(0 + dir)%8]][index].dx
         local dy = network[current][adjusted[(0 + dir) %8]][index].dy
         local description = ""
         if math.floor(math.abs(dx)+ .5) ~= 0 then
            if dx < 0 then
               description = description .. math.floor(math.abs(dx)+.5) .. " " .. "tiles west, "
            elseif dx > 0 then
               description = description .. math.floor(math.abs(dx)+.5) .. " " .. "tiles east, "
            end
         end
         if math.floor(math.abs(dy)+ .5) ~= 0 then
            if dy < 0 then
               description = description .. math.floor(math.abs(dy)+.5) .. " " .. "tiles north, "
            elseif dy > 0 then
               description = description .. math.floor(math.abs(dy)+.5) .. " " .. "tiles south, "
            end
         end
         local ent = network[network[current][adjusted[(0 + dir) %8]][index].num]
         if ent.ent.valid then
            cursor_highlight(pindex, ent.ent, nil)
            move_mouse_pointer(ent.ent.position,pindex)
            players[pindex].cursor_pos = ent.ent.position
            --Case 1: Proposing a new structure
            printout("To " .. ent.name .. " " .. extra_info_for_scan_list(ent.ent,pindex,true) .. ", " .. description  .. ", " .. index .. " of " .. #network[current][adjusted[(0 + dir) % 8]], pindex)
         else
            printout("Missing " .. ent.name .. " " .. description, pindex)
         end
      else
         printout("There are no buildings directly " .. adjusted[(0 + dir) %8] .. " of this one.", pindex)
      end
   elseif direction == adjusted[(4 + dir)%8] then
      players[pindex].structure_travel.direction = "none"
      local description = ""
      if #network[current].north > 0 then
         description = description .. ", " .. #network[current].north .. " connections north,"
      end
      if #network[current].east > 0 then
         description = description .. ", " .. #network[current].east .. " connections east,"
      end
      if #network[current].south > 0 then
         description = description .. ", " .. #network[current].south .. " connections south,"
      end
      if #network[current].west > 0 then
         description = description .. ", " .. #network[current].west .. " connections west,"
      end
      if description == "" then
         description = "No nearby buildings."
      end
      local ent = network[current]
      if ent.ent.valid then
         cursor_highlight(pindex, ent.ent, nil)
         move_mouse_pointer(ent.ent.position,pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 2: Returning to the current structure
         printout("Back at " .. ent.name .. " " .. extra_info_for_scan_list(ent.ent,pindex,true) .. ", " .. description, pindex)
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   elseif direction == adjusted[(0 + dir) %8] then
      players[pindex].structure_travel.direction = "none"
      players[pindex].structure_travel.current = network[current][adjusted[(0 + dir) %8]][index].num
      local current = players[pindex].structure_travel.current

      local description = ""
      if #network[current].north > 0 then
         description = description .. ", " .. #network[current].north .. " connections north,"
      end
      if #network[current].east > 0 then
         description = description .. ", " .. #network[current].east .. " connections east,"
      end
      if #network[current].south > 0 then
         description = description .. ", " .. #network[current].south .. " connections south,"
      end
      if #network[current].west > 0 then
         description = description .. ", " .. #network[current].west .. " connections west,"
      end
      if description == "" then
         description = "No nearby buildings."
      end
      local ent = network[current]
     if ent.ent.valid then
         cursor_highlight(pindex, ent.ent, nil)
         move_mouse_pointer(ent.ent.position,pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 3: Moved to the new structure
         printout("Now at " .. ent.name .. " " .. extra_info_for_scan_list(ent.ent,pindex,true) .. ", " .. description, pindex)
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   elseif direction == adjusted[(2 + dir)%8] or direction == adjusted[(6 + dir) %8] then
      if (dir == 0 or dir == 6) and index > 1 then
         game.get_player(pindex).play_sound{path = "Inventory-Move"}
         players[pindex].structure_travel.index = index - 1
      elseif (dir == 2 or dir == 4) and index < #network[current][direction] then
         game.get_player(pindex).play_sound{path = "Inventory-Move"}
         players[pindex].structure_travel.index = index + 1
      end
      local index = players[pindex].structure_travel.index
      local dx = network[current][direction][index].dx
      local dy = network[current][direction][index].dy
      local description = ""
      if math.floor(math.abs(dx)+ .5) ~= 0 then
         if dx < 0 then
            description = description .. math.floor(math.abs(dx)+.5) .. " " .. "tiles west, "
         elseif dx > 0 then
            description = description .. math.floor(math.abs(dx)+.5) .. " " .. "tiles east, "
         end
      end
      if math.floor(math.abs(dy)+ .5) ~= 0 then
         if dy < 0 then
            description = description .. math.floor(math.abs(dy)+.5) .. " " .. "tiles north, "
         elseif dy > 0 then
            description = description .. math.floor(math.abs(dy)+.5) .. " " .. "tiles south, "
         end
      end
      local ent = network[network[current][direction][index].num]
      if ent.ent.valid then
         cursor_highlight(pindex, ent.ent, nil)
         move_mouse_pointer(ent.ent.position,pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 4: Propose a new structure within the same direction
         printout("To " .. ent.name .. " " .. extra_info_for_scan_list(ent.ent,pindex,true) .. ", " .. description  .. ", " .. index .. " of " .. #network[current][direction], pindex)
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   end
end

--Structure travel: Creates the building network that is traveled during structure travel. 
function compile_building_network(ent, radius_in,pindex)--**Todo bug: Some neighboring structures are not picked up when they should be such as machines next to inserters
   local radius = radius_in
   local ents = ent.surface.find_entities_filtered{position = ent.position, radius = radius}
   game.get_player(pindex).print(#ents .. " ents at first pass")
   if #ents < 100 then
      radius = radius_in * 2
      ents = ent.surface.find_entities_filtered{position = ent.position, radius = radius}
   elseif #ents > 2000 then
      radius = math.floor(radius_in/4)
      ents = ent.surface.find_entities_filtered{position = ent.position, radius = radius}
   elseif #ents > 1000 then
      radius = math.floor(radius_in/2)
      ents = ent.surface.find_entities_filtered{position = ent.position, radius = radius}
   end
   rendering.draw_circle{color = {1, 1, 1},radius = radius,width = 20,target = ent.position, surface = ent.surface, draw_on_ground = true, time_to_live = 300}
   --game.get_player(pindex).print(#ents .. " ents at start")
   local adj = {hor = {}, vert = {}}
   local PQ = {}
   local result = {}
   --game.get_player(pindex).print("checkpoint 0")
   table.insert(ents, 1, ent)
   for i = #ents, 1, -1 do
      local row = ents[i]
      if row.unit_number ~= nil and (row.prototype.is_building or row.unit_number == ent.unit_number) then
         adj.hor[row.unit_number] = {}
         adj.vert[row.unit_number] = {}
         result[row.unit_number] = {
            ent = row,
            name = row.name,
            position = table.deepcopy(row.position),
            north = {},
            east = {},
            south = {},
            west = {}
         }
      else
         table.remove(ents, i)
      end
   end

   game.get_player(pindex).print(#ents .. " buildings found")--**keep here intentionally
   --game.get_player(pindex).print("checkpoint 1")

   for i, row in pairs(ents) do
      for i1, col in pairs(ents) do
         if adj.hor[row.unit_number][col.unit_number] == nil then
            if row.unit_number == col.unit_number then
               adj.hor[row.unit_number][col.unit_number] = true
               adj.vert[row.unit_number][col.unit_number] = true
            else
               adj.hor[row.unit_number][col.unit_number] = false
               adj.vert[row.unit_number][col.unit_number] = false
               adj.hor[col.unit_number][row.unit_number] = false
               adj.vert[col.unit_number][row.unit_number] = false

               table.insert(PQ, {
                  source = row,
                  dest = col,
                  dx = col.position.x - row.position.x,
                  dy = col.position.y - row.position.y,
                  man = math.abs(col.position.x - row.position.x) + math.abs(col.position.y - row.position.y)
               })

            end
         end

      end
   end
   --game.get_player(pindex).print("checkpoint 2")
   table.sort(PQ, function (k1, k2)
      return k1.man > k2.man
   end)
   --game.get_player(pindex).print("checkpoint 3, #PQ = " .. #PQ)--

   local entry = table.remove(PQ)
   local loop_count = 0
   while entry~= nil and loop_count < #PQ * 2 do
      loop_count = loop_count + 1
      if math.abs(entry.dy) >= math.abs(entry.dx) then
         if not adj.vert[entry.source.unit_number][entry.dest.unit_number] then
            for i, explored in pairs(adj.vert[entry.source.unit_number]) do
               adj.vert[entry.source.unit_number][i] = (explored or adj.vert[entry.dest.unit_number][i])
            end
         for i, row in pairs(adj.vert) do
            if adj.vert[entry.source.unit_number][i] then
               adj.vert[i] = adj.vert[entry.source.unit_number]
            end
         end
            if entry.dy > 0 then

               table.insert(result[entry.source.unit_number].south, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy
               })
               table.insert(result[entry.dest.unit_number].north, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1
               })
            else
               table.insert(result[entry.source.unit_number].north, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy
               })
               table.insert(result[entry.dest.unit_number].south, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1
               })

            end
         end
      end
      if math.abs(entry.dx) >= math.abs(entry.dy) then
         if not adj.hor[entry.source.unit_number][entry.dest.unit_number] then
            for i, explored in pairs(adj.hor[entry.source.unit_number]) do
               adj.hor[entry.source.unit_number][i] = explored or adj.hor[entry.dest.unit_number][i]
            end
         for i, row in pairs(adj.hor) do
            if adj.hor[entry.source.unit_number][i] then
               adj.hor[i] = adj.hor[entry.source.unit_number]
            end
         end
            if entry.dx > 0 then
               table.insert(result[entry.source.unit_number].east, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy
               })
               table.insert(result[entry.dest.unit_number].west, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1
               })
            else
               table.insert(result[entry.source.unit_number].west, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy
               })
               table.insert(result[entry.dest.unit_number].east, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1
               })

            end
         end

      end
      entry = table.remove(PQ)
   end
   --game.get_player(pindex).print("checkpoint 4, loop count: " .. loop_count )
   return result
end

--Makes the player teleport to the closest valid position to a target position. Uses game's teleport function. Muted makes silent and effectless teleporting
function teleport_to_closest(pindex, pos, muted, ignore_enemies)
   local pos = table.deepcopy(pos)
   local muted = muted or false
   local first_player = game.get_player(pindex)
   local surf = first_player.surface
   local radius = .5
   local new_pos = surf.find_non_colliding_position("character", pos, radius, .1, true)
   while new_pos == nil do
      radius = radius + 1
      new_pos = surf.find_non_colliding_position("character", pos, radius, .1, true)
   end
   --Do not teleport if in a vehicle, in a menu, or already at the desitination
   if first_player.vehicle ~= nil and first_player.vehicle.valid then
      printout("Cannot teleport while in a vehicle.", pindex)
      return false
   elseif util.distance(game.get_player(pindex).position, pos) <= 1.5 then
      printout("Already at target", pindex)
      return false
   elseif players[pindex].in_menu and players[pindex].menu ~= "travel" and players[pindex].menu ~= "structure-travel" then
      printout("Cannot teleport while in a menu.", pindex)
      return false
   end
   --Do not teleport near enemies unless instructed to ignore them
   if not ignore_enemies then
      local enemy = first_player.surface.find_nearest_enemy{position = new_pos, max_distance = 30, force =  first_player.force}
      if enemy and enemy.valid then
         printout("Warning: There are enemies at this location, but you can force teleporting if you press CONTROL + SHIFT + T", pindex)
         return false
      end
   end
   --Attempt teleport
   local can_port = first_player.surface.can_place_entity{name = "character", position = new_pos}
   if can_port then
      local old_pos = table.deepcopy(first_player.position)
      if not muted then
         --Teleporting visuals at origin
         rendering.draw_circle{color = {0.8, 0.2, 0.0},radius = 0.5,width = 15,target = old_pos, surface = first_player.surface, draw_on_ground = true, time_to_live = 60}
         rendering.draw_circle{color = {0.6, 0.1, 0.1},radius = 0.3,width = 20,target = old_pos, surface = first_player.surface, draw_on_ground = true, time_to_live = 60}
         local smoke_effect = first_player.surface.create_entity{name = "iron-chest", position = first_player.position, raise_built = false, force = first_player.force}
         smoke_effect.destroy{}
         --Teleport sound at origin
         game.get_player(pindex).play_sound{path = "player-teleported", volume_modifier = 0.2, position = old_pos}
         game.get_player(pindex).play_sound{path = "utility/scenario_message", volume_modifier = 0.8, position = old_pos}
      end
      local teleported = false
      if muted then
         teleported = first_player.teleport(new_pos)
      else
         teleported = first_player.teleport(new_pos)
      end
      if teleported then
         first_player.force.chart(first_player.surface, {{new_pos.x-15,new_pos.y-15},{new_pos.x+15,new_pos.y+15}})
         players[pindex].position = table.deepcopy(new_pos)
         reset_bump_stats(pindex)
         if not muted then
            --Teleporting visuals at target
            rendering.draw_circle{color = {0.3, 0.3, 0.9},radius = 0.5,width = 15,target = new_pos, surface = first_player.surface, draw_on_ground = true, time_to_live = 60}
            rendering.draw_circle{color = {0.0, 0.0, 0.9},radius = 0.3,width = 20,target = new_pos, surface = first_player.surface, draw_on_ground = true, time_to_live = 60}
            local smoke_effect = first_player.surface.create_entity{name = "iron-chest", position = first_player.position, raise_built = false, force = first_player.force}
            smoke_effect.destroy{}
            --Teleport sound at target
            game.get_player(pindex).play_sound{path = "player-teleported", volume_modifier = 0.2, position = new_pos}
            game.get_player(pindex).play_sound{path = "utility/scenario_message", volume_modifier = 0.8, position = new_pos}
         end
         if new_pos.x ~= pos.x or new_pos.y ~= pos.y then
            if not muted then
               printout("Teleported " .. math.ceil(fa_utils.distance(pos,first_player.position)) .. " " .. fa_utils.direction(pos, first_player.position) .. " of target", pindex)
            end
         end
         --Update cursor after teleport
         players[pindex].cursor_pos = table.deepcopy(new_pos)
         move_mouse_pointer(fa_utils.center_of_tile(players[pindex].cursor_pos),pindex)
         cursor_highlight(pindex,nil,nil)
      else
         printout("Teleport Failed", pindex)
         return false
      end
   else
      printout("Cannot teleport", pindex)--this is unlikely to be reached because we find the first non-colliding position
      return false
   end

   -- --Adjust camera
   -- game.get_player(pindex).close_map()

   return true
end

--Teleports the player character to the cursor position.
function teleport_to_cursor(pindex, muted, ignore_enemies, return_cursor)
   local result = teleport_to_closest(pindex, players[pindex].cursor_pos, muted, ignore_enemies)
   if return_cursor then
      players[pindex].cursor_pos = players[pindex].position
   end
   return result
end


function fast_travel_menu_open(pindex)
   if players[pindex].in_menu == false and game.get_player(pindex).driving == false and game.get_player(pindex).opened == nil then
      game.get_player(pindex).selected = nil

      players[pindex].menu = "travel"
      players[pindex].in_menu = true
      players[pindex].move_queue = {}
      players[pindex].travel.index = {x = 1, y = 0}
      players[pindex].travel.creating = false
      players[pindex].travel.renaming = false
      players[pindex].travel.describing = false
      printout("Navigate up and down with W and S to select a fast travel location, and jump to it with LEFT BRACKET.  Alternatively, select an option by navigating left and right with A and D.", pindex)
      local screen = game.get_player(pindex).gui.screen
      local frame = screen.add{type = "frame", name = "travel"}
      frame.bring_to_front()
      frame.force_auto_center()
      frame.focus()
      game.get_player(pindex).opened = frame
      game.get_player(pindex).selected = nil
   elseif players[pindex].in_menu or game.get_player(pindex).opened ~= nil then
      printout("Another menu is open.", pindex)
   elseif game.get_player(pindex).driving then
      printout("Cannot fast travel from inside a vehicle", pindex)
   end

   --Report disconnect error because the V key normally disconnects rolling stock if driving.
   local vehicle = nil
   if game.get_player(pindex).vehicle ~= nil and game.get_player(pindex).vehicle.train ~= nil then
      vehicle = game.get_player(pindex).vehicle
      local connected = 0
      if vehicle.get_connected_rolling_stock(defines.rail_direction.front) ~= nil then
         connected = connected + 1
      end
      if vehicle.get_connected_rolling_stock(defines.rail_direction.back) ~= nil then
         connected = connected + 1
      end
      if connected == 0 then
         printout("Warning, this vehicle was disconnected. Please review mod settings.", pindex)
         --Attempt to reconnect (does not work)
         --vehicle.connect_rolling_stock(defines.rail_direction.front)
         --vehicle.connect_rolling_stock(defines.rail_direction.back)
      end
   end
end

--Reads the selected fast travel menu slot
function read_travel_slot(pindex)
   if #global.players[pindex].travel == 0 then
      printout("Move towards the right and select Create to get started.", pindex)
   else
      local entry = global.players[pindex].travel[players[pindex].travel.index.y]
      printout(entry.name .. " at " .. math.floor(entry.position.x) .. ", " .. math.floor(entry.position.y), pindex)
      players[pindex].cursor_pos = fa_utils.center_of_tile(entry.position)
      cursor_highlight(pindex, nil, "train-visualization")
   end
end

function fast_travel_menu_click(pindex)
   if players[pindex].travel.input_box then
      players[pindex].travel.input_box.destroy()
   end
   if #global.players[pindex].travel == 0 and players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      printout("Move towards the right and select Create New to get started.", pindex)
   elseif players[pindex].travel.index.y == 0 and players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      printout("Navigate up and down to select a fast travel point, then press LEFT BRACKET to get there quickly.", pindex)
   elseif players[pindex].travel.index.x == 1 then --Travel
      local success = teleport_to_closest(pindex, global.players[pindex].travel[players[pindex].travel.index.y].position, false, false)
      if success and players[pindex].cursor then
         players[pindex].cursor_pos = table.deepcopy(global.players[pindex].travel[players[pindex].travel.index.y].position)
      else
         players[pindex].cursor_pos = fa_utils.offset_position(players[pindex].position, players[pindex].player_direction, 1)
      end
      sync_build_cursor_graphics(pindex)
      game.get_player(pindex).opened = nil

      if not refresh_player_tile(pindex) then
         printout("Tile out of range", pindex)
         return
      end

      --Update cursor highlight
      local ent = get_selected_ent(pindex)
      if ent and ent.valid then
         cursor_highlight(pindex, ent, nil)
      else
         cursor_highlight(pindex, nil, nil)
      end
   elseif players[pindex].travel.index.x == 2 then --Read description
      local desc = players[pindex].travel[players[pindex].travel.index.y].description
      if desc == nil or desc == "" then
         desc = "No description"
         players[pindex].travel[players[pindex].travel.index.y].description = desc
      end
      printout(desc, pindex)
   elseif players[pindex].travel.index.x == 3 then --Rename
      printout("Type in a new name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
      players[pindex].travel.renaming = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add{type="textfield", name = "input"}
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif players[pindex].travel.index.x == 4 then --Rewrite description
      local desc = players[pindex].travel[players[pindex].travel.index.y].description
      if desc == nil then
         desc = ""
         players[pindex].travel[players[pindex].travel.index.y].description = desc
      end
      printout("Type in the new description text, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
      players[pindex].travel.describing = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add{type="textfield", name = "input"}
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif players[pindex].travel.index.x == 5 then --Relocate to current character position
      players[pindex].travel[players[pindex].travel.index.y].position = fa_utils.center_of_tile(players[pindex].position)
      printout("Relocated point ".. players[pindex].travel[players[pindex].travel.index.y].name .. " to " .. math.floor(players[pindex].position.x) .. ", " .. math.floor(players[pindex].position.y), pindex)
      players[pindex].cursor_pos = players[pindex].position
      cursor_highlight(pindex)
   elseif players[pindex].travel.index.x == 6 then --Delete
      printout("Deleted " .. global.players[pindex].travel[players[pindex].travel.index.y].name, pindex)
      table.remove(global.players[pindex].travel, players[pindex].travel.index.y)
      players[pindex].travel.x = 1
      players[pindex].travel.index.y = players[pindex].travel.index.y - 1
   elseif players[pindex].travel.index.x == 7 then --Create new 
      printout("Type in a name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
      players[pindex].travel.creating = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add{type="textfield", name = "input"}
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   end
end
TRAVEL_MENU_LENGTH = 7

function fast_travel_menu_up(pindex)
   if players[pindex].travel.index.y > 1 then
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
      players[pindex].travel.index.y = players[pindex].travel.index.y - 1
   else
      players[pindex].travel.index.y = 1
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   end
   players[pindex].travel.index.x = 1
   read_travel_slot(pindex)
end

function fast_travel_menu_down(pindex)
   if players[pindex].travel.index.y < #players[pindex].travel then
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
      players[pindex].travel.index.y = players[pindex].travel.index.y + 1
   else
      players[pindex].travel.index.y = #players[pindex].travel
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   end
   players[pindex].travel.index.x = 1
   read_travel_slot(pindex)
end

function fast_travel_menu_right(pindex)
   if players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
      players[pindex].travel.index.x = players[pindex].travel.index.x + 1
   else
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   end
   if players[pindex].travel.index.x == 1 then
      printout("Travel", pindex)
   elseif players[pindex].travel.index.x == 2 then
      printout("Read description", pindex)
   elseif players[pindex].travel.index.x == 3 then
      printout("Rename", pindex)
   elseif players[pindex].travel.index.x == 4 then
      printout("Rewrite description", pindex)
   elseif players[pindex].travel.index.x == 5 then
      printout("Relocate to current character position", pindex)
   elseif players[pindex].travel.index.x == 6 then
      printout("Delete", pindex)
   elseif players[pindex].travel.index.x == 7 then
      printout("Create New", pindex)
   end
end

function fast_travel_menu_left(pindex)
   if players[pindex].travel.index.x > 1 then
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
      players[pindex].travel.index.x = players[pindex].travel.index.x - 1
   else
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   end
   if players[pindex].travel.index.x == 1 then
      printout("Travel", pindex)
   elseif players[pindex].travel.index.x == 2 then
      printout("Read description", pindex)
   elseif players[pindex].travel.index.x == 3 then
      printout("Rename", pindex)
   elseif players[pindex].travel.index.x == 4 then
      printout("Rewrite description", pindex)
   elseif players[pindex].travel.index.x == 5 then
      printout("Relocate to current character position", pindex)
   elseif players[pindex].travel.index.x == 6 then
      printout("Delete", pindex)
   elseif players[pindex].travel.index.x == 7 then
      printout("Create New", pindex)
   end
end