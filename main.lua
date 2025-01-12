love.load = function()
    print("loading love game")
    love.window.setMode(1000, 768)

    anim8 = require "libraries.anim8.anim8"
    sti = require "libraries/Simple-Tiled-Implementation/sti"
    cameraFile = require "libraries/hump/camera"

    cam = cameraFile()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage("assets/sprites/playerSheet.png")
    sprites.enemySheet = love.graphics.newImage("assets/sprites/enemySheet.png")

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrip = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

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

    animations.enemy = anim8.newAnimation(enemyGrip("1-2", 1), 0.03)

    wf = require "libraries.windfield.windfield"
    worldSleep = false
    world = wf.newWorld(0, 800, worldSleep)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("Platform")
    world:addCollisionClass("Player" --[[ , {ignores = {'Platform'}} ]])
    world:addCollisionClass("Danger")

    require("player")
    require("enemy")

    -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    -- dangerZone:setType("static")

    platforms = {}

    loadMap()

   
end

love.update = function(dt)
    world:update(dt)
    gameMap:update(dt)
    player.playerUpdate(dt)
    updateEnemies(dt)
    if player.body then
        local px, py = player:getPosition()
        cam:lookAt(px, love.graphics.getHeight() / 2)
    end
end

love.draw = function()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    world:draw()
    player.drawPlayer()
    drawEnemies()
    cam:detach()
end

love.keypressed = function(key)
    if key == "up" then
        if player.grounded then
            local impulse = -5000
            player:applyLinearImpulse(0, impulse)
        end
    end
end

love.mousepressed = function(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {"Platform", "Danger"})
        for i, c in ipairs(colliders) do
            -- c:destroy()
        end
    end
end

loadMap = function()
    print("loading map data")
    gameMap = sti("assets/sprites/maps/level1.lua")
    print("start load platforms")
    for i, obj in pairs(gameMap.layers["platforms"].objects) do
        print("load platform: " .. i)
        spwanPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    print("start load enemies")
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        print("load enemy: " .. i)
        spawnEnemy(obj.x, obj.y)
    end
end

function spwanPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType("static")
        table.insert(platforms, platform)
    end
end
