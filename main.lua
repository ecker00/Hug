--love.graphics.setMode( 960, 640 )
print("#############################################")

-- Detected_ Löve2D
if love then
	require("wrapper.hug")
	love.graphics.setMode( 960, 640 )

-- Detected: CoronaSDK
else
	display.setStatusBar(display.HiddenStatusBar)
	physics = require( "physics" )
	physics.start()
end

-- require("wrapper.corona")
-- require("wrapper.physics")
-- require("wrapper.system")
-- require("wrapper.timer")

-- Create testing scene
local world = display.newGroup()
world:translate( 480, 320 )


local loveLogo = display.newImage( "logo_love.png", 0, 0 )
local hugLogo = display.newImage( world, "logo_hug.png", 0, 0 )
hugLogo.x = 0

print(world.parent, loveLogo.parent, hugLogo.parent.parent, hugLogo.parent)

-- Move logo
timer.performWithDelay( 1000, function()
	hugLogo.x = hugLogo.contentWidth
end)



if false then
	physicsWorld = love.physics.newWorld( 0, 9.81*64, false )

	screen = {}
	screen.xl = 0
	screen.xc = love.graphics.getWidth() * 0.5
	screen.xr = love.graphics.getWidth()
	screen.xw = love.graphics.getWidth()
	screen.yt = 0
	screen.yc = love.graphics.getHeight() * 0.5
	screen.yb = love.graphics.getHeight()
	screen.yh = love.graphics.getHeight()

	local bg = display.newGroup()
	local world = display.newGroup()
	world:translate( screen.xc, screen.yc )

	local lightPole2
	local balls = {}

	function love.load()
		-- Regular image
		local splash = display.newImage( bg, "assets/splash/splash.png", 0, 0 )

		-- Image via sprite atlas
		local rects1 = require('assets.general.lamp_post')
		local sheet1 = graphics.newImageSheet( 'assets/general/lamp_post@4.png', rects1:getSheet() )
		local lightPole1 = display.newImageRect( world, sheet1, rects1:getFrameIndex('lamp_post_1'))
		lightPole1:setReferencePoint( display.CenterReferencePoint )
		lightPole1:scale( 4, 4 )
		lightPole1.x = -250
		lightPole1.y = 0

		-- Image via sprite atlas
		local rects2 = require('assets.ground.ground_6')
		local sheet2 = graphics.newImageSheet( 'assets/ground/ground_6@4.png', rects2:getSheet() )
		local floor = display.newImageRect( world, sheet2, rects2:getFrameIndex('grass'))
		floor:setReferencePoint( display.CenterReferencePoint )
		floor.x = 0
		floor.y = 425
		floor:scale( 4, 4 )

		-- Physics body
		polygonSheet  = require('assets.ground.ground_6-polygons')
		polygonData   = polygonSheet.physicsData( 1.00 )
		physics.addBody( floor, "static" , polygonData:get('ground_6') )

		-- Working animation example
		local rects3 = require('assets.light.light')
		local sheet3 = graphics.newImageSheet( 'assets/light/light@4.png', rects3:getSheet() )
		local lightGlow = display.newSprite( world, sheet3 , rects3:getSequenceData() )
		lightGlow:setSequence( 'light' )
		lightGlow:setFrame( math.random(1, lightGlow.numFrames) )
		lightGlow:setReferencePoint( display.CenterReferencePoint )
		lightGlow:translate( -250, -70 )
		lightGlow:scale( 4, 4 )
		lightGlow.timeScale = 10
		lightGlow:play()

		-- Creating and removing things on timer
		timer.performWithDelay( 1000, function()
			lightPole2 = display.newImageRect( world, sheet1, rects1:getFrameIndex('lamp_post_3'))
			lightPole2:setReferencePoint( display.CenterReferencePoint )
			lightPole2:scale( 4, 4 )
			lightPole2.x = 250
			lightPole2.y = 0
		end)

		-- Big glow
		timer.performWithDelay( 3000, function()
			lightGlow:scale( 2, 2 )
		end)

		-- Add ball
		addBall()
		return
	end

	-- Add physics ball
	function addBall()
		-- Create ball from regular image
		local ball = display.newImage( world, "assets/ball2.png", math.random()*100, -400 )
		ball:setReferencePoint( display.CenterReferencePoint )
		ball:scale( 0.5, 0.5 )

		-- Physics body
		polygonSheet  = require('assets.ball-polygons')
		polygonData   = polygonSheet.physicsData( 0.5 )
		physics.addBody( ball, "dynamic" , polygonData:get('ball') )

		-- Add new ball
		table.insert( balls, ball )
		timer.performWithDelay( 1000, addBall )
	end

	-- This function should be moved into the wrapper code
	function love.update( dt )
		if lightPole2 then
			lightPole2.x = 250 + (math.sin( system.getTimer()*0.001 )*50)
		end

		-- Wrapper Updates
		physicsWorld:update( dt )
		graphics.update( dt )
		timer.update( dt )
	end

	-- This function should be moved into the wrapper code
	function love.draw()
		-- Wrapper Automatic Draw
		drawGroup( display )
	end
end


