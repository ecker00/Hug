physics = {}

-- Add physics body
------------------------------------------------
function physics.addBody( object, bodyType, polygons )
	local body    = love.physics.newBody( physicsWorld, object.x, object.y, bodyType )
	local shape   = love.physics.newPolygonShape( unpack(polygons.shape) )
	local fixture = love.physics.newFixture( body, shape )
	fixture:setRestitution(0.5)
	print( fixture:getDensity() )
	object.physics = {body=body, shape=shape, fixture=fixture}
end