bullet = {}
bullet.list = {}  -- holds all active bullets

function bullet.fire(x, y, dir_x, dir_y)
    local speed = 200
    
    local vec_x = dir_x - x
    local vec_y = dir_y - y
    local angle = math.atan2(vec_y, vec_x)

    local dx = math.cos(angle) * speed
    local dy = math.sin(angle) * speed

    local newBullet = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        radius = 5,
        color = player.colorSwap and "red" or "blue", -- Match player's current color
        isPlayerBullet = true
    }
    
    table.insert(bullet.list, newBullet)
end

function bullet.fireBoss(x, y, dir_x, dir_y, bulletColor)
    local speed = 150
    
    local vec_x = dir_x - x
    local vec_y = dir_y - y
    local angle = math.atan2(vec_y, vec_x)

    local dx = math.cos(angle) * speed
    local dy = math.sin(angle) * speed

    local newBullet = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        radius = 8,
        color = bulletColor, -- "red" or "blue"
        isPlayerBullet = false
    }
    
    table.insert(bullet.list, newBullet)
end

function bullet.update(dt)
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt

        -- Check for collision with player (only for boss bullets)
        local playerHitboxX = player.x + player.hitboxOffsetX
        local playerHitboxY = player.y + player.hitboxOffsetY
        
        if not b.isPlayerBullet and CheckCollision(
            playerHitboxX, playerHitboxY, player.width, player.height,
            b.x - b.radius, b.y - b.radius, b.radius * 2, b.radius * 2
        ) then
            -- If colors match, player catches the bullet
            local playerColor = player.colorSwap and "red" or "blue"
            if playerColor == b.color then
                player.bulletCount = player.bulletCount + 1
            else
                player.health = player.health - 1
            end
            table.remove(bullet.list, i)
        -- Remove bullet if it goes off screen
        elseif b.x + b.radius < 0 or b.x - b.radius > love.graphics.getWidth() or
               b.y + b.radius < 0 or b.y - b.radius > love.graphics.getHeight() then
            table.remove(bullet.list, i)
        end
    end
end

function bullet.draw()
    for _, b in ipairs(bullet.list) do
        if b.color == "red" then
            love.graphics.setColor(1, 0, 0) -- Red
        else
            love.graphics.setColor(0, 0, 1) -- Blue
        end
        
        love.graphics.circle("fill", b.x, b.y, b.radius)
        love.graphics.setColor(1, 1, 1) -- Reset color
    end
end

return bullet
