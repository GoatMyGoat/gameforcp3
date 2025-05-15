boss = {}

function boss.load()
    boss.x = 640 -- Start in the middle of the screen
    boss.y = 100
    boss.sprite = love.graphics.newImage("sprites/TankBoss.png")
    boss.width = boss.sprite:getWidth()
    boss.height = boss.sprite:getHeight()
    -- Calculate hitbox dimensions based on sprite and visual inspection
    boss.hitboxWidth = boss.width  -- 60% of sprite width
    boss.hitboxHeight = boss.height * 0.5-- 20% of sprite height
    -- Position the hitbox to match the tank body based on visual inspection
    boss.hitboxOffsetX = boss.width * 0.45   -- Offset from left edge
    boss.hitboxOffsetY = 210 -- Offset from top edge
    boss.speed = 100
    boss.direction = 1 -- 1 for right, -1 for left
    boss.health = 3
    boss.maxHealth = 3
    boss.bulletTimer = 0
    boss.bulletInterval = 2 -- Shoot every 2 seconds
    boss.bulletColor = "red" -- Alternates between red and blue
end

function boss.update(dt)
    -- Move back and forth
    boss.x = boss.x + boss.speed * boss.direction * dt
    
    -- Change direction when reaching screen edges
    if boss.x > love.graphics.getWidth() - boss.width then
        boss.direction = -1
    elseif boss.x < 0 then
        boss.direction = 1
    end
    
    -- Shoot bullets periodically
    boss.bulletTimer = boss.bulletTimer + dt
    if boss.bulletTimer >= boss.bulletInterval then
        boss.bulletTimer = 0
        
        -- Fire bullet at player from the center of the hitbox
        local bossHitboxX = boss.x + boss.hitboxOffsetX
        local bossHitboxY = boss.y + boss.hitboxOffsetY
        
        local bulletX = bossHitboxX
        local bulletY = bossHitboxY + boss.hitboxHeight/2
        
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
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        
        -- Only player bullets can hit the boss
        local bossHitboxX = boss.x + boss.hitboxOffsetX
        local bossHitboxY = boss.y + boss.hitboxOffsetY
        
        if b.isPlayerBullet and CheckCollision(
            bossHitboxX - boss.hitboxWidth/2, bossHitboxY - boss.hitboxHeight/2, boss.hitboxWidth, boss.hitboxHeight,
            b.x - b.radius, b.y - b.radius, b.radius * 2, b.radius * 2
        ) then
            boss.health = boss.health - 1
            table.remove(bullet.list, i)
            
            -- Boss is defeated
            if boss.health <= 0 then
                boss.active = false
            end
        end
    end
end

function boss.draw()
    if boss.health > 0 then
        love.graphics.draw(boss.sprite, boss.x, boss.y)
        
        -- Draw health bar at the bottom of the screen
        local barWidth = love.graphics.getWidth()
        local barHeight = 20
        local barY = love.graphics.getHeight() - barHeight
        
        -- Background of health bar
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 0, barY, barWidth, barHeight)
        
        -- Health portion
        local healthWidth = (boss.health / boss.maxHealth) * barWidth
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", 0, barY, healthWidth, barHeight)
        
        -- Reset color
        love.graphics.setColor(1, 1, 1)
        
        -- Draw health text
        local font = love.graphics.newFont(16)
        love.graphics.setFont(font)
        love.graphics.print("Boss Health: " .. boss.health .. "/" .. boss.maxHealth, barWidth/2 - 60, barY + 2)
        love.graphics.setFont(love.graphics.newFont())
    end
end

return boss