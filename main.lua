--love.graphics.setMode( 960, 640 )
print("#############################################")

-- Detected_ Löve2D
if love then
	love.graphics.setMode( 960, 640 )
	require("wrapper.hug")

-- Detected: CoronaSDK
else
	display.setStatusBar(display.HiddenStatusBar)
	physics = require( "physics" )
end


------------------------------------------------
-- Testing scene
------------------------------------------------

-- Start physics
physics.start()


-- Blue background
local bg = display.newRect(0, 0, display.contentWidth, display.contentHeight)
bg:setFillColor( 50, 90, 120 )


-- Display image: Logo top left
local hugLogo = display.newImage( "images/logo_hug.png", 0, 0 )
hugLogo:setReferencePoint( display.TopLeftReferencePoint )
hugLogo:scale( 0.5, 0.5 )
hugLogo.x = 0
hugLogo.y = 0


-- Sprite animation: Animated logo
local data = require('images.hug_ani')
local sheet = graphics.newImageSheet( 'images/hug_ani.png', data:getSheet() )
local logoAni = display.newSprite( sheet, data:getSequenceData() )
logoAni:setSequence('hug_animation')
logoAni:setReferencePoint( display.TopLeftReferencePoint )
logoAni:translate( logoAni.contentWidth+2, logoAni.contentHeight*0.5+1 )
logoAni:scale( 0.5, 0.5 )
logoAni.isVisible = false
logoAni.timeScale = 2


-- Time delay: show and play animation
timer.performWithDelay( 2000, function()
	logoAni.isVisible = true
	logoAni:play()
end)


-- Setup world group
local world = display.newGroup()


-- Create floor
local floor = display.newRect( world, display.contentWidth*0.25, display.contentHeight*0.75, display.contentWidth*0.5, display.contentHeight*0.15 )
physics.addBody( floor, "static" )
floor:setFillColor( 160, 220, 235 )
floor.id = 'floor'


-- Add physics ball
local function ballLoop()
	-- Create ball from regular image
	local ball = display.newImage( world, "images/ball.png", 0, 0 )
	ball.x = display.contentWidth*0.5
	ball:scale( 0.5, 0.5 )
	ball.id = 'ball'

	-- Physics body
	local polygonSheet = require('images.ball')
	local polygonData = polygonSheet.physicsData( 0.5 )
	physics.addBody( ball, "dynamic" , polygonData:get('ball') )

	-- Add new ball
	timer.performWithDelay( 1000, ballLoop )
end
ballLoop()


-- Frame update
local function update()

	-- Remove balls falling off
	local r = 0
	for i = 1, world.numChildren do
		local child = world[i-r]

		if child.id == 'ball' then
			if child.y > display.contentHeight*0.9 then
				child:removeSelf()
				r=r+1
			end
		end
	end

	-- Move floor
	floor.y = math.sin( system.getTimer()*0.002 ) * 50 + display.contentHeight*0.75
end


-- Runtime enter frame
Runtime:addEventListener("enterFrame", update)


