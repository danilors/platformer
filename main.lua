love.load = function()
    print("loading love game")
    love.window.setMode(1000, 768)

    anim8 = require "libraries.anim8.anim8"
    sti = require "libraries/Simple-Tiled-Implementation/sti"
    cameraFile = require "libraries/hump/camera"

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("assets/media/jump.wav", "static")
    sounds.music = love.audio.newSource("assets/media/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.2)
    sounds.music:play()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage("assets/sprites/playerSheet.png")
    sprites.enemySheet = love.graphics.newImage("assets/sprites/enemySheet.png")
    sprites.background = love.graphics.newImage("assets/sprites/background.png")

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
    world = wf.newWorld(0, 500, worldSleep)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("Platform")
    world:addCollisionClass("Player" --[[ , {ignores = {'Platform'}} ]])
    world:addCollisionClass("Danger")

    require("player")
    require("enemy")
    require("libraries/show")

    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType("static")

    platforms = {}

    flagX = 0
    flagY = 0
    saveData = {}
    saveData.currentLevel = "level1"

    if love.filesystem.getInfo("data.lua") then
        print("loading saved data")
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)
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

    local colliders = world:queryCircleArea(flagX, flagY, 10, {"Player"})
    if #colliders > 0 then
        if saveData.currentLevel == "level1" then
            loadMap("level2")
        elseif saveData.currentLevel == "level2" then
            loadMap("level1")
        end
    end
end

love.draw = function()
    love.graphics.draw(sprites.background, 0, 0)
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
            player:applyLinearImpulse(0, player.impulse)
            sounds.jump:play()
        end
    end
    if key == "r" then
        loadMap("level2")
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

destroyAll = function()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end

loadMap = function(mapName)
    saveData.currentLevel = mapName
    dir = love.filesystem.getSaveDirectory()
    print("writing data in: " .. dir)
    dataSaved = love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    print("data was saved?: " .. string.format("%s", dataSaved))
    destroyAll()
    player:setPosition(playerStartX, playerStartY)

    print("loading map data")
    gameMap = sti("assets/sprites/maps/" .. mapName .. ".lua")
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
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end

function spwanPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType("static")
        table.insert(platforms, platform)
    end
end
