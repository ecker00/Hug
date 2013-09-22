-- Sprite table
graphics = {}
-- Display table
display = {}

display.CenterReferencePoint = 'center'
display.TopLeftReferencePoint = 'topLeft' -- default
display.BottomCenterReferencePoint = 'bottomCenter'


-- New group
------------------------------------------------
function display.newGroup()
	local object = hug.DisplayObject( parent )
	
	-- Properties
	object.numChildren = 0

	-- Adding child
	function object:insert( other )
		-- Set new parent
		other.parent = object
		object[ #object+1 ] = other
		object.numChildren = object.numChildren+1
	end

	-- Removing child
	function object:remove( index )
		table.remove( object, index )
		object.numChildren = object.numChildren-1
	end

	return object
end


-- New image
------------------------------------------------
function display.newImage( a, b, c, d )
	-- Overload handling
	local parent, path, x, y
	if a and b and c and d then
		parent, path, x, y = a, b, c, d
	elseif a and b and c then
		path, x, y = a, b, c
	else
		print("Hug: Wrong number of arguments in display.newImage()")
	end

	-- Create image object
	local object = hug.DisplayObject( parent )
	local img = love.graphics.newImage( path )

	-- Set object data
	object.img = img
	object.rect = false
	object.draw = true
	object.x = x + img:getWidth()*0.5
	object.y = y + img:getHeight()*0.5
	object.width = img:getWidth() -- Not affected by scale
	object.height = img:getHeight() -- Not affected by scale
	object.contentWidth = img:getWidth() -- Affected by scale
	object.contentHeight = img:getHeight() -- Affected by scale

	return object
end


-- New atlas
------------------------------------------------
function graphics.newImageSheet( path, rects )
	-- Moved object creation away from function, because otherwise it was not possible to create
	-- multiple instances of the same sheet, and parenting should be done with newImageRects() anyway
	return { path=path, rects=rects }
end


-- New image from atlas (should be without Rect)
------------------------------------------------
function display.newImageRect( parent, sheet, rectID )
	local object = hug.DisplayObject( parent )
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
	local object = hug.DisplayObject( parent )
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
	hug.graphics[ #hug.graphics+1 ] = object

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

	-- Animation update
	function object:_updateAnimation( dt )
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















