love.load = function()
    anim8 = require "libraries.anim8.anim8"
    sprites = {}
    sprites.playerSheet = love.graphics.newImage('assets/sprites/playerSheet.png')
    
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    animations = {}
    animations.idle = anim8.newAnimation()
    
    wf = require "libraries.windfield.windfield"
    worldSleep = false
    world = wf.newWorld(0, 800, worldSleep)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("Platform")
    world:addCollisionClass("Player" --[[ , {ignores = {'Platform'}} ]])
    world:addCollisionClass("Danger")

    player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "Player"})
    player.speed = 240
    player:setFixedRotation(true)

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType("static")
end

love.update = function(dt)
    world:update(dt)
    if player.body then
        local x, y = player:getPosition()
        if love.keyboard.isDown("right") then
            player:setX(x + (player.speed * dt))
        end
        if love.keyboard.isDown("left") then
            player:setX(x - (player.speed * dt))
        end
        if love.keyboard.isDown("up") then
            player:setY(y + (player.speed * dt))
        end
        if love.keyboard.isDown("down") then
            player:setY(y - (player.speed * dt))
        end

        if player:enter("Danger") then
            player:destroy()
        end
    end
end

love.draw = function()
    world:draw()
end

love.keypressed = function(key)
    if key == "up" then
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {"Platform"})
        if #colliders > 0 then
            player:applyLinearImpulse(0, -7000)
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
