local class = require 'code/middleclass'

Player = class('Player')

local WALKING_SPEED = 50
local JUMP_VELOCITY = 50

function Player:initialize(x, y, keyLEFT, keyRIGHT, image, flip , state)

    --initial position
    self.x = x
    self.y = y

    self.Time = love.timer.getTime()

    self.height = 100
    self.width = 100

    -- X and Y vectors
    self.vectorX = 0
    self.vectorY = 0

    self.collider = world:newRectangleCollider(self.x , self.y, self.width - 30, self.height)
    self.collider:setCollisionClass('Player')
    self.collider:setMass(1)

    -- offset from top left to center to support sprite flipping
    self.xOffset = self.width/2
    self.yOffset = self.height/2

    self.alive = true

    image = 'assets/images/' .. image

    self.texture = love.graphics.newImage(image)

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- determines sprite flipping
    self.direction = flip

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, self.width, self.height, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad( 0*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['countdown'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad( 0*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 0*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 1*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 2*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 3*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 4*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 4*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 4*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 5*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 5*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 5*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 6*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 6*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 6*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 7*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 7*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 2*self.width, 7*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 0*self.width, 8*self.height, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad( 1*self.width, 8*self.height, self.width, self.height, self.texture:getDimensions())
            },
            interval = 0.10
        })
 
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations[state]
    self.state = state
    
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
            
            self.animation = self.animations['idle']
            
            if love.keyboard.wasPressed(keyLEFT) then

                self.direction = 'left'
                self.vectorX = self.vectorX - 1
                self.state = 'walking'

            elseif love.keyboard.wasPressed(keyRIGHT) then

                self.direction = 'right'
                self.vectorX = self.vectorX + 1
                self.state = 'walking'
    
                
            elseif self.dx == 0 then

                self.vectorX = 0
                self.animation = self.animations['idle']

            end

            if self.vectorX ~= 0 then
                self.state = 'walking'
            end

        end,

        ['walking'] = function(dt)
        
            self.animation = self.animations['walking']

            if love.keyboard.wasPressed(keyLEFT) then

                self.vectorX = self.vectorX - 1
                self.direction = 'left'

            elseif love.keyboard.wasPressed(keyRIGHT) then

                self.vectorX = self.vectorX + 1
                self.direction = 'right'
                
            elseif self.vectorX == 0 then
                self.state = 'idle'
                self.animation = self.animations['idle']

            end

        end,

        ['countdown'] = function(dt)
            
            self.animation = self.animations['countdown']

            if love.timer.getTime() > countdownTime + 2.65 then 
                gameState = 'play'
            end
                      
        end
       
    }
end

function Player:update(dt)
    
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()

    -- works to reduce speed after set interval, like friction
    if love.timer.getTime() > self.Time + 1  then
        
        self.Time = love.timer.getTime()
        
        if self.vectorX > 0 then
            self.vectorX = self.vectorX - 1

        elseif self.vectorX < 0 then
            self.vectorX = self.vectorX + 1

        end

    end
    
    self.collider:applyLinearImpulse(self.vectorX/2 * WALKING_SPEED * dt, self.vectorY)

end

function Player:draw()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    self.x = self.collider:getX()
    self.y = self.collider:getY()

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, scaleX, 1, self.xOffset, self.yOffset)

end