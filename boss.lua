-- Boss module for handling the tank boss enemy
local boss = {}
local bullet = require "bullet"
local player = require "player"

-- Constants
local BOSS_SPEED = 100
local MAX_HEALTH = 3
local BULLET_INTERVAL = 2
local HEALTH_BAR_HEIGHT = 10
local HEALTH_BAR_WIDTH_RATIO = 0.8
local HEALTH_BAR_PADDING = 10
local HEALTH_BAR_BORDER = 2

-- Colors
local COLORS = {
    BLACK = {0, 0, 0},
    RED = {1, 0, 0},
    GREEN = {0, 1, 0},
    WHITE = {1, 1, 1}
}

function boss.load()
    -- Position
    boss.x = 640 -- Start in the middle of the screen
    boss.y = 350
    
    -- Load sprite
    boss.sprite = love.graphics.newImage("sprites/TankBoss.png")
    boss.width = boss.sprite:getWidth()
    boss.height = boss.sprite:getHeight()
    
    -- Hitbox (adjusted to match the tank body visually)
    boss.hitboxWidth = boss.width
    boss.hitboxHeight = boss.height * 0.5
    boss.hitboxOffsetX = boss.width * 0.45
    boss.hitboxOffsetY = 210
    
    -- Movement
    boss.speed = BOSS_SPEED
    boss.direction = 1 -- 1 for right, -1 for left
    
    
    -- Combat stats
    boss.health = MAX_HEALTH
    boss.maxHealth = MAX_HEALTH
    
    -- Bullet firing
    boss.bulletTimer = 0
    boss.bulletInterval = BULLET_INTERVAL
    boss.bulletColor = "red" -- Alternates between red and blue
    
    -- State
    boss.active = true
end

function boss.update(dt)
    -- Only update if boss is active
    if boss.health <= 0 then
        boss.active = false
        return
    end
    
    -- Move back and forth
    boss.x = boss.x + boss.speed * boss.direction * dt
    
    -- Get screen width once
    local screenWidth = love.graphics.getWidth()
    
    -- Change direction when reaching screen edges
    if boss.x > screenWidth - boss.width - 400 then
        boss.direction = -1
    elseif boss.x < 0 then
        boss.direction = 1
    end
    
    -- Shoot bullets periodically
    boss.bulletTimer = boss.bulletTimer + dt
    if boss.bulletTimer >= boss.bulletInterval then
        boss.bulletTimer = 0
        
        -- Calculate bullet spawn position
        local bossHitboxX = boss.x + boss.hitboxOffsetX
        local bossHitboxY = boss.y + boss.hitboxOffsetY
        
        local bulletX = bossHitboxX + 35
        local bulletY = bossHitboxY + boss.hitboxHeight/2 - 250
        
        -- Alternate bullet colors
        if boss.bulletColor == "red" then
            bullet.fireBoss(bulletX, bulletY, player.x, player.y, "red")
            boss.bulletColor = "blue"
        else
            bullet.fireBoss(bulletX, bulletY, player.x, player.y, "blue")
            boss.bulletColor = "red"
        end
    end
    
    -- Check for bullet collisions with boss
    boss.checkBulletCollisions()
end

-- Check for bullet collisions with boss
function boss.checkBulletCollisions()
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        
        -- Only player bullets can hit the boss
        if b.isPlayerBullet then
            local bossHitboxX = boss.x + boss.hitboxOffsetX
            local bossHitboxY = boss.y + boss.hitboxOffsetY
            
            if CheckCollision(
                bossHitboxX - boss.hitboxWidth/2, bossHitboxY - boss.hitboxHeight/2,
                boss.hitboxWidth, boss.hitboxHeight,
                b.x - b.radius, b.y - b.radius,
                b.radius * 2, b.radius * 2
            ) then
                boss.health = boss.health - 1
                table.remove(bullet.list, i)
            end
        end
    end
end

function boss.draw()
    if boss.health > 0 then
        -- Draw boss sprite
        love.graphics.draw(boss.sprite, boss.x, boss.y)
        
        -- Draw health bar
        boss.drawHealthBar()
    end
end

-- Draw the boss health bar
function boss.drawHealthBar()
    -- Calculate health bar dimensions and position
    local barWidth = boss.width * HEALTH_BAR_WIDTH_RATIO
    local barHeight = HEALTH_BAR_HEIGHT
    local barX = boss.x + (boss.width - barWidth) / 2
    local barY = boss.y + boss.height + HEALTH_BAR_PADDING
    
    -- Background/border of health bar (black outline)
    love.graphics.setColor(COLORS.BLACK)
    love.graphics.rectangle(
        "fill",
        barX - HEALTH_BAR_BORDER,
        barY - HEALTH_BAR_BORDER,
        barWidth + (HEALTH_BAR_BORDER * 2),
        barHeight + (HEALTH_BAR_BORDER * 2)
    )
    
    -- Background of health bar (red for empty health)
    love.graphics.setColor(COLORS.RED)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Health portion (green for remaining health)
    local healthWidth = (boss.health / boss.maxHealth) * barWidth
    love.graphics.setColor(COLORS.GREEN)
    love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)
    
    -- Reset color
    love.graphics.setColor(COLORS.WHITE)
end

return boss