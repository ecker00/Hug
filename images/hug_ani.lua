--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:a94b69ef91ec71763c3d9f877df4514f:1/1$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- hug_01
            x=254,
            y=252,
            width=252,
            height=250,

        },
        {
            -- hug_02
            x=1,
            y=252,
            width=252,
            height=250,

        },
        {
            -- hug_03
            x=254,
            y=1,
            width=252,
            height=250,

        },
        {
            -- hug_04
            x=1,
            y=1,
            width=252,
            height=250,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["hug_01"] = 1,
    ["hug_02"] = 2,
    ["hug_03"] = 3,
    ["hug_04"] = 4,
}

-- My own animation data
SheetInfo.sequenceData = {
    {
        name="hug",
        start=1,
        count=4,
        time=2000,
        loopCount = 0,
        loopDirection = "bounce"
    }
}

-- My own fetch function
function SheetInfo:getSequenceData()
    return self.sequenceData;
end

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
