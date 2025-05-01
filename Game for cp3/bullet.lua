 bullet = {}

bullet.list = {}  -- holds all active bullets

function bullet.fire(x, y)
    local mx, my = love.mouse.getPosition()
    print(mx..""..my)
    local speed = 200
    local dir = math.atan(( my - y ), ( mx - x ))
    local dx =  speed * math.cos(dir)
    local dy = speed * math.sin(dir) --im going to be honest, i had some help for the math here, got stuck 
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
