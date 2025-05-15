-- Player module for handling player character
local player = {}
local bullet

-- Constants
local PLAYER_SPEED = 300
local MAX_HEALTH = 3
local MAX_BULLETS = 3
local STARTING_BULLETS = 0
local BULLET_COOLDOWN = 0.3
local COLOR_SWAP_COOLDOWN = 0.5
local HEART_SPACING = 5

-- Radial bullet display constants
local BULLET_DISPLAY_RADIUS = 30
local BULLET_SEGMENT_WIDTH = 8
local BULLET_SEGMENT_GAP = 5
local BULLET_DISPLAY_X = 50
local BULLET_DISPLAY_Y = 50
local BULLET_ANIMATION_DURATION = 0.3

-- Private variables
local colorSwapCooldown = 0
local canSwapColor = true
local bulletAnimations = {
    gained = {active = false, timer = 0, index = 0},
    lost = {active = false, timer = 0, index = 0}
}

function player.load()
    bullet = require "bullet"
    bullet.setPlayer(player)
    
    -- Position
    player.x = 400
    player.y = 200
    
    -- Expose bullet animations to other modules
    player.bulletAnimations = bulletAnimations
    
    -- Sprite offsets (for drawing the sprite at the correct position)
    player.sprite_offset_x = -40
    player.sprite_offset_y = -110
    
    -- Load sprites
    player.spriteRed = love.graphics.newImage("sprites/player-no-ani.png")
    player.spriteBlue = love.graphics.newImage("sprites/player-no-ani-blue.png")
    player.sprite = player.spriteRed
    
    -- Load heart sprites for health display
    player.heartFull = love.graphics.newImage("sprites/Heart-Full.png")
    player.heartEmpty = love.graphics.newImage("sprites/Heart-Empty.png")
    player.heartWidth = player.heartFull:getWidth()
    player.heartHeight = player.heartFull:getHeight()
    player.heartSpacing = HEART_SPACING
    
    -- Get dimensions from sprite
    player.spriteWidth = player.sprite:getWidth()
    player.spriteHeight = player.sprite:getHeight()
    
    -- Hitbox (smaller than the full sprite for better gameplay)
    player.width = player.spriteWidth / 2
    player.height = player.spriteHeight / 2
    player.hitboxOffsetX = player.sprite_offset_x + 30
    player.hitboxOffsetY = player.sprite_offset_y + 60
    
    -- Game stats
    player.speed = PLAYER_SPEED
    player.health = MAX_HEALTH
    player.bulletCount = STARTING_BULLETS
    player.bulletCooldown = 0
    player.bulletCooldownMax = BULLET_COOLDOWN
    
    -- State
    player.colorSwap = true -- true = red, false = blue
    
    -- UI
    player.uiFont = love.graphics.newFont(25)
end

function player.update(dt)
    -- Get screen dimensions
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Calculate hitbox boundaries
    local hitboxLeft = player.x + player.hitboxOffsetX
    local hitboxRight = hitboxLeft + player.width
    local hitboxTop = player.y + player.hitboxOffsetY
    local hitboxBottom = hitboxTop + player.height
    
    -- Update bullet animations
    if bulletAnimations.gained.active then
        bulletAnimations.gained.timer = bulletAnimations.gained.timer + dt
        if bulletAnimations.gained.timer >= BULLET_ANIMATION_DURATION then
            bulletAnimations.gained.active = false
        end
    end

    if bulletAnimations.lost.active then
        bulletAnimations.lost.timer = bulletAnimations.lost.timer + dt
        if bulletAnimations.lost.timer >= BULLET_ANIMATION_DURATION then
            bulletAnimations.lost.active = false
        end
    end
    
    -- Movement with screen boundary checks
    if love.keyboard.isDown("d") then
        -- Only move right if not at right edge of screen
        if hitboxRight + player.speed * dt < screenWidth then
            player.x = player.x + player.speed * dt
        else
            -- Clamp to screen edge
            player.x = screenWidth - player.width - player.hitboxOffsetX
        end
    end
    if love.keyboard.isDown("a") then
        -- Only move left if not at left edge of screen
        if hitboxLeft - player.speed * dt > 0 then
            player.x = player.x - player.speed * dt
        else
            -- Clamp to screen edge
            player.x = -player.hitboxOffsetX
        end
    end
    if love.keyboard.isDown("w") then
        -- Only move up if not at top edge of screen
        if hitboxTop - player.speed * dt > 0 then
            player.y = player.y - player.speed * dt
        else
            -- Clamp to screen edge
            player.y = -player.hitboxOffsetY
        end
    end
    if love.keyboard.isDown("s") then
        -- Only move down if not at bottom edge of screen
        if hitboxBottom + player.speed * dt < screenHeight then
            player.y = player.y + player.speed * dt
        else
            -- Clamp to screen edge
            player.y = screenHeight - player.height - player.hitboxOffsetY
        end
    end
    
    -- Color swapping
    if love.keyboard.isDown("space") and canSwapColor then
        player.colorSwap = not player.colorSwap
        -- Update sprite based on color
        player.sprite = player.colorSwap and player.spriteRed or player.spriteBlue
        canSwapColor = false
        colorSwapCooldown = COLOR_SWAP_COOLDOWN
    end
    
    -- Update color swap cooldown
    if not canSwapColor then
        colorSwapCooldown = colorSwapCooldown - dt
        if colorSwapCooldown <= 0 then
            canSwapColor = true
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
        local centerX = playerHitboxX + player.width/2
        local centerY = playerHitboxY + player.height/2
        
        bullet.fire(centerX, centerY, mx, my)
        player.bulletCount = player.bulletCount - 1
        player.bulletCooldown = player.bulletCooldownMax
        
        -- Add animation for losing a bullet
        bulletAnimations.lost.active = true
        bulletAnimations.lost.timer = 0
        bulletAnimations.lost.index = player.bulletCount + 1
    end
    
    -- Ensure health doesn't go below 0
    if player.health <= 0 then
        player.health = 0
    end
end

function player.draw()
    -- Draw player sprite
    love.graphics.draw(player.sprite, player.x + player.sprite_offset_x, player.y + player.sprite_offset_y)
    
    -- Draw health bar (hearts) below the player
    player.drawHealthBar()
    
    -- Draw radial bullet display instead of text
    player.drawBulletDisplay()
end

-- Function to draw the radial bullet display
function player.drawBulletDisplay()
    local x, y = BULLET_DISPLAY_X, BULLET_DISPLAY_Y
    local radius = BULLET_DISPLAY_RADIUS
    
    -- Draw background circle (darker)
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.circle("fill", x, y, radius)
    
    -- Draw bullet segments
    for i = 1, MAX_BULLETS do
        local angle = (i - 1) * (2 * math.pi / MAX_BULLETS)
        local segmentX = x + math.cos(angle) * (radius - BULLET_SEGMENT_WIDTH/2)
        local segmentY = y + math.sin(angle) * (radius - BULLET_SEGMENT_WIDTH/2)
        
        -- Determine if this segment should be lit
        local isLit = i <= player.bulletCount
        
        -- Set color based on player's current color and whether segment is lit
        if isLit then
            if player.colorSwap then -- Red
                love.graphics.setColor(1, 0.3, 0.3, 1)
            else -- Blue
                love.graphics.setColor(0.3, 0.3, 1, 1)
            end
            
            -- Add animation effects for newly gained bullets
            if bulletAnimations.gained.active and bulletAnimations.gained.index == i then
                local progress = bulletAnimations.gained.timer / BULLET_ANIMATION_DURATION
                local pulseScale = 1 + 0.3 * math.sin(progress * math.pi)
                love.graphics.circle("fill", segmentX, segmentY, BULLET_SEGMENT_WIDTH * pulseScale)
            else
                love.graphics.circle("fill", segmentX, segmentY, BULLET_SEGMENT_WIDTH)
            end
        else
            -- Empty bullet slot
            love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
            love.graphics.circle("line", segmentX, segmentY, BULLET_SEGMENT_WIDTH)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Function to draw the health bar with heart sprites
function player.drawHealthBar()
    -- Calculate position for hearts (centered below the player)
    local playerHitboxX = player.x + player.hitboxOffsetX
    local playerHitboxY = player.y + player.hitboxOffsetY
    local totalWidth = (player.heartWidth * MAX_HEALTH) + (player.heartSpacing * (MAX_HEALTH - 1))
    local startX = playerHitboxX + (player.width / 2) - (totalWidth / 2)
    local startY = playerHitboxY + player.height + 10 -- 10 pixels below player hitbox
    
    -- Draw hearts based on current health
    for i = 1, MAX_HEALTH do
        local heartX = startX + (i-1) * (player.heartWidth + player.heartSpacing)
        local heartImage = (i <= player.health) and player.heartFull or player.heartEmpty
        love.graphics.draw(heartImage, heartX, startY)
    end
end

return player