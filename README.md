# Color Swap Game

A simple 2D game built with LÖVE (Love2D) where you control a character that can switch between red and blue colors to defeat a boss and reach transcendence.

## Game Overview

In this game, you control a character that can switch between red and blue colors. The boss fires bullets of alternating colors. If you catch a bullet that matches your color, you gain ammunition. If you catch a bullet of the opposite color, you lose health. Use your collected bullets to shoot at the boss and defeat it.

After defeating the boss, a door will appear in the tower. Enter the door to complete the game and experience the transcendence ending sequence.

## Controls

- **W, A, S, D**: Move the player character
- **Space**: Switch between red and blue colors
- **Left Mouse Button**: Shoot bullets (if you have ammunition)
- **F1**: Toggle debug mode (shows hitboxes)

## Game Mechanics

- **Color Matching**: Your character can be either red or blue. Match your color with incoming bullets to collect them.
- **Health**: You have 3 hearts. Getting hit by a bullet of the opposite color reduces your health.
- **Ammunition**: You start with 3 bullets. Collect more by catching bullets that match your color.
- **Boss**: The boss has 3 health points. Hit it with your bullets to defeat it.
- **Tower Door**: After defeating the boss, enter the door in the tower to complete the game.

## Files

- **main.lua**: Main game file that handles game state, rendering, and win sequence
- **player.lua**: Player character logic and rendering
- **boss.lua**: Boss enemy logic and rendering
- **bullet.lua**: Bullet mechanics for both player and boss
- **conf.lua**: LÖVE configuration file

## Assets

The game uses various sprite assets located in the `sprites/` directory:
- Player sprites (red and blue)
- Boss sprite
- Tower sprites
- Heart sprites for health display
- Background tiles

## Debug Mode

Press F1 to toggle debug mode, which shows hitboxes for the player, boss, bullets, and tower door. This is useful for understanding collision detection in the game.

## Credits

Created as a simple game project using the LÖVE (Love2D) framework.
