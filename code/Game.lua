local class = require 'code/middleclass'
local stateful = require 'code/stateful'

local backgroundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local BACKGROUND_LOOPING_POINT = 1280

background = love.graphics.newImage('assets/images/BleachersLong.png')

Game = class('Game')
Game:include(stateful)

function Game:initialize(state)
    self:gotoState(state)
end

-- initialize the states our game contains
Menu = Game:addState('Menu')
Countdown = Game:addState('Countdown')
Play = Game:addState('Play')
GameOver = Game:addState('GameOver')


-- Menu

function Menu:enteredState()
    music.main:play()
end

function Menu:update(dt)

    -- start the game when the player presses space or enter
    if love.keyboard.isDown('space', 'return') then
        self:gotoState('Countdown')
        return
    end

    -- update background position so that it loops forever
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED *dt) % BACKGROUND_LOOPING_POINT
end

function Menu:draw()

    -- draw background
    love.graphics.draw(background, -backgroundScroll, 0)

    -- draw title
    love.graphics.setFont(large)
    love.graphics.setColor(20/255, 20/255, 25/255)
    love.graphics.printf('SUMO', 0, WINDOW_HEIGHT/2 - 145, WINDOW_WIDTH + 5, 'center')
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.printf('SUMO', 0, WINDOW_HEIGHT/2 - 140, WINDOW_WIDTH, 'center')

    -- press enter to play
    if math.cos(2*math.pi*love.timer.getTime()) > 0 then
        love.graphics.setFont(small)
        love.graphics.setColor(20/255, 20/255, 25/255)
        love.graphics.printf('press ENTER to play', 0, WINDOW_HEIGHT/2 - 60, WINDOW_WIDTH , 'center')
        love.graphics.setColor(255/255, 255/255, 255/255)
        --love.graphics.printf('press ENTER to play', 0, WINDOW_HEIGHT/2 - 20, WINDOW_WIDTH, 'center')
    end
end

function Menu:exitedState()
    music.main:setVolume(0.10)
    --music.main:stop()
end

-- Countdown

function Countdown:enteredState()
    --music.menu:play()

    countdownTime = love.timer.getTime()
    playGround = love.graphics.newImage('assets/images/Bleachers.png')

    -- intitialize platform
    platform = world:newRectangleCollider(0, WINDOW_HEIGHT - 15, WINDOW_WIDTH , 10)
    platform:setType('static')
    platform:setCollisionClass('Map')
    
    gameState = 'Countdown'
    
    -- create players for countdown
    self.player1 = Player:new(300, 650, 'a', 'd', 'BlueStart.png', 'right', 'countdown' )
    self.player2 = Player:new(WINDOW_WIDTH - 300, 650, 'left', 'right', 'RedStart.png', 'left' , 'countdown' )

end

function Countdown:update(dt)
    
    self.player1:update(dt)
    self.player2:update(dt)
    
    if love.keyboard.isDown('escape') then
        self:gotoState('Menu')
    end

    if love.timer.getTime() - countdownTime > 2.65 then 
        self:gotoState('Play')
    end
end

function Countdown:draw()

    love.graphics.draw(playGround, 0, 0)

    self.player1:draw()
    self.player2:draw()

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(large)
    love.graphics.printf(3 - math.floor(love.timer.getTime() - countdownTime), 0, WINDOW_HEIGHT/2 - 145, WINDOW_WIDTH + 5, 'center')
    
    love.graphics.setColor(1, 1, 1, 1)
    
end

function Countdown:exitedState()
    self.player1.collider:destroy()
    self.player2.collider:destroy()

    music.gong:play()
end


-- Play

function Play:enteredState()
    music.main:play()

    playGround = love.graphics.newImage('assets/images/Bleachers.png')
    gameState = 'play'

    -- initialize boundaries
    right = world:newLineCollider(WINDOW_WIDTH - 35, 0, WINDOW_WIDTH - 35, WINDOW_HEIGHT)
    right:setCollisionClass('Outside')
    right:setType('static')

    left = world:newLineCollider(35, 0, 35, WINDOW_HEIGHT)
    left:setCollisionClass('Outside')
    left:setType('static')

    platform = world:newRectangleCollider(0, WINDOW_HEIGHT - 15, WINDOW_WIDTH , 10)
    platform:setType('static')
    platform:setCollisionClass('Map')

    self.player1 = Player:new(300, 650, 'a', 'd', 'BlueWalking.png', 'right', 'idle' )
    self.player2 = Player:new(WINDOW_WIDTH - 300, 650, 'left', 'right', 'RedWalking.png', 'left', 'idle' )

    playTime = love.timer.getTime()
    love.timer.sleep(0.01)
    
    self.player2.animation = self.player2.animations['idle']
    self.player1.animation = self.player1.animations['idle']

end

function Play:update(dt)

    self.player1:update(dt)
    self.player2:update(dt)
    
    if love.keyboard.isDown('escape') then
        self:gotoState('Menu')
    end

    if self.player1.alive == false or self.player2.alive == false then

        --music.main:stop()

        music.applause:play()

        --sleep for 2 seconds
        love.timer.sleep(2)

        self:gotoState('GameOver')
    end

    if self.player1.collider:enter('Outside') then
        self.player1.alive = false
        winningPlayer = 2

    elseif self.player2.collider:enter('Outside') then
        self.player2.alive = false
        winningPlayer = 1

    end

end

function Play:draw()

    love.graphics.draw(playGround, 0, 0)

    self.player1:draw()
    self.player2:draw()
 
end

function Play:exitedState()
   
end


-- GameOver

function GameOver:enteredState()

    self.player1.collider:destroy()
    self.player2.collider:destroy()

    self.gameOverTime = love.timer.getTime()

end

function GameOver:update(dt)

    if love.keyboard.isDown('return') then
        self:gotoState('Menu')
        love.timer.sleep(0.15)
    end

    -- update background position so that it loops forever
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED *dt) % BACKGROUND_LOOPING_POINT
   
end

function GameOver:draw()

    -- draw background
    love.graphics.draw(background, -backgroundScroll, 0)

    love.graphics.setFont(large)
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.printf('Player ' .. winningPlayer .. ' wins!!', 0, WINDOW_HEIGHT/2 - 120, WINDOW_WIDTH + 3, 'center')
    love.graphics.setColor(20/255, 20/255, 25/255)
    love.graphics.printf('Player ' .. winningPlayer .. ' wins!!', 0, WINDOW_HEIGHT/2 - 117, WINDOW_WIDTH, 'center')
    love.graphics.setColor(255/255, 255/255, 255/255)

    if math.cos(2*math.pi*love.timer.getTime()) > 0 then
        love.graphics.setFont(small)
        love.graphics.setColor(20/255, 20/255, 25/255)
        love.graphics.printf('press ENTER to replay', 0, WINDOW_HEIGHT/2 - 50, WINDOW_WIDTH , 'center')
        love.graphics.setColor(255/255, 255/255, 255/255)
        --love.graphics.printf('press ENTER to play', 0, WINDOW_HEIGHT/2 - 20, WINDOW_WIDTH, 'center')
    end
    
end

function GameOver:exitedState()
end