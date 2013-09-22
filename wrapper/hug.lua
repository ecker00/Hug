--
--
-- # Hug v0.1
-- Wrapper for CoronaSDK to Love2D
-- Built for Love 0.8.0
--
--
-- # Coding stucture
-- Most unofficial functions should go in the hug[] table.
-- When unofficial properties are needed names start with underscore obj._property.
-- A comment with "FIX: Explenation"" is a point in the code which needs correction.
--
--
-- # Limitations
-- Moving objects between groups will cause duplicates
-- Changing or setting a groups or image parent after creation will cause duplicate renders.
-- object:setReferencePoint(), is always centered
--
--


-- Hug table
hug = {}
local function initHug()
	hug.graphics = display.newGroup() -- Root display group
end


-- Import wrapper functions
require("wrapper.display")
require("wrapper.physics")
require("wrapper.system")
require("wrapper.timer")

------------------------------------------------
-- Love functions
------------------------------------------------

-- Love load
function love.load()
	-- Setup physics world
	physicsWorld = love.physics.newWorld( 0, 9.81*64, false )
end

-- Love frame update
function love.update( dt )
	physicsWorld:update( dt ) -- Update physics
	timer.update( dt ) -- Update timers
	hug.update( dt ) -- Update display objects
end

-- Love draw frame
function love.draw()
	-- Automaticly draw display objects
	hug.drawGroup( hug.graphics )
end


------------------------------------------------
-- Hug functions
------------------------------------------------

-- Update sprite animations
------------------------------------------------
function hug.update( dt )
	for _, object in ipairs( hug.graphics ) do
		if object._updateAnimation then
			object:_updateAnimation( dt )
		end
	end
end


-- Display object class
------------------------------------------------
function hug.displayObject( parent )
	local object = {}

	-- Private (unofficial)
	object.ani = false

	-- Set default data
	object.x = 0
	object.y = 0
	object.xScale = 1
	object.yScale = 1
	object.rotation = 0
	object.isVisible = true
	object.physics = false
	object.align = "center"
	object.width = 0
	object.height = 0
	object.contentWidth = 0
	object.contentHeight = 0

	-- Not implemented:
	object.blendMode = "normal"
	object.alpha = 1

	-- Scale object
	function object:translate( xPos, yPos )
		object.x = object.x + xPos
		object.y = object.y + yPos
	end

	-- Scale object
	function object:scale( xScale, yScale )
		object.xScale = object.xScale * xScale
		object.yScale = object.yScale * yScale
	end

	-- Rotate object
	function object:rotate( value )
		object.rotation = object.rotation+value
	end

	-- Remove object
	function object:removeSelf()
		-- Clear from display group
		if object.parent then
			for index, child in ipairs( object.parent ) do
				if child == object then
					table.remove( object.parent, index )
					object.parent.numChildren = #object.parent
					break
		end end end
		-- Clear from animation table
		if object.ani then
			for index, child in ipairs( hug.graphics ) do
				if child == object then
					table.remove( hug.graphics, index )
					break
		end end end
		-- Clear physics
		if object.physics then object.physics = nil end
		object = nil
	end

	-- Align object
	function object:setReferencePoint( alignment )
		 object.align = alignment
	end

	-- Set parrent
	if parent then
		object.parent = parent
		parent[ #parent+1 ] = object
		parent.numChildren = #parent
	
	-- Store object at root
	else
		--object.parent = false
		--display[ #display+1 ] = object
		if hug.graphics then
			object.parent = hug.graphics
			hug.graphics[ #hug.graphics+1 ] = object
		end
	end

	-- Set fill color
	function object:setFillColor( r, g, b, a )
		print('Function not yet implemented. :setFillColor()')
	end

	-- Move object to the front of the layer
	function object:toFront()
		print('Function not yet implemented. :toFront()')
	end

	-- Move object to the back of the layer
	function object:toBack()
		print('Function not yet implemented. :toBack()')
	end

	return object
end


-- Automatically draw display objects
------------------------------------------------
function hug.drawGroup( group )
	for _, child in ipairs( group ) do

		-- Apply group offset
		love.graphics.push()
		love.graphics.translate( group.x, group.y )
		love.graphics.rotate( math.rad(group.rotation) )
		love.graphics.scale( group.xScale, group.yScale )

		-- Only draw visible objects
		if child.isVisible then
			-- Draw child
			if child.numChildren == nil then
				-- Update positions from physics
				if child.physics then
					child.x = child.physics.body:getX()
					child.y = child.physics.body:getY()
					child.rotation = math.deg( child.physics.body:getAngle() )
				end
				-- Position child
				love.graphics.push()
				love.graphics.translate( child.x, child.y )
				love.graphics.rotate( math.rad(child.rotation) )
				love.graphics.scale( child.xScale, child.yScale )

				
				-- Draw from rect (using sprite atlas)
				if child.rect then
					-- Alignment offset
					local _, _, w, h = child.rect:getViewport()
					if child.align == 'topLeft' then

					elseif child.align == 'center' then
						love.graphics.translate( w*-.5, h*-.5 )
					elseif child.align == 'bottomCenter' then
						love.graphics.translate( w*-.5, h*-1 )
					end
					love.graphics.drawq( child._image, child.rect, 0, 0 )

				-- Draw entire image
				else
					-- Alignment offset
					if child.align == 'topLeft' then
						-- No offset
					elseif child.align == 'center' then
						love.graphics.translate( child._image:getWidth()*-.5, child._image:getHeight()*-.5 )
					elseif child.align == 'bottomCenter' then
						love.graphics.translate( child._image:getWidth()*-.5, child._image:getHeight()*-1 )
					end
					love.graphics.draw( child._image, 0, 0 )
				end
				love.graphics.pop()
			
			-- Draw group content
			elseif child.numChildren > 0 then
				hug.drawGroup( child )
			end
		end

		-- Exit group offset
		love.graphics.pop()
	end
end

initHug()







