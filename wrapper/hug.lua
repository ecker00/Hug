

-- Hug table
hug = {}
hug.dt = 0
hug.enterFrame = {}

local function initHug()
	hug.graphics = display.newGroup() -- Root display group
end

-- Import wrapper functions
require("wrapper.classes")
require("wrapper.display")
require("wrapper.physics")
require("wrapper.system")
require("wrapper.timer")

-- Runtime table
Runtime = hug.EventListener()


------------------------------------------------
-- Love functions
------------------------------------------------

-- Love load
function love.load()
	
end

-- Love frame update
function love.update( dt )
	hug.dt = dt -- For animation update in love.draw()

	-- Enter frame listeners
	for _, callback in pairs( hug.enterFrame ) do
		callback()
	end

	-- Update timers
	timer.update( dt )

	-- Update physics
	physics._world:update( dt )
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


-- Hug alignment
------------------------------------------------
function hug.align( atype, object )
	-- CoronaSDK seems to be very irregular in how it handles alignment,
	-- making it complicated to accomodate all possible combinations.
	-- Scale affects alignment differently on different type of objects.
	-- Results also changes depending on if you've set XY positions after creation.

	local alignment = object.align

	-- Regular image
	if atype == "img" then
		local width = object.contentWidth
		local height = object.contentHeight

		if alignment == 'topLeft' then -- Appers to work, scaling ok
			love.graphics.translate( 0, 0 )
		elseif alignment == 'center' then -- Appers to work, scaling ok
			love.graphics.translate( object.width*-0.5, object.height*-0.5 )
		elseif alignment == 'bottomCenter' then -- Appers to work, scaling ok
			love.graphics.translate( object.width*-0.5, object.height*-1 )
		else
			print("Hug: " .. alignment .. " alignment not yet implemented.")
		end

	-- Sprite animation
	elseif atype == "ani" then
		local width = object.width/object.xScale
		local height = object.height/object.yScale

		if alignment == 'topLeft' then -- Appers to work, scaling ok
			love.graphics.translate( width*-0.5, height*-0.5 )
		elseif alignment == 'center' then -- Appers to work, scaling ok
			love.graphics.translate( object.width*-0.5, object.height*-0.5 )
		elseif alignment == 'bottomCenter' then -- FIX: X alignment works, y alignment is wrong
			love.graphics.translate( object.width*-0.5, object.height*-1 ) -- object.height*-0.5+(object.height*-(object.yScale-1))
		else
			print("Hug: " .. alignment .. " alignment not yet implemented.")
		end
	end
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
				-- Update animation frame
				if child.sequence then
					child:_updateAnimation( hug.dt )
				end

				-- Sync physics positions
				if child._physics then
					-- Check if object positions have been modified by user
					if child.x ~= child._lastX or child.y ~= child._lastY or child.rotation ~= child._lastR then
						-- Update physics from object
						child._physics.body:setX( child.x )
						child._physics.body:setY( child.y )
						child._physics.body:setAngle( math.rad(child.rotation) )
					else
						-- Update object from physics
						child.x = child._physics.body:getX()
						child.y = child._physics.body:getY()
						child.rotation = math.deg( child._physics.body:getAngle() )
					end
					-- Store transformation reference
					child._lastX = child.x
					child._lastY = child.y
					child._lastR = child.rotation
				end

				-- Position child
				love.graphics.push()
				love.graphics.translate( child.x, child.y )
				love.graphics.rotate( math.rad(child.rotation) )
				love.graphics.scale( child.xScale, child.yScale )

				-- Set color
				local c = child._color
				love.graphics.setColor( c.r, c.g, c.b, c.a )

				-- Draw rectangle
				if child._rectangle then
					hug.align( "img", child )
					love.graphics.rectangle("fill", 0, 0, child._rectangle.w, child._rectangle.h )

				-- Draw area of image (using sprite atlas)
				elseif child._rect then
					-- Alignment offset
					hug.align( "ani", child )
					love.graphics.drawq( child._image, child._rect, 0, 0 )

				-- Draw entire image
				else
					-- Alignment offset
					hug.align( "img", child )
					love.graphics.draw( child._image, 0, 0 )
				end

				-- Exit alignment offset
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
