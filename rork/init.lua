
local awful      = require("awful")
awful.rules      = require("awful.rules")
rork = {}
--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function rork.run_or_raise(cmd, properties,callback)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if matchtable(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if #ctags == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   --awful.util.spawn(cmd)
   awful.spawn(cmd,{},callback)
 
end
-- | run or kill | --

function rork.run_or_kill(cmd, properties, newprop)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   local newprop = newprop or {}
   local scr = newprop.screen or mouse.screen
   --local newprop.x = newprop.x or mouse.coords().x
   --local newprop.y = newprop.y or mouse.coords().y
   --local newprop.funcafter = newprop.funcafter or function() end
   --local newprop.funcbefore = newprop.funcbefore or function() end
   for i, c in pairs(clients) do
      --make an array of matched clients
      if matchtable(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if #ctags == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      --else
         ---- Otherwise, pop to first tag client is visible on
         --awful.tag.viewonly(ctags[1])
      end
      -- And then kill the client
      c:kill()
      return
   end
   function unfocus(cl)
	   if matchtable(properties, cl) then  
		   cl:kill()
		   if newprop.funcafter then
			   newprop.funcafter()
		   end
		   client.disconnect_signal("unfocus",unfocus)
	   end
   end
   client.connect_signal("unfocus", unfocus)

   function manage(cl)
	   if matchtable(properties, cl) then  
		   if newprop.y then
			   cl:geometry( { y = newprop.y })
		   end
		   if newprop.x then
			   local x1
			   local w = cl.geometry(cl).width
			   local w2 = math.floor(w/2)
			   local scrw = screen[scr].workarea.width
			   --if newprop.x + w2 > scrw then
				   --x1 = scrw - w
				   --n = 1
			   --else
				   x1 = newprop.x - w2
			   --end
			   cl:geometry( { x = x1 })
		   end

		   client.focus = cl
		   if newprop.funcbefore then
			   newprop.funcbefore()
		   end
		   client.disconnect_signal("manage",manage)
	   end
   end
   client.connect_signal("manage", manage)
   awful.util.spawn(cmd)
end

--function rules.match(c, rule)
    --if not rule then return false end
    --for field, value in pairs(rule) do
        --if c[field] then
            --if type(c[field]) == "string" then
                --if not c[field]:match(value) and c[field] ~= value then
                    --return false
                --end
            --elseif c[field] ~= value then
                --return false
            --end
        --else
            --return false
        --end
    --end
    --return true
--end
-- Returns true if all pairs in table1 are present in table2
function matchtable(table1, table2)
   for k, v in pairs(table1) do
      if not table2[k] or table2[k] ~= v then -- and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

return rork
