-- Sprite table
graphics = {}
-- Display table
display = {}

-- Display properties
------------------------------------------------
display.contentWidth = love.graphics.getWidth()
display.contentHeight = love.graphics.getHeight()
display.CenterReferencePoint = 'center'
display.TopLeftReferencePoint = 'topLeft'
display.TopCenterReferencePoint = 'topCenter'
display.TopRightReferencePoint = 'topRight'
display.CenterRightReferencePoint = 'centerRight'
display.BottomRightReferencePoint = 'bottomRight'
display.BottomCenterReferencePoint = 'bottomCenter'
display.BottomLeftReferencePoint = 'bottomLeft'
display.CenterLeftReferencePoint = 'centerLeft'


-- New group
------------------------------------------------
function display.newGroup()
	local object = hug.DisplayObject( parent )
	
	-- Properties
	object.numChildren = 0

	-- Adding child
	function object:insert( other )
		-- Set new parent
		other.parent = self
		self[ #self+1 ] = other
		self.numChildren = self.numChildren+1
	end

	-- Removing child
	function object:remove( index )
		table.remove( self, index )
		self.numChildren = self.numChildren-1
	end

	return object
end


function display.newRect( a, b, c, d, e )
	-- Overload handling
	local parent, x, y, w, h
	if a and b and c and d and e then
		parent, x, y, w, h = a, b, c, d, e
	elseif a and b and c and d then
		x, y, w, h = a, b, c, d
	else
		print("Hug: Wrong number of arguments in display.newRect()")
	end

	-- Create display and image object
	local object = hug.DisplayObject( parent )

	-- Set object parameters
	object._rectangle = {w=w, h=h}
	object._rect = false
	object.isVisible = true
	object.x = x
	object.y = y
	object.width = w
	object.height = h
	object.contentWidth = w
	object.contentHeight = h
	object:setReferencePoint( display.TopLeftReferencePoint )

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

	-- Create display and image object
	local object = hug.DisplayObject( parent )
	local image = love.graphics.newImage( path )

	-- Set object parameters
	object._image = image
	object._rect = false
	object.isVisible = true
	object.x = x + image:getWidth()*0.5
	object.y = y + image:getHeight()*0.5
	object.width = image:getWidth() -- Not affected by scale
	object.height = image:getHeight() -- Not affected by scale
	object.contentWidth = image:getWidth() -- Affected by scale
	object.contentHeight = image:getHeight() -- Affected by scale

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
	object._image = love.graphics.newImage( sheet.path )
	object.isVisible = true -- FIX: change to .isVisible

	-- Define rect
	local data = sheet.rects
	local x = data.frames[ rectID ].x
	local y = data.frames[ rectID ].y
	local w = data.frames[ rectID ].width
	local h = data.frames[ rectID ].height
	local width = data.sheetContentWidth
	local height = data.sheetContentHeight
	object._rect = love.graphics.newQuad( x, y, w, h, width, height )

	return object
end


-- New image from atlas (should be without Rect)
------------------------------------------------
function display.newSprite( a, b, c )
	-- Overload handling
	local parent, sheet, sequences
	if a and b and c then
		parent, sheet, sequences = a, b, c
	elseif a and b then
		sheet, sequences = a, b
	else
		print("Hug: Wrong number of arguments in display.newSprite()")
	end

	-- Create display object
	local object = hug.DisplayObject( parent )
	-- Create image
	object._image = love.graphics.newImage( sheet.path )

	-- Hug properties
	object._sequences = sequences
	object._loopDirection = "forward"
	object._rects = sheet.rects
	object._rect = false
	object._timer = 0
	object._time = 0

	-- Set animation properties
	object.isVisible = false
	object.start = 1
	object.frame = 1
	object.isPlaying = false
	object.numFrames = 1
	object.loopCount = 0 -- FIX: Loop count is not implemented
	object.timeScale = 1.0
	object.sequence = nil -- FIX: Supposed to default to sequence 1 when non is set.

	-- Play animation
	function object:play()
		self.isPlaying = true
	end

	-- Pause animation
	function object:pause()
		self.isPlaying = false
	end

	-- Set frame rect
	function object:setFrame( frameIndex )
		self.frame = frameIndex

		local data = object._rects
		local x = data.frames[ frameIndex ].x
		local y = data.frames[ frameIndex ].y
		local w = data.frames[ frameIndex ].width
		local h = data.frames[ frameIndex ].height
		local width = data.sheetContentWidth
		local height = data.sheetContentHeight

		-- Define rect
		self._rect = love.graphics.newQuad( x, y, w, h, width, height )
	end

	-- Set sequence data
	function object:setSequence( name )
		for index, seq in pairs( self._sequences ) do
			if seq.name == name or index == name then
				-- Set sequence data
				self.isVisible = true
				self._time = seq.time
				self.start = seq.start
				self.numFrames = seq.count
				self.loopCount = seq.loopCount
				self._loopDirection = seq.loopDirection
				self.sequence = name
				self:setFrame( seq.start )

				-- Update transformation data
				local _, _, width, height = self._rect:getViewport()
				self.width = width
				self.height = height
				self.contentWidth = width * self.xScale
				self.contentHeight = height * self.yScale
				break
			end
		end
	end

	-- Animation update
	function object:_updateAnimation( dt )
		if not self.isPlaying then return end -- return when paused

		-- Count down
		if self._timer > self._time/self.numFrames then
			self._timer = 0
			local frame

			-- Set next frame: Forward
			if self._loopDirection == "forward" then
				frame = self.frame+1
				if frame > self.numFrames then
					frame = self.start
				end

			-- Set next frame: Bounce
			elseif self._loopDirection == "bounce" then
				print('Hug: display.newSprite() with bounce animation is not yet implemented.')

			-- Set next frame: Backward ( Note: Backward does not exist in CoronaSDK )
			elseif self._loopDirection == "backward" then
				frame = self.frame-1
				if frame <= self.start then
					frame = self.numFrames
				end
			end
			self:setFrame( frame )
		end

		-- Increment timer
		self._timer = self._timer + (dt*1000 * self.timeScale)
	end

	-- Set default sequence
	object:setSequence(1)
	return object
end















