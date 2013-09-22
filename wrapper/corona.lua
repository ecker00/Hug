display = { gx=0, gy=0, x=0, y=0, rotation=0, xScale=1, yScale=1, parent=nil }
graphics = {} -- Stores all animation updates

-- Limitations:
-- Moving objects between groups will cause duplicates
-- Changing or setting a groups or image parent after creation will cause duplicate renders.
-- object:setReferencePoint(), is always centered

display.BottomCenterReferencePoint = 'bottomCenter'
display.CenterReferencePoint = 'center'

-- Display object class
------------------------------------------------
function display.createObject( parent )
	local object = {}

	-- Private (unofficial)
	object.draw = false
	object.ani = false

	-- Set default data
	object.x = 0
	object.y = 0
	object.xScale = 1
	object.yScale = 1
	object.rotation = 0
	object.numChildren = 0
	object.physics = false

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
			for index, child in ipairs( graphics ) do
				if child == object then
					table.remove( graphics, index )
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
	
	-- Store object for root draw
	else
		object.parent = false
		display[ #display+1 ] = object
	end

	-- Set fill color
	function object:setFillColor( r, g, b, a )

	end

	-- Move object to the back of the layer
	function object:toBack()

	end

	return object
end


-- New group
------------------------------------------------
function display.newGroup( parent )
	local object = display.createObject( parent )

	-- Adding child
	function object:insert( other )
		-- Set new parent
		other.parent = object
		object[ #object+1 ] = other
	end

	-- Removing child
	function object:remove( index )
		table.remove( object, index )
	end

	return object
end


-- New image
------------------------------------------------
function display.newImage( parent, path, x, y )
	local object = display.createObject( parent )

	object.img = love.graphics.newImage( path )
	object.rect = false
	object.draw = true
	object.x = x
	object.y = y

	return object
end


-- New atlas               (why is it graphics?)
------------------------------------------------
function graphics.newImageSheet( path, rects )
	-- Moved object creation out of here, because other wise it was not possible to
	-- create multiple instances and parenting should be done with newImageRects()
	return { path=path, rects=rects }
end


-- Update animations                (unofficial)
------------------------------------------------
function graphics.update( dt )
	for _, seq in ipairs( graphics ) do
		seq:update( dt )
	end
end


-- New image from atlas (should be without Rect)
------------------------------------------------
function display.newImageRect( parent, sheet, rectID )
	local object = display.createObject( parent )
	object.img = love.graphics.newImage( sheet.path )
	object.draw = true

	-- Define rect
	local data = sheet.rects
	local x = data.frames[ rectID ].x
	local y = data.frames[ rectID ].y
	local w = data.frames[ rectID ].width
	local h = data.frames[ rectID ].height
	local width = data.sheetContentWidth
	local height = data.sheetContentHeight
	object.rect = love.graphics.newQuad( x, y, w, h, width, height )

	return object
end


-- New image from atlas (should be without Rect)
------------------------------------------------
function display.newSprite( parent, sheet, sequences )
	local object = display.createObject( parent )
	object.img = love.graphics.newImage( sheet.path )
	object.draw = false

	-- Private (unofficial)
	object.sequences = sequences
	object.rects = sheet.rects
	object.rect = false
	object.ani = true
	object.timer = 0

	-- Set animation data
	object.time = 0
	object.start = 1
	object.frame = 1
	object.isPlaying = false
	object.numFrames = 1
	object.loopCount = 0
	object.sequence = 'sequence name unspecified'
	object.timeScale = 1.0

	-- Store for automatic animation update
	graphics[ #graphics+1 ] = object

	-- Play animation
	function object:play()
		object.isPlaying = true
	end

	-- Pause animation
	function object:pause()
		object.isPlaying = false
	end

	-- Set frame rect
	function object:setFrame( frameIndex )
		object.frame = frameIndex

		local data = object.rects
		local x = data.frames[ frameIndex ].x
		local y = data.frames[ frameIndex ].y
		local w = data.frames[ frameIndex ].width
		local h = data.frames[ frameIndex ].height
		local width = data.sheetContentWidth
		local height = data.sheetContentHeight

		-- Define rect
		object.rect = love.graphics.newQuad( x, y, w, h, width, height )
	end

	-- Set sequence data
	function object:setSequence( name ) -- "light"
		for _, seq in pairs( object.sequences ) do
			if seq.name == name then
				-- Set sequence data
				object.draw = true
				object.time = seq.time
				object.start = seq.start
				object.numFrames = seq.count
				object.loopCount = seq.loopCount
				object.sequence = name
				object:setFrame( seq.start )
				break
			end
		end
	end

	-- Animation update (unofficial)
	function object:update( dt )
		if not object.isPlaying then return end -- return when paused

		-- Count down
		if object.timer > object.time then
			object.timer = 0

			-- Set next frame
			local frame = object.frame+1
			if frame > object.numFrames then frame = object.start end
			object:setFrame( frame )

		-- Increment timer
		else object.timer = object.timer + ((dt*1000) * object.timeScale) end
	end

	return object
end


-- Automatically draw display objects
------------------------------------------------
function drawGroup( group )
	for _, child in ipairs( group ) do

		-- Apply group offset
		love.graphics.push()
		love.graphics.translate( group.x, group.y )
		love.graphics.rotate( math.rad(group.rotation) )
		love.graphics.scale( group.xScale, group.yScale )

		-- Draw graphic
		if child.draw then
			-- Update physics
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

			
			-- Draw from rect, center pivot
			if child.rect then
					local _, _, w, h = child.rect:getViewport()
				if child.align == 'center' then
					love.graphics.translate( w*-.5, h*-.5 )
				elseif child.align == 'bottomCenter' then
					love.graphics.translate( w*-.5, h*-1 )
				end
				love.graphics.drawq( child.img, child.rect, 0, 0 )

			-- Draw entire image, center pivot
			else
				if child.align == 'center' then -- Center align
					love.graphics.translate( child.img:getWidth()*-.5, child.img:getHeight()*-.5 )
				elseif child.align == 'bottomCenter' then
					love.graphics.translate( child.img:getWidth()*-.5, child.img:getHeight()*-1 )
				end
				love.graphics.draw( child.img, 0, 0 )
			end
			love.graphics.pop()
		end

		-- Draw group content
		if 0 < #child then
			drawGroup( child )
		end

		-- Exit group offset
		love.graphics.pop()
	end
end

-- Inverted ipairs()
------------------------------------------------
function rpairs( table )
	local i = #table+1
	
	return function ()
		i=i-1
		if i <= 0 then
			return nil
		else
			return i, table[i]
		end
	end
end















