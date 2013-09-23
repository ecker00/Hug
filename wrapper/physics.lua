physics = {}


-- Add physics body
------------------------------------------------
function physics.start()
	physics._world = love.physics.newWorld( 0, 9.81*64, false )
end


-- Add physics body
------------------------------------------------
function physics.addBody( object, bodyType, polygons )
	-- Create physics body
	local body = love.physics.newBody( physics._world, object.x, object.y, bodyType )

	-- Body shape
	local shape
	if polygons then
		-- Polygon based
		shape = love.physics.newPolygonShape( unpack(polygons.shape) )
	else
		-- Rectangle
		shape = love.physics.newRectangleShape( object.contentWidth, object.contentHeight )
		-- Add required offset
		object:setReferencePoint( display.CenterReferencePoint )
		body:setX( object.x + object.contentWidth*0.5 )
		body:setY( object.y + object.contentHeight*0.5 )

		 -- Fix: Using :setReferencePoint() is only a temporary fix, as the object is actually
		 -- topLeft aligned, but the physics and display object have different origins. Which
		 -- center aligning the display object fixes (unitl you specify a different alignment).
	end

	-- Create and store physics object
	local fixture = love.physics.newFixture( body, shape )
	fixture:setRestitution(0.5)
	object._physics = {body=body, shape=shape, fixture=fixture}

	-- Set initial position
	object.x = body:getX()
	object.y = body:getY()
	object.rotation = 0

	-- Method to check if posisions are in sync, used in hug.drawGroup()
	object._lastX = object.x
	object._lastY = object.y
	object._lastR = 0
end