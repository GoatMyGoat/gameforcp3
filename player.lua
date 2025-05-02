player = {} -- makes this file a object that can be called from other files, applys for any thing with a player.__
local downSwap = .5 -- down and r in the future are for cooldowns
local rSwap = true

function player.load()
    require "bullet"
    player.x = 400
    player.y = 200
    player.sprite_offset_x = -40
    player.sprite_offset_y = -110
    player.width = 25
    player.height = 25
    player.speed = 300
    player.health = 3 
    player.sprite = love.graphics.newImage("sprites/player-no-ani.png")
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
        rSwap=false
        downSwap = .5
    end
    if rSwap == false then --cooldown for swapping
        downSwap = downSwap - dt
        if downSwap <= 0 then 
            rSwap = true
        end
    end

    if love.mouse.isDown(1) then 
        local mx, my = love.mouse.getPosition()
        bullet.fire(player.x, player.y, mx, my)
    end
end

function player.draw()
    love.graphics.draw(player.sprite, player.x + player.sprite_offset_x, player.y + player.sprite_offset_y)
    font = love.graphics.newFont(25)
    love.graphics.setFont(font)
    love.graphics.print("Health:"..player.health,1,1)
    if player.colorSwap == true then 
        love.graphics.print("Red", 1, 25)
    else 
        love.graphics.print("Blue", 1, 25) end
    love.graphics.newFont()
end

return player