function love.load()
    wf = require "libraries.windfield.windfield"
    worldSleep = false
    world = wf.newWorld(0, 800, worldSleep)

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

function love.update(dt)
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

function love.draw()
    world:draw()
end

love.keypressed = function(key)
    if key == "up" then
        player:applyLinearImpulse(0, -7000)
    end
end
