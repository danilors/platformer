player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
player.speed = 240
player.animation = animations.idle
player:setFixedRotation(true)
player.isMoving = false
player.direction = 1
player.grounded = true
player.impulse = -5000
print('loading player data')
player.playerUpdate = function(dt)
    if player.body then
        player.isMoving = false

        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {"Platform"})
        if #colliders > 0 then
            player.grounded = true
        else
            player.grounded = false
        end

        local x, y = player:getPosition()
        if love.keyboard.isDown("right") then
            player:setX(x + (player.speed * dt))
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown("left") then
            player:setX(x - (player.speed * dt))
            player.isMoving = true
            player.direction = -1
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

    if player.grounded then
        if player.isMoving then
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end
    player.animation:update(dt)
end

player.drawPlayer = function()
    if player.body then
        local rotation = nil
        local playerXScale = 0.25 * player.direction
        local px, py = player:getPosition()
        local offsetX = 130
        local offsetY = 300
        player.animation:draw(sprites.playerSheet, px, py, rotation, playerXScale, 0.25, offsetX, offsetY)
    end
end
