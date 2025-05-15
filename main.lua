local bullet = require "bullet"
local player = require "player"
local boss = require "boss"

-- Win sequence final message
local winMessage = "You have transcended."

function love.load() --loads when game is run
    print("hiya")
    player.load()
    boss.load()
    
    -- Load tower images
    towerImage = love.graphics.newImage("sprites/tower.png")
    towerDoorImage = love.graphics.newImage("sprites/tower-door.png")
    towerWidth, towerHeight = towerImage:getDimensions()
    
    -- Calculate tower position in bottom right corner (with 20px padding)
    screenWidth, screenHeight = love.graphics.getDimensions()
    towerX = screenWidth - towerWidth - 20
    towerY = screenHeight - towerHeight
    
    -- Create tower door hitbox (60x120 at bottom middle of tower)
    towerDoorWidth = 60
    towerDoorHeight = 120
    towerDoorX = towerX + (towerWidth / 2) - (towerDoorWidth / 2)
    towerDoorY = towerY + towerHeight - towerDoorHeight
    
    -- Game state
    gameState = {
        gameOver = false,
        bossDefeated = false,
        inVoid = false,
        debugMode = false, -- Debug mode flag for showing hitboxes
        
        -- Win sequence state
        winSequence = {
            active = false,
            timer = 0,
            messageFade = 0,
            silhouetteProgress = 0,
            fadeToBlackProgress = 0,
            completed = false
        }
    }
    
end

-- Start the win sequence
function startWinSequence()
    gameState.winSequence.active = true
    gameState.winSequence.timer = 0
    gameState.winSequence.messageFade = 0
    gameState.winSequence.silhouetteProgress = 0
    gameState.winSequence.fadeToBlackProgress = 0
    gameState.winSequence.completed = false
end

function love.update(dt) --what the game checks every frame the is running.
    -- Only update if game is not over
    if not gameState.gameOver then
        player.update(dt)
        
        -- Only update bullets and boss if not in void and boss not defeated
        if not gameState.inVoid and not gameState.bossDefeated then
            bullet.update(dt)
            boss.update(dt)
            
            -- Check game state
            if player.health <= 0 then
                gameState.gameOver = true
            end
            
            if boss.health <= 0 then
                gameState.bossDefeated = true
            end
        end
        
        -- Check if player enters tower door (only when boss is defeated)
        if gameState.bossDefeated and not gameState.inVoid then
            local playerHitboxX = player.x + player.hitboxOffsetX
            local playerHitboxY = player.y + player.hitboxOffsetY
            
            if CheckCollision(
                playerHitboxX, playerHitboxY, player.width, player.height,
                towerDoorX, towerDoorY, towerDoorWidth, towerDoorHeight
            ) then
                gameState.inVoid = true
                startWinSequence() -- Start the win sequence when entering void
            end
        end
        
        -- Update win sequence if active
        if gameState.inVoid and gameState.winSequence.active then
            updateWinSequence(dt)
        end
        
    end
end

-- Update the win sequence state
function updateWinSequence(dt)
    local ws = gameState.winSequence
    ws.timer = ws.timer + dt
    
    -- Phase 1 (0-3s): Message fades in
    if ws.timer < 3 then
        ws.messageFade = math.min(ws.timer / 2, 1) -- Fade in over 2 seconds
    end
    
    -- Phase 2 (3-6s): Player fades to black
    if ws.timer >= 3 and ws.timer < 6 then
        ws.silhouetteProgress = (ws.timer - 3) / 3 -- Complete over 3 seconds
    elseif ws.timer >= 6 then
        ws.silhouetteProgress = 1
    end
    
    -- Phase 3 (6-10s): Concentric circles fade to black
    if ws.timer >= 6 and ws.timer < 10 then
        ws.fadeToBlackProgress = (ws.timer - 6) / 4 -- Complete over 4 seconds
    elseif ws.timer >= 10 then
        ws.fadeToBlackProgress = 1
    end
    
    -- Phase 4 (12s): Close the window
    if ws.timer > 12 and not ws.completed then
        ws.completed = true
        love.event.quit() -- Close the window
    end
end

function love.keypressed(key)
    -- Toggle debug mode with F1 key
    if key == "f1" then
        gameState.debugMode = not gameState.debugMode
        print("Debug mode: " .. (gameState.debugMode and "ON" or "OFF"))
    end
end

function love.draw()-- for graphics
    if gameState.inVoid then
        -- Draw white void background
        love.graphics.setBackgroundColor(1, 1, 1)
        
        -- Draw void elements if win sequence is active
        if gameState.winSequence.active then
            drawWinSequence()
        end
        
        -- Draw player in void (with silhouette effect if applicable)
        if gameState.winSequence.active and gameState.winSequence.silhouetteProgress > 0 then
            -- Draw player with silhouette effect
            drawPlayerSilhouette()
        else
            -- Draw normal player
            player.draw()
        end
    else
        -- Reset background color
        love.graphics.setBackgroundColor(0, 0, 0)
        
        -- Draw tiled background
        local tile = love.graphics.newImage("sprites/tile1.png")
        for tx=0,1280 ,65 do
            for ty=0,720,65 do
                love.graphics.draw(tile,tx,ty)
            end
        end
        
        -- Draw tower in bottom right corner (change sprite if boss is defeated)
        if gameState.bossDefeated then
            love.graphics.draw(towerDoorImage, towerX, towerY)
        else
            love.graphics.draw(towerImage, towerX, towerY)
        end
        
        -- Draw game elements
        player.draw()
        boss.draw()
        bullet.draw() -- Draw bullets last so they appear on top
        
        -- Draw game over message if applicable
        if gameState.gameOver then
            love.graphics.setColor(1, 0, 0)
            love.graphics.setFont(love.graphics.newFont(40))
            love.graphics.printf("GAME OVER", 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), "center")
            love.graphics.setColor(1, 1, 1)
        end
    end
    
    -- Draw hitboxes in debug mode
    if gameState.debugMode then
        drawHitboxes()
    end
end

-- Draw the win sequence elements
function drawWinSequence()
    local ws = gameState.winSequence
    
    -- Draw vignette effect (concentric circles)
    local intensity = 0.3 + 0.1 * math.sin(ws.timer * 0.5) -- Subtle pulsing between 0.2 and 0.4
    drawVignette(intensity, ws.fadeToBlackProgress)
    
    -- Draw text message
    if ws.messageFade > 0 then
        love.graphics.setColor(0, 0, 0, ws.messageFade)
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf(winMessage, 0, screenHeight * 0.4, screenWidth, "center")
        love.graphics.setColor(1, 1, 1)
    end
end

-- Draw the player with silhouette effect
function drawPlayerSilhouette()
    -- Save current color
    local r, g, b, a = love.graphics.getColor()
    
    -- Calculate silhouette color based on progress (white to black)
    local colorValue = 1 - gameState.winSequence.silhouetteProgress
    love.graphics.setColor(colorValue, colorValue, colorValue)
    
    -- Draw player sprite
    love.graphics.draw(player.sprite, player.x + player.sprite_offset_x, player.y + player.sprite_offset_y)
    
    -- Don't draw health or bullets in silhouette mode
    
    -- Restore color
    love.graphics.setColor(r, g, b, a)
end

-- Draw vignette effect
function drawVignette(intensity, fadeToBlackProgress)
    fadeToBlackProgress = fadeToBlackProgress or 0
    
    -- Draw a full-screen black rectangle with increasing opacity for fade-to-black effect
    if fadeToBlackProgress > 0 then
        love.graphics.setColor(0, 0, 0, fadeToBlackProgress)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
    
    -- Draw a gradient from transparent in the center to semi-opaque at the edges
    local segments = 20
    for i = 1, segments do
        -- Calculate alpha based on segment position and intensity
        -- As fadeToBlackProgress increases, the circles become more visible (darker)
        local baseAlpha = (i / segments) * intensity
        local adjustedAlpha = math.min(baseAlpha + fadeToBlackProgress * 0.5, 1)
        
        love.graphics.setColor(0, 0, 0, adjustedAlpha)
        
        -- Draw a rectangle with a hole in the middle
        love.graphics.stencil(function()
            -- As fadeToBlackProgress increases, the inner circles get smaller
            local radiusMultiplier = 1 - fadeToBlackProgress * 0.5
            local innerRadius = screenWidth * (1 - i / segments) * radiusMultiplier
            love.graphics.circle("fill", screenWidth / 2, screenHeight / 2, innerRadius)
        end, "replace", 1)
        
        love.graphics.setStencilTest("notequal", 1)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
        love.graphics.setStencilTest()
    end
    
    love.graphics.setColor(1, 1, 1)
end

-- Function to draw hitboxes for all game objects
function drawHitboxes()
    love.graphics.setColor(0, 1, 0, 0.5) -- Green with transparency
    
    -- Player hitbox (aligned with the visible sprite)
    -- The hitbox should be centered on the player's visible sprite
    local playerHitboxX = player.x + player.hitboxOffsetX
    local playerHitboxY = player.y + player.hitboxOffsetY
    love.graphics.rectangle("line", playerHitboxX, playerHitboxY,
                           player.width, player.height)
    
    -- Draw a dot at player position for reference
    love.graphics.setPointSize(5)
    love.graphics.points(player.x, player.y)
    love.graphics.setColor(1, 0, 0)
    love.graphics.points(playerHitboxX + player.width/2, playerHitboxY + player.height/2)
    
    -- Boss hitbox (if alive)
    if boss.health > 0 and not gameState.inVoid then
        -- Use the boss's calculated hitbox values
        local bossHitboxX = boss.x + boss.hitboxOffsetX
        local bossHitboxY = boss.y + boss.hitboxOffsetY
        love.graphics.rectangle("line", bossHitboxX - boss.hitboxWidth/2, bossHitboxY - boss.hitboxHeight/2,
                               boss.hitboxWidth, boss.hitboxHeight)
        
        -- Draw a dot at boss center for reference
        love.graphics.setColor(1, 0, 0)
        love.graphics.points(bossHitboxX, bossHitboxY)
        love.graphics.setColor(0, 1, 0, 0.5)
    end
    
    -- Tower door hitbox (only when boss is defeated)
    if gameState.bossDefeated and not gameState.inVoid then
        love.graphics.setColor(0, 0, 1, 0.5) -- Blue with transparency
        love.graphics.rectangle("line", towerDoorX, towerDoorY, towerDoorWidth, towerDoorHeight)
        love.graphics.setColor(0, 1, 0, 0.5) -- Back to green
    end
    
    -- Bullet hitboxes
    if not gameState.inVoid then
        for _, b in ipairs(bullet.list) do
            love.graphics.circle("line", b.x, b.y, b.radius)
        end
    end
    
    -- Draw debug text
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("DEBUG MODE (F1 to toggle)", 10, love.graphics.getHeight() - 30)
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)--checks the collision of 2 things
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end
