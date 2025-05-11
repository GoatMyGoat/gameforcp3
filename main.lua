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
 local tile =love.graphics.newImage("sprites/tile1.png")
    for tx=0,1280 ,65 do
        for ty=0,720,65 do
        love.graphics.draw(tile,tx,ty)
        end
    end
    love.graphics.draw(love.graphics.newImage("sprites/tower.png"),500,200)
    player.draw()
    bullet.draw()
   
end
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)--checks the collision of 2 things
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end
