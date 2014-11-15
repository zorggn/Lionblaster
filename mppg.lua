--[[
	Multi-partite Performance Graph
	Generalized by zorg, from Rouge Carrot's Performance Graph implementation
	v1.1 @2014; license: isc
--]]

-- Definition: A performance graph implementation. Duh. :3

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]

--[[
   Future ideas:
      Cumulative Benchmark - compare two code parts' execution time over more frames (more either defined as a number or not)

   Changelog:
   v1.1
      Added pause function, and additional behaviour to the start and stop functions relating to the implemented function mentioned.
      Made a local for love.math too, just for neatness sake (it's only called 3 times in :add, not really a bottleneck; same with love.window)
   v1.0
      First release.
--]]



--[[
   external modules
--]]



--[[
   localized love lib calls
--]]

local lw = love.window
local lg = love.graphics
local lt = love.timer
local lm = love.math

--[[
   locals (private)
--]]







-- modified via function calls

local data = {} -- 
local revl = {} -- reverse lookup

local enabled =   true
local fading =     true
local showText =  true

-- internal

local tickPos =   0
local tickScale = 10000
local fps =       60 -- only defines a limit, not tied to the actual render rate of the löve window
local avgFrames = 60 -- applies only to the textual representation, so it won't jitter that much

local width =     lg.getWidth()
local height =    lg.getHeight()
local scale =     lw.getPixelScale()

local primary =   lg.newCanvas(width, height)
local secondary = lg.newCanvas(width, height)
primary:setFilter("nearest")
secondary:setFilter("nearest")

local fader = 0.0
local timer = 0.0

-- the module

local pg = {}

-- private functions

local function reset()
   local _s = 1 / fps
   tickPos = 0
   primary:clear(0,0,0,0)
   secondary:clear(0,0,0,0)
end

-- public functions

function pg.toggle(key)
   if key then
      data[revl[key]].active = not data[revl[key]].active
      return true
   else
      reset()
      enabled = not enabled
      return true
   end
   return false
end

function pg.toggleText()
   showText = not showText
   return true
end

function pg.isFading()
   faded = not faded
   return true
end

function pg.add(key,color)
   local color = (color and (type(color) == 'table')) and color or {lm.random(0,255),lm.random(0,255),lm.random(0,255)}
   if not revl[key] then
      data[#data+1] = {key = key, time = 0, active = true, color = color, counter = 1, avg = 0.0, _state = 'stopped'}
      revl[key] = #data
      return true
   else
      return false
   end
end

function pg.remove(key)
   if revl[key] then
      local index = revl[key]
      for i = index+1, #data-1 do
         data[index] = data[i]
      end
      data[#data] = nil
      revl[key] = nil
      return true
   else
      return false
   end
end

function pg.start(key)
   if data[revl[key]] then
      if data[revl[key]]._state == 'stopped' then
         data[revl[key]]._time = lt.getTime()
         data[revl[key]]._state = 'running'
      elseif data[revl[key]]._state == 'paused' then
         data[revl[key]]._time = data[revl[key]]._time + lt.getTime()
         data[revl[key]]._state = 'running'
      end
      return true
   else
      return false
   end
end

function pg.pause(key)
   if data[revl[key]] then
      if data[revl[key]]._state == 'running' then
         data[revl[key]]._time = data[revl[key]]._time - lt.getTime()
         data[revl[key]]._state = 'paused'
      end
      return true
   else
      return false
   end
end

function pg.stop(key)
   if data[revl[key]] and data[revl[key]]._state ~= 'stopped' then
      if data[revl[key]]._state == 'paused' then
         -- magic happens here, because this shouldn't happen, but we allow it to.
         data[revl[key]]._time = data[revl[key]]._time + lt.getTime()
      end
      data[revl[key]].time = data[revl[key]]._time and lt.getTime() - data[revl[key]]._time or 0.0
      data[revl[key]]._state = 'stopped'
      return true
   else
      return false
   end
end

function pg.reinit(w,h)
   reset()
   width, height = w, h
   scale = lw.getPixelScale()
   primary =   lg.newCanvas(width, height)
   secondary = lg.newCanvas(width, height)
   primary:setFilter("nearest")
   secondary:setFilter("nearest")
end

function pg.draw(key)
   if key and not data[revl[key]] then return false end

   local _s = 1 / fps

   if not faded then
      -- just clear the whole canvas once we reach the other side of the screen
      if tickPos == 0 then reset() end
   else
      -- gradually fade out previous content, utilizing a helper canvas
      lg.setCanvas(primary)
      local blendmode = lg.getBlendMode()
      lg.setBlendMode('subtractive')

      -- modify this part to get different fading speeds; i found this to work somewhat decently.
      fader = fader + 0.4 * (800/width)
      lg.setColor(0,0,0,16)

      if fader > 1.0 then 
         fader = 0.0
         --lg.rectangle("fill", 0, 0, width, _s * tickScale--)
         lg.rectangle("fill", 0, 0, width, height) -- this way, it will also fade the spikes that may go over the vertical 1/fps limit line.
      end
      lg.setBlendMode(blendmode)
   end

   lg.setCanvas(secondary)

   -- timer update so we can visualize one second distances in the graph, whenever the update/render does not take more time than allowed, that is.
   timer = timer + lt.getDelta()
   if timer >= 1.0 then
      timer = timer % 1
      lg.setColor(63,63,63)
      lg.rectangle("fill", tickPos, 0, 1, _s * tickScale)
   end

   -- draw either the selected, or all of the components
   if key then
      local v = data[revl[key]]
      lg.setColor(v.color)
      lg.rectangle("fill", tickPos, 0, 1, v.time * tickScale)
   else
      local accum_base = 0.0
      for i,v in ipairs(data) do
         if v.active then
            lg.setColor(v.color)
            lg.rectangle("fill", tickPos, accum_base, 1, v.time * tickScale)
            accum_base = accum_base + v.time * tickScale
         end
      end
   end

   -- increment the current x coord of the graph's drawing position
   tickPos = tickPos + 1
   if tickPos >= width then tickPos = 0 end

   -- draw the limiting line
   lg.setColor(255,255,255)
   local ls = lg.getLineStyle()
   lg.setLineStyle('rough')
   lg.line(0, _s * tickScale, width, _s * tickScale)
   lg.setLineStyle(ls)

   -- flush the secondary canvas to the primary, then clear the former
   lg.setCanvas(primary)
   lg.draw(secondary,0,lg.getHeight(), 0, scale, -scale)
   secondary:clear()

   -- flush the primary canvas to the screen
   lg.setCanvas()
   lg.draw(primary, 0, 0)

   -- draw the (averaged) percentile texts (not on any of the two canvases, it would distort the text.)
   if showText then
      if key then
         local v = data[revl[key]]
         if v.avg == 0.0 and v.counter == 1 then
            v.avg = v.timer
         elseif v.counter < avgFrames then
            -- running average
            v.avg = ((v.counter * v.avg) + v.time) / math.min(v.counter+1,avgFrames)
         end
         v.counter = v.counter + 1
         v.counter = v.counter % avgFrames + 1

         local v = data[revl[key]]
         local s = tostring(math.floor((v.avg / _s) * 100))

         lg.print(v.key .. ':',0,(revl[key]-1)*12)
         lg.printf(s .. "%",string.len(v.key),(revl[key]-1)*12,100,"right")
      else
         local total = 0.0
         for i,v in ipairs(data) do
            if v.active then
               if v.avg == 0.0 and v.counter == 1 then
                  v.avg = v.time
               elseif v.avg > 0.0 and v.counter < avgFrames then
                  -- running average
                  v.avg = ((v.counter * v.avg) + v.time) / math.min(v.counter+1,avgFrames)
               end
               v.counter = v.counter + 1
               v.counter = v.counter % avgFrames + 1

               local p = math.floor((v.avg / _s) * 100)
               local s = tostring(p)

               lg.print(v.key .. ':',0,(i-1)*12)
               lg.printf(s .."%",10,(i-1)*12,100,"right")
               total = total + p
            end
         end
         lg.print('Total:',0,(#data)*12)
         lg.printf(total .. "%",10,(#data)*12,100,"right")
      end
   end
   return true
end

return pg