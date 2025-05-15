local bullet = require "bullet"
local player = require "player"
local boss = require "boss"

function love.load() --loads when game is run
    print("hiya")
    player.load()
    boss.load()
    
    -- Game state
    gameState = {
        gameOver = false,
        bossDefeated = false,
        debugMode = false -- Debug mode flag for showing hitboxes
    }
end

function love.update(dt) --what the game checks every frame the is running.
    -- Only update if game is not over
    if not gameState.gameOver and not gameState.bossDefeated then
        player.update(dt)
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
end

function love.keypressed(key)
    -- Toggle debug mode with F1 key
    if key == "f1" then
        gameState.debugMode = not gameState.debugMode
        print("Debug mode: " .. (gameState.debugMode and "ON" or "OFF"))
    end
end

function love.draw()-- for graphics
    local tile = love.graphics.newImage("sprites/tile1.png")
    for tx=0,1280 ,65 do
        for ty=0,720,65 do
            love.graphics.draw(tile,tx,ty)
        end
    end
    
    love.graphics.draw(love.graphics.newImage("sprites/tower.png"), 500, 200)
    
    -- Draw game elements
    player.draw()
    bullet.draw()
    boss.draw()
    
    -- Draw game over message if applicable
    if gameState.gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.printf("GAME OVER", 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw victory message if applicable
    if gameState.bossDefeated then
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.printf("BOSS DEFEATED!", 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw hitboxes in debug mode
    if gameState.debugMode then
        drawHitboxes()
    end
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
    if boss.health > 0 then
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
    
    -- Bullet hitboxes
    for _, b in ipairs(bullet.list) do
        love.graphics.circle("line", b.x, b.y, b.radius)
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
