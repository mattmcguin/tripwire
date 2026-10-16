-- ⌃⌥⌘L → arm tripwire: any input, Space change, power unplug or new USB device locks the screen.
-- While armed, a Touch ID prompt stays open: a fingerprint match disarms, anything else locks.
-- Keeps the Mac and display awake while armed; unlocking also disarms it.
local TOUCHID = hs.configdir .. "/bin/touchid"
local sensors, unlockWatcher, armedIcon, authTask

local function disarm()
  for _, s in ipairs(sensors) do s:stop() end
  sensors = nil
  if unlockWatcher then unlockWatcher:stop() unlockWatcher = nil end
  if armedIcon then armedIcon:delete() armedIcon = nil end
  hs.caffeinate.set("displayIdle", false)
  hs.caffeinate.set("systemIdle", false)
end

local function trip()
  if unlockWatcher then return true end -- already tripped
  for _, s in ipairs(sensors) do s:stop() end
  if authTask then authTask:terminate() end -- dismiss the Touch ID prompt
  hs.caffeinate.set("displayIdle", false) -- display may sleep once locked; systemIdle stays held
  hs.caffeinate.lockScreen()
  unlockWatcher = hs.caffeinate.watcher.new(function(e)
    if e == hs.caffeinate.watcher.screensDidUnlock then disarm() end
  end):start()
  return true -- swallow the input that tripped it
end

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "l", function()
  if sensors then return end
  local t = hs.eventtap.event.types
  local powerSource
  sensors = {
    hs.eventtap.new({
      t.keyDown, t.flagsChanged, t.mouseMoved, t.scrollWheel,
      t.leftMouseDown, t.rightMouseDown, t.otherMouseDown,
      t.gesture, t.magnify, t.swipe, t.rotate, t.smartMagnify,
      t.systemDefined, -- media/volume/brightness keys and the power button
    }, trip),
    -- the Dock handles three-finger space swipes itself, so the tap alone may miss them
    hs.spaces.watcher.new(trip),
    -- fires on every battery change, so compare against the source at arm time
    hs.battery.watcher.new(function()
      if hs.battery.powerSource() ~= powerSource then trip() end
    end),
    hs.usb.watcher.new(function(e)
      if e.eventType == "added" then trip() end
    end),
  }
  armedIcon = hs.menubar.new():setTitle("⚠︎ armed")
  hs.caffeinate.set("displayIdle", true)
  hs.caffeinate.set("systemIdle", true)
  hs.alert.show("tripwire armed")
  -- grace period so releasing the hotkey / nudging the trackpad doesn't trip it
  hs.timer.doAfter(1.5, function()
    if not sensors then return end
    powerSource = hs.battery.powerSource()
    for _, s in ipairs(sensors) do s:start() end
    authTask = hs.task.new(TOUCHID, function(code)
      authTask = nil
      if unlockWatcher then return end -- tripped while prompting
      if code == 0 then
        disarm()
        hs.alert.show("tripwire disarmed")
      else
        trip()
      end
    end, { "disarm the tripwire" }):start()
  end)
end)

hs.alert.show("hammerspoon ready", 0.8)
