local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'

local Turkey = {}
Turkey.__index = Turkey

local sprite = love.graphics.newImage('images/turkey.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

function Turkey.new(node, collider)
    local turkey = {}

    setmetatable(turkey, Turkey)
    turkey.collider = collider
    turkey.dead = false
    turkey.width = 48
    turkey.height = 48
    turkey.damage = 1

    turkey.position = {x=node.x, y=node.y}
    turkey.velocity = {x=0, y=0}
    turkey.state = 'jump'       -- default animation is walk
    turkey.direction = 'left'   -- default animation faces right direction is right
    turkey.animations = {
        jump = {
            right = anim8.newAnimation('once', g('3-4,2'), 0.25),
            left = anim8.newAnimation('once', g('3-4,1'), 0.25)
        },
        walk = {
            right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        },
        dying = jump,
    }

    turkey.bb = collider:addRectangle(node.x, node.y,72,72)
    turkey.bb.node = turkey
    collider:setPassive(turkey.bb)

    return turkey
end


function Turkey:animation()
    return self.animations[self.state][self.direction]
end

-- function Turkey:hit()
--     self.state = 'attack'
--     Timer.add(1, function() 
--         if self.state ~= 'dying' then self.state = 'crawl' end
--     end)
-- end

function Turkey:die()
    -- sound.playSfx( "turkey_kill" )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
end

function Turkey:collide(player, dt, mtv_x, mtv_y)
    if player.rebounding then
        return
    end

    local a = player.position.x < self.position.x and -1 or 1
    local x1,y1,x2,y2 = self.bb:bbox()

    if player.position.y + player.height <= y2 and player.velocity.y > 0 then 
        -- successful attack
        self:die()
        if cheat.jump_high then
            player.velocity.y = -670
        else
            player.velocity.y = -450
        end
        return
    end

    if cheat.god then
        self:die()
        return
    end
    
    if player.invulnerable then
        return
    end
    
    self:hit()

    player:die(self.damage)
    player.bb:move(mtv_x, mtv_y)
    player.velocity.y = -450
    player.velocity.x = 300 * a
end


function Turkey:update(dt, player)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
        return
    end


    if self.position.x > player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if math.abs(self.position.x - player.position.x) < 2 then
        -- stay put
    elseif self.direction == 'left' then
        self.position.x = self.position.x - (10 * dt)
    else
        self.position.x = self.position.x + (10 * dt)
    end

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2 + 10)
end

function Turkey:draw()
    if self.dead then
        return
    end

    self:animation():draw(sprite, math.floor(self.position.x),
    math.floor(self.position.y))
end

return Turkey

