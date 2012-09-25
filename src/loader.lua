local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local fonts = require 'fonts'
local state = Gamestate.new()

local home = require 'menu'
local nextState = 'home'
local nextPlayer = nil

local import_levels = {
    ['valley']      = 'valley',
    ['gay-island']  = 'gay-island',
    ['gay-island2'] = 'gay-island2',
    ['abedtown']    = 'newtown',
    ['lab']         = 'lab',
    ['house']       = 'house',
    ['studyroom']   = 'studyroom',
    ['hallway']     = 'hallway',
    ['forest']      = 'forest',
    ['forest2']     = 'forest2',
    ['black-caverns']      = 'black-caverns',
    ['village-forest']     = 'village-forest',
    ['town']               = 'town',
    ['tavern']             = 'tavern',
    ['blacksmith']         = 'blacksmith',
    ['greendale-exterior'] = 'greendale-exterior',
    ['deans-office-1']     = 'deans-office-1',
    ['deans-office-2']     = 'deans-office-2',
    ['deans-closet']       = 'deans-closet',
    ['baseball']    = 'baseball',
    ['dorm-lobby']  = 'dorm-lobby',
    ['borchert-hallway']   = 'borchert-hallway',
    ['admin-hallway']      = 'admin-hallway',
    ['class-hallway-1']    = 'class-hallway-1',
    ['class-hallway-2']    = 'class-hallway-2',
    ['rave-hallway']       = 'rave-hallway',
    ['class-basement']     = 'class-basement',
    ['gazette-office-1']   = 'gazette-office-1',
    ['gazette-office-2']   = 'gazette-office-2',
}
local import_interfaces = {
    ['overworld']   = 'overworld',
    ['credits']     = 'credits',
    ['select']      = 'select',
    ['home']        = 'menu',
    ['pause']       = 'pause',
    ['cheatscreen'] = 'cheatscreen',
    ['instructions']= 'instructions',
    ['options']     = 'options',
    ['blackjackgame']      = 'blackjackgame',
}

function state:init()
    state.finished = false
    state.current = 1
    state.assets = {}

    for k, v in pairs(import_levels) do
        table.insert(state.assets, {'level', k})
    end

    for k, v in pairs(import_interfaces) do
        table.insert(state.assets, {'interface', k})
    end

    state.step = 240 / # self.assets
end

function state:update(dt)
    if self.finished then
        return
    end

    local asset = state.assets[self.current]

    if asset ~= nil then
        self:loadAsset(asset)
        self.current = self.current + 1
    else
        self.finished = true
        self:switch()
    end
end

function state:loadAsset(asset_data)
    local atype = asset_data[1]
    local aname = asset_data[2]
    local avalue = nil
    if atype == "level" then
        avalue = Level.new(import_levels[aname])
    else
        avalue = require(import_interfaces[aname])
    end
    Gamestate.load(aname, avalue)
end

function state:switch()
    Gamestate.switch(nextState,nextPlayer)
end

function state:target(state,player)
    nextState = state
    nextPlayer = player
end

function state:draw()
    love.graphics.rectangle('line', 
                            window.width / 2 - 120,
                            window.height / 2 - 10,
                            240,
                            20)
    love.graphics.rectangle('fill', 
                            window.width / 2 - 120,
                            window.height / 2 - 10,
                            (self.current - 1) * self.step,
                            20)
end

return state
