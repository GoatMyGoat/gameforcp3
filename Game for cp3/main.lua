function love.load() --loads when game is run 
    player = { -- values for player migrated to own script when more is added
        y = 200,
        x = 400,
        speed = 1,
        sprite =  love.graphics.newImage("sprites/player-no-ani.png")
    }
 
end
function love.update(dt) --what the game checks every frame the is running.
    if love.keyboard.isDown("right") then 
        player.x=player.x+player.speed+dt
    end
    if love.keyboard.isDown("left") then 
        player.x=player.x-player.speed+dt
    end
    if love.keyboard.isDown("up") then 
        player.y=player.y-player.speed+dt
    end
    if love.keyboard.isDown("down") then 
        player.y=player.y+player.speed+dt
    end
    
end
function love.draw()-- for graphics 
    love.graphics.draw(player.sprite,player.x,player.y)
end