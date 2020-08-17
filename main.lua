
require 'code/Player'
require 'code/Animation'

class = require 'code/middleclass'
game = require 'code/Game'
windfield = require 'code/windfield'

WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1280

function love.load()

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    -- create new physics world
    world = windfield.newWorld(0, 0, true)
    world:setGravity(0, 250)

    -- create collision classes
    world:addCollisionClass('Player')
    world:addCollisionClass('Map')
    world:addCollisionClass('Outside')

    -- music
    music = {}
    music.main = love.audio.newSource('assets/sounds/Driftveil.mp3', 'stream')
    music.main:setVolume(0.20)
    music.main:setLooping(true)

    music.gong = love.audio.newSource('assets/sounds/Gong.mp3', 'stream')
    music.applause = love.audio.newSource('assets/sounds/Applause.wav', 'stream')

    -- hide mouse
    love.mouse.setVisible(false)

    -- seed random function
    math.randomseed(os.time())

    -- fonts
    large = love.graphics.newFont('assets/fonts/asian_hiro/AsianHiro.ttf', 80)
    small = love.graphics.newFont('assets/fonts/asian_hiro/AsianHiro.ttf', 20)

    -- game
    game = Game:new('Menu')

    -- initialze keys pressed table
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end


function love.update(dt)

    game:update(dt)
    
    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    -- update the physics world
    world:update(dt)

end

function love.draw()

    love.graphics.clear (40/255, 45/255, 52/255, 255/255)

    game:draw()
    --world:draw()

end