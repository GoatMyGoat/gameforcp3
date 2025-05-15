player = {} -- makes this file a object that can be called from other files, applys for any thing with a player.__
local downSwap = .5 -- down and r in the future are for cooldowns
local rSwap = true

function player.load()
    require "bullet"
    player.x = 400
    player.y = 200
    player.sprite_offset_x = -40
    player.sprite_offset_y = -110
    player.spriteRed = love.graphics.newImage("sprites/player-no-ani.png")
    player.spriteBlue = love.graphics.newImage("sprites/player-no-ani-blue.png")
    player.sprite = player.spriteRed
    
    -- Load heart sprites for health display
    player.heartFull = love.graphics.newImage("sprites/Heart-Full.png")
    player.heartEmpty = love.graphics.newImage("sprites/Heart-Empty.png")
    player.heartWidth = player.heartFull:getWidth()
    player.heartHeight = player.heartFull:getHeight()
    player.heartSpacing = 5 -- Space between hearts
    -- Get dimensions from sprite
    player.spriteWidth = player.sprite:getWidth()
    player.spriteHeight = player.sprite:getHeight()
    -- Use a smaller hitbox than the full sprite for better gameplay
    player.width = player.spriteWidth / 2 -- 15% of sprite width
    player.height = player.spriteHeight / 2-- 15% of sprite height
    player.hitboxOffsetX = player.sprite_offset_x + 30
    player.hitboxOffsetY = player.sprite_offset_y + 60
    player.speed = 300
    player.health = 3
    player.bulletCount = 3 -- Number of bullets the player has
    player.bulletCooldown = 0 -- Cooldown timer for shooting
    player.bulletCooldownMax = 0.3 -- Maximum cooldown time in seconds
    player.isPlayer = true
    player.colorSwap = true -- true = red, false = blue
end

function player.update(dt)
    if love.keyboard.isDown("d") then player.x = player.x + player.speed * dt end
    if love.keyboard.isDown("a") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("w") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("s") then player.y = player.y + player.speed * dt end -- moving
    if love.keyboard.isDown("space") and rSwap == true  then -- swapping
        player.colorSwap = not player.colorSwap
        -- Update sprite based on color
        if player.colorSwap then
            player.sprite = player.spriteRed
        else
            player.sprite = player.spriteBlue
        end
        rSwap=false
        downSwap = .5
    end
    if rSwap == false then --cooldown for swapping
        downSwap = downSwap - dt
        if downSwap <= 0 then 
            rSwap = true
        end
    end

    -- Update bullet cooldown
    if player.bulletCooldown > 0 then
        player.bulletCooldown = player.bulletCooldown - dt
    end

    -- Fire bullet if mouse is clicked, cooldown is over, and player has bullets
    if love.mouse.isDown(1) and player.bulletCooldown <= 0 and player.bulletCount > 0 then
        local mx, my = love.mouse.getPosition()
        local playerHitboxX = player.x + player.hitboxOffsetX
        local playerHitboxY = player.y + player.hitboxOffsetY
        bullet.fire(playerHitboxX + player.width/2, playerHitboxY + player.height/2, mx, my)
        player.bulletCount = player.bulletCount - 1 -- Decrease bullet count
        player.bulletCooldown = player.bulletCooldownMax -- Reset cooldown
    end
    
    -- Game over check
    if player.health <= 0 then
        -- Handle game over (could be expanded later)
        player.health = 0
    end
end

function player.draw()
    -- Draw player sprite
    love.graphics.draw(player.sprite, player.x + player.sprite_offset_x, player.y + player.sprite_offset_y)
    
    -- Draw health bar (hearts) below the player
    player.drawHealthBar()
    
    -- Draw UI text
    font = love.graphics.newFont(25)
    love.graphics.setFont(font)
    love.graphics.print("Bullets:"..player.bulletCount,1,1) -- Display bullet count only
    love.graphics.newFont()
end

-- Function to draw the health bar with heart sprites
function player.drawHealthBar()
    -- Calculate position for hearts (centered below the player)
    local playerHitboxX = player.x + player.hitboxOffsetX
    local playerHitboxY = player.y + player.hitboxOffsetY
    local totalWidth = (player.heartWidth * 3) + (player.heartSpacing * 2)
    local startX = playerHitboxX + (player.width / 2) - (totalWidth / 2)
    local startY = playerHitboxY + player.height + 10 -- 10 pixels below player hitbox
    
    -- Draw hearts based on current health
    for i = 1, 3 do
        local heartX = startX + (i-1) * (player.heartWidth + player.heartSpacing)
        if i <= player.health then
            -- Draw full heart
            love.graphics.draw(player.heartFull, heartX, startY)
        else
            -- Draw empty heart
            love.graphics.draw(player.heartEmpty, heartX, startY)
        end
    end
end

return player