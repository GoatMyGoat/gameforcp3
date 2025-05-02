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
        radius = 5
    }
    
    table.insert(bullet.list, newBullet)
end

function bullet.update(dt)
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt

        -- Remove bullet if it goes off screen
        if b.x + b.radius < 0 or b.x - b.radius > love.graphics.getWidth() or
           b.y + b.radius < 0 or b.y - b.radius > love.graphics.getHeight() then
            table.remove(bullet.list, i)
        end
    end
end

function bullet.draw()
    for _, b in ipairs(bullet.list) do
        love.graphics.circle("fill", b.x, b.y, b.radius)
    end
end

return bullet
