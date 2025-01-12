love.load = function()
    anim8 = require "libraries.anim8.anim8"
    sprites = {}
    sprites.playerSheet = love.graphics.newImage("assets/sprites/playerSheet.png")

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    spritesItemsIntervalIdle = "1-15"
    spritesRowIdle = 1
    timeIntervalIdle = 0.05
    animations.idle = anim8.newAnimation(grid(spritesItemsIntervalIdle, spritesRowIdle), timeIntervalIdle)

    spritesItemsIntervalJump = "1-7"
    spritesRowJump = 2
    timeIntervalJump = 0.05
    animations.jump = anim8.newAnimation(grid(spritesItemsIntervalJump, spritesRowJump), timeIntervalJump)

    spritesItemsIntervalRun = "1-15"
    spritesRowRun = 3
    timeIntervalRun = 0.05
    animations.run = anim8.newAnimation(grid(spritesItemsIntervalRun, spritesRowRun), timeIntervalRun)

    wf = require "libraries.windfield.windfield"
    worldSleep = false
    world = wf.newWorld(0, 800, worldSleep)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("Platform")
    world:addCollisionClass("Player" --[[ , {ignores = {'Platform'}} ]])
    world:addCollisionClass("Danger")

    require('player')

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType("static")
end

love.update = function(dt)
    world:update(dt)
    player.playerUpdate(dt)
    
end

love.draw = function()
    world:draw()
    player.drawPlayer()
end

love.keypressed = function(key)
    if key == "up" then
        if player.grounded then
            local impulse = -4000
            player:applyLinearImpulse(0, impulse)
        end
    end
end

love.mousepressed = function(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {"Platform", "Danger"})
        for i, c in ipairs(colliders) do
            c:destroy()
        end
    end
end
