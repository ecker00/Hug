timer = {}

-- Create timer
------------------------------------------------
function timer.performWithDelay( delay, callback )
	-- Create a timer time object
	local timeObj = {}
	timeObj.callback = callback
	timeObj.delay = delay
	timeObj.time = 0

	timer[ #timer+1 ] = timeObj
	return timeObj
end

-- Resume timer
------------------------------------------------
function timer.resume( id )
	print("Hug: timer.pause is not yet implemented.")
end

-- Pause timer
------------------------------------------------
function timer.pause( id )
	print("Hug: timer.pause is not yet implemented.")
end

-- Updates all timers
------------------------------------------------
function timer.update( dt )
	local r = 0
	--for _, timeObj in ipairs( timer ) do
	for i = 1, #timer do
		local timeObj = timer[i-r]

		timeObj.time = timeObj.time + (dt*1000)

		-- Check timer
		if timeObj.delay <= timeObj.time then
			timeObj.callback()
			table.remove( timer, i-r )
			timeObj = nil
			r=r+1
		end
	end
end


