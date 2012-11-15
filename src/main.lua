local correctVersion = require 'correctversion'
if correctVersion then

  require 'utils'
  local Gamestate = require 'vendor/gamestate'
  local Level = require 'level'
  local camera = require 'camera'
  local fonts = require 'fonts'
  local sound = require 'vendor/TEsound'
  local window = require 'window'
  local controls = require 'controls'
  local hud = require 'hud'
  local cli = require 'vendor/cliargs'
  local memdebug = nil

  -- XXX Hack for level loading
  Gamestate.Level = Level

  -- will hold the currently playing sources

  function love.load(arg)
    table.remove(arg, 1)
    local state = 'splash'
    local player = nil

    -- SCIENCE!
    love.thread.newThread('ping', 'ping.lua'):start()

    -- set settings
    local options = require 'options'
    options:init()

    cli:add_option("-l, --level=NAME", "The level to display")
    cli:add_option("-c, --character=NAME", "The character to use in the game")
    cli:add_option("-m, --mute=CHANNEL", "Disable sound: all, music, sfx")
    cli:add_option("-debug", "Debug with ZeroBrane Studio IDE")
    cli:add_option("--memdebug", "Debug memory with console output")

    local args = cli:parse(arg)

    if args["level"] ~= "" then
      state = args["level"]
    end

    if args["character"] ~= "" then
      local character = require ('characters/' .. args["c"])
      local costume = love.graphics.newImage('images/characters/' .. args["c"] .. '/base.png')
      player = character.new(costume)
    end

    if args["mute"] == 'all' then
      sound.volume('music',0)
      sound.volume('sfx',0)
    elseif args["mute"] == 'music' then
      sound.volume('music',0)
    elseif args["mute"] == 'sfx' then
      sound.volume('sfx',0)
    end

    if args["debug"] then
      require("mobdebug").start()
      _G['memdebug'] = require "memdebug"
      _G['gamestate'] = Gamestate
      _G['currentLevel'] = Gamestate.currentState
    end

    if args["memdebug"] then
      memdebug = require 'memdebug'
      memdebug:init()
    end

    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(window.scale, window.scale)
    love.graphics.setMode(window.screen_width, window.screen_height)

    Gamestate.switch(state)
  end

  function love.update(dt)
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
    sound.cleanup()
    if memdebug then memdebug:update(dt) end
  end

  function love.keyreleased(key)
    local button = controls.getButton(key)
    if button then Gamestate.keyreleased(button) end
  end

  function love.keypressed(key)
    local button = controls.getButton(key)
    if button then Gamestate.keypressed(button) end
  end

  function love.draw()
    camera:set()
    Gamestate.draw()
    camera:unset()

    if paused then
      love.graphics.setColor(75, 75, 75, 125)
      love.graphics.rectangle('fill', 0, 0, love.graphics:getWidth(),
      love.graphics:getHeight())
      love.graphics.setColor(255, 255, 255, 255)
    end

  end

  -- Override the default screenshot functionality so we can disable the fps before taking it
  local newScreenshot = love.graphics.newScreenshot
  function love.graphics.newScreenshot()
    window.dressing_visible = false
    love.draw()
    local ss = newScreenshot()
    window.dressing_visible = true
    return ss
  end

end
