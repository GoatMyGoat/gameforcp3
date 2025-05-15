# Radial Bullet Counter Implementation Plan

## Overview

The current text-based bullet counter will be replaced with a radial display that:
- Clearly shows a maximum of 3 bullets
- Starts with 0 bullets (changed from the current 3)
- Is color-coded based on the player's current color state
- Has visual effects when bullets are gained or lost

## Detailed Implementation Plan

### 1. Modify Player Starting Bullets
- Change `STARTING_BULLETS` constant in player.lua from 3 to 0
- This will require the player to catch bullets from the boss before being able to shoot

### 2. Design the Radial Display
- Create a circular display with 3 segments (one for each potential bullet)
- Each segment will be:
  - Filled/lit when a bullet is available
  - Empty/dark when no bullet is available
  - Colored to match the player's current color state (red or blue)
- Position the display in the top-left corner where the text counter currently is

### 3. Visual Effects
- Add a pulse/glow effect when a new bullet is gained
- Add a fade-out effect when a bullet is used
- Add a subtle continuous animation to make the display visually interesting

### 4. Code Implementation

#### New Constants and Variables in player.lua
```lua
-- Radial bullet display constants
local BULLET_DISPLAY_RADIUS = 30
local BULLET_SEGMENT_WIDTH = 8
local BULLET_SEGMENT_GAP = 5
local BULLET_DISPLAY_X = 50
local BULLET_DISPLAY_Y = 50
local BULLET_ANIMATION_DURATION = 0.3

-- Animation state for bullet display
local bulletAnimations = {
  gained = {active = false, timer = 0, index = 0},
  lost = {active = false, timer = 0, index = 0}
}
```

#### New Drawing Function
```lua
function player.drawBulletDisplay()
  local x, y = BULLET_DISPLAY_X, BULLET_DISPLAY_Y
  local radius = BULLET_DISPLAY_RADIUS
  
  -- Draw background circle (darker)
  love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
  love.graphics.circle("fill", x, y, radius)
  
  -- Draw bullet segments
  for i = 1, MAX_BULLETS do
    local angle = (i - 1) * (2 * math.pi / MAX_BULLETS)
    local segmentX = x + math.cos(angle) * (radius - BULLET_SEGMENT_WIDTH/2)
    local segmentY = y + math.sin(angle) * (radius - BULLET_SEGMENT_WIDTH/2)
    
    -- Determine if this segment should be lit
    local isLit = i <= player.bulletCount
    
    -- Set color based on player's current color and whether segment is lit
    if isLit then
      if player.colorSwap then -- Red
        love.graphics.setColor(1, 0.3, 0.3, 1)
      else -- Blue
        love.graphics.setColor(0.3, 0.3, 1, 1)
      end
      
      -- Add animation effects for newly gained bullets
      if bulletAnimations.gained.active and bulletAnimations.gained.index == i then
        local progress = bulletAnimations.gained.timer / BULLET_ANIMATION_DURATION
        local pulseScale = 1 + 0.3 * math.sin(progress * math.pi)
        love.graphics.circle("fill", segmentX, segmentY, BULLET_SEGMENT_WIDTH * pulseScale)
      else
        love.graphics.circle("fill", segmentX, segmentY, BULLET_SEGMENT_WIDTH)
      end
    else
      -- Empty bullet slot
      love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
      love.graphics.circle("line", segmentX, segmentY, BULLET_SEGMENT_WIDTH)
    end
  end
  
  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end
```

#### Update Animation State in player.update()
```lua
-- Update bullet animations
if bulletAnimations.gained.active then
  bulletAnimations.gained.timer = bulletAnimations.gained.timer + dt
  if bulletAnimations.gained.timer >= BULLET_ANIMATION_DURATION then
    bulletAnimations.gained.active = false
  end
end

if bulletAnimations.lost.active then
  bulletAnimations.lost.timer = bulletAnimations.lost.timer + dt
  if bulletAnimations.lost.timer >= BULLET_ANIMATION_DURATION then
    bulletAnimations.lost.active = false
  end
end
```

#### Modify Bullet Firing and Gaining Logic
```lua
-- When firing a bullet
if love.mouse.isDown(1) and player.bulletCooldown <= 0 and player.bulletCount > 0 then
  -- Existing firing code...
  
  -- Add animation for losing a bullet
  bulletAnimations.lost.active = true
  bulletAnimations.lost.timer = 0
  bulletAnimations.lost.index = player.bulletCount + 1
end

-- When gaining a bullet (in bullet.lua, collision with boss bullet)
if playerColor == b.color then
  player.bulletCount = player.bulletCount + 1
  
  -- Add animation for gaining a bullet
  player.bulletAnimations.gained.active = true
  player.bulletAnimations.gained.timer = 0
  player.bulletAnimations.gained.index = player.bulletCount
end
```

#### Replace Text Display in player.draw()
```lua
function player.draw()
  -- Draw player sprite
  love.graphics.draw(player.sprite, player.x + player.sprite_offset_x, player.y + player.sprite_offset_y)
  
  -- Draw health bar (hearts) below the player
  player.drawHealthBar()
  
  -- Draw radial bullet display instead of text
  player.drawBulletDisplay()
  
  -- Remove the old text display:
  -- love.graphics.setFont(player.uiFont)
  -- love.graphics.print("Bullets: " .. player.bulletCount, 10, 10)
end
```

## Implementation Steps

1. Modify the `STARTING_BULLETS` constant in player.lua
2. Add the new constants and variables for the radial display
3. Create the new `drawBulletDisplay()` function
4. Update the animation state in the update function
5. Modify the bullet firing and gaining logic to include animations
6. Replace the text display with the radial display in player.draw()
7. Test and refine the visual appearance and animations

## Potential Enhancements

1. Add a subtle rotation animation to the entire display
2. Include a small icon in the center of the radial display
3. Add sound effects that sync with the visual animations
4. Implement a "low ammo" warning effect when down to the last bullet