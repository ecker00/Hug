
------------------------------------------------
-- Hug Classes
------------------------------------------------


-- Event listener class
------------------------------------------------
function hug.EventListener()
	local object = {}

	-- Add event listener
	function object:addEventListener( event, callback )
		-- Add an enter frame event
		if event == "enterFrame" then
			table.insert( hug.enterFrame, callback )
		end
	end
	
	-- Dispatch event
	function object:dispatchEvent()
		print("Hug: object:dispatchEvent() not implemented yet.")
	end

	-- Remove event listener
	function object:removeEventListener( event, callback )
		print("Hug: object:removeEventListener() not implemented yet.")
	end

	return object
end

-- Display object class
------------------------------------------------
function hug.DisplayObject( parent )
	-- Display Object inherits from EventListener
	local object = hug.EventListener()

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
	object._color = {r=255,g=255,b=255,a=255}

	-- Not implemented:
	object.blendMode = "normal"
	object.alpha = 1

	-- Scale object
	function object:translate( xPos, yPos )
		self.x = self.x + xPos
		self.y = self.y + yPos
	end

	-- Scale object
	function object:scale( xScale, yScale )
		self.xScale = self.xScale * xScale
		self.yScale = self.yScale * yScale
		self.contentWidth = self.width * xScale
		self.contentHeight = self.height * yScale
	end

	-- Rotate object
	function object:rotate( value )
		self.rotation = self.rotation+value
	end

	-- Remove object
	function object:removeSelf()
		-- Clear from display group
		if self.parent then
			for index, child in ipairs( self.parent ) do
				if child == self then
					table.remove( self.parent, index )
					self.parent.numChildren = #self.parent
					break
		end end end
		-- Clear from animation table
		if self.ani then
			for index, child in ipairs( hug.graphics ) do
				if child == self then
					table.remove( hug.graphics, index )
					break
		end end end
		-- Clear physics
		if self.physics then self.physics = nil end
		self = nil
	end

	-- Align object
	function object:setReferencePoint( alignment )
		 self.align = alignment
	end

	-- Set parent
	if parent then
		object.parent = parent
		parent[ #parent+1 ] = object
		parent.numChildren = parent.numChildren+1
	
	-- No parent, Store object at root
	else
		if hug.graphics then -- Don't parrent the root to itself
			object.parent = hug.graphics
			hug.graphics[ #hug.graphics+1 ] = object
			hug.graphics.numChildren = hug.graphics.numChildren+1
		end
	end

	-- Set fill color
	function object:setFillColor( a, b, c, d )
		-- Overload handling
		if a and b and c and d then -- R G B A
			self._color = {r=a, g=b, b=c, a=d}
		elseif a and b and c then -- R G B
			self._color = {r=a, g=b, b=c, a=self._color.a}
		elseif a and b then -- Luminence Apha
			self._color = {r=a,g=a,b=a,a=b}
		elseif a then -- Luminence
			self._color = {r=a, g=a, b=a, a=self._color.a}
		else
			print("Hug: Wrong number of arguments in object:setFillColor()")
		end
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







