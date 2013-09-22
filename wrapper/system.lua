system = {}

love.filesystem.setIdentity("LoveBloom")
system.ResourceDirectory = love.filesystem.getWorkingDirectory() .. '/'
system.TemporaryDirectory = love.filesystem.getSaveDirectory()
system.DocumentsDirectory = love.filesystem.getSaveDirectory()

-- Return file path
------------------------------------------------
function system.pathForFile( file, dir )
	return dir .. file
end

function system.getTimer()
	return love.timer.getTime()*1000
end
