-- Bullet module for handling all projectiles in the game
local bullet = {}
local player

bullet.list = {}  -- Table that holds all active bullets

-- Constants
local PLAYER_BULLET_SPEED = 200
local PLAYER_BULLET_RADIUS = 5
local BOSS_BULLET_SPEED = 150
local BOSS_BULLET_RADIUS = 8

-- Colors
local COLORS = {
    RED = {1, 0, 0},
    BLUE = {0, 0, 1},
    WHITE = {1, 1, 1}
}

-- Set the player reference to resolve circular dependency
function bullet.setPlayer(playerModule)
    player = playerModule
end

-- Create a new player bullet
-- @param x, y: Origin position
-- @param dir_x, dir_y: Target position (for direction calculation)
function bullet.fire(x, y, dir_x, dir_y)
    -- Calculate direction vector
    local vec_x = dir_x - x
    local vec_y = dir_y - y
    local angle = math.atan2(vec_y, vec_x)

    -- Calculate velocity
    local dx = math.cos(angle) * PLAYER_BULLET_SPEED
    local dy = math.sin(angle) * PLAYER_BULLET_SPEED

    -- Create new bullet
    local newBullet = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        radius = PLAYER_BULLET_RADIUS,
        color = player.colorSwap and "red" or "blue", -- Match player's current color
        isPlayerBullet = true
    }
    
    table.insert(bullet.list, newBullet)
end

-- Create a new boss bullet
-- @param x, y: Origin position
-- @param dir_x, dir_y: Target position (for direction calculation)
-- @param bulletColor: Color of the bullet ("red" or "blue")
function bullet.fireBoss(x, y, dir_x, dir_y, bulletColor)
    -- Calculate direction vector
    local vec_x = dir_x - x
    local vec_y = dir_y - y
    local angle = math.atan2(vec_y, vec_x)

    -- Calculate velocity
    local dx = math.cos(angle) * BOSS_BULLET_SPEED
    local dy = math.sin(angle) * BOSS_BULLET_SPEED

    -- Create new bullet
    local newBullet = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        radius = BOSS_BULLET_RADIUS,
        color = bulletColor, -- "red" or "blue"
        isPlayerBullet = false
    }
    
    table.insert(bullet.list, newBullet)
end

-- Update all bullets
-- @param dt: Delta time
function bullet.update(dt)
    -- Get screen dimensions once
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        
        -- Update position
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt

        -- Check for collision with player (only for boss bullets)
        if not b.isPlayerBullet then
            local playerHitboxX = player.x + player.hitboxOffsetX
            local playerHitboxY = player.y + player.hitboxOffsetY
            
            if CheckCollision(
                playerHitboxX, playerHitboxY, player.width, player.height,
                b.x - b.radius, b.y - b.radius, b.radius * 2, b.radius * 2
            ) then
                -- If colors match, player catches the bullet
                local playerColor = player.colorSwap and "red" or "blue"
                if playerColor == b.color then
                    player.bulletCount = player.bulletCount + 1
                    
                    -- Add animation for gaining a bullet
                    if player.bulletAnimations then
                        player.bulletAnimations.gained.active = true
                        player.bulletAnimations.gained.timer = 0
                        player.bulletAnimations.gained.index = player.bulletCount
                    end
                else
                    player.health = player.health - 1
                end
                table.remove(bullet.list, i)
            end
        end
        
        -- Remove bullet if it goes off screen
        if b.x + b.radius < 0 or b.x - b.radius > screenWidth or
           b.y + b.radius < 0 or b.y - b.radius > screenHeight then
            table.remove(bullet.list, i)
        end
    end
end

-- Draw all bullets
function bullet.draw()
    for _, b in ipairs(bullet.list) do
        if b.color == "red" then
            love.graphics.setColor(COLORS.RED)
        else
            love.graphics.setColor(COLORS.BLUE)
        end
        
        love.graphics.circle("fill", b.x, b.y, b.radius)
    end
    
    -- Reset color
    love.graphics.setColor(COLORS.WHITE)
end

return bullet
