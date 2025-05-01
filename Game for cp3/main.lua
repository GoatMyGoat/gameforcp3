local bullet = require "bullet"
local player = require "player"
function love.load() --loads when game is run 
    print("hiya")
    player.load()
end
function love.update(dt) --what the game checks every frame the is running.
player.update(dt)
bullet.update(dt)
end
function love.draw()-- for graphics 
    player.draw()
    bullet.draw()
end
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)--checks the collision of 2 things
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end
