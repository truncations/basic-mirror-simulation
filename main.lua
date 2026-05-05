-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
--[[

variables

]]
-- when we need to make the ui to change how the mirror behaves and stuff
local uiModSizeX = display.contentWidth
local uiModSizeY = 150

-- the "y-intercept"
local xMid = display.contentCenterX
-- the "x-intercept"
local yMid = display.contentCenterY - (uiModSizeY / 2)

-- re_ --> relative to
local objectDistance_re_xMid = 75
local objectHeight = 50

local radiusOfCurvature = 200
local focusDistance
-- depends on object's position and type of mirror
-- which influences how the light rays will behave.
local horizontalRay_slope
local horizontalRay_finalPos
local angledRay_slope
local angledRay_finalPos
local xIntersection

local needsImageRayLines = false

--[[

UI variables

]]
local bgGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiModGroup = display.newGroup()

local objectLine
local objectLeftArrow
local objectRightArrow

local realSide_focus

local imageLine
local imageLeftArrow
local imageRightArrow

local incidentRay_horizontal
local refractedRay_horizontal
local imageRay_horizontal

local incidentRay_angled
local refractedRay_angled
local imageRay_angled

local background = display.newRect(bgGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight);
background:setFillColor(166/255, 185/255, 193/255)

local mirror = display.newCircle( mainGroup, xMid - 5998, yMid, 6000 )
mirror.strokeWidth = 5
mirror:setStrokeColor(0,0,0)
mirror:setFillColor(0,0,0,0)
-- UI mod
local uiFrame = display.newRect(uiModGroup, display.contentCenterX, display.contentHeight - (uiModSizeY / 2), uiModSizeX, uiModSizeY)
uiFrame:setFillColor(155/255, 171/255, 178/255)

local title = display.newText( uiModGroup, "ap phys 2 mirror sim. (units in pixels)", 850, display.contentHeight - uiModSizeY + 20, 1000, 35, native.systemFont, 25)
local objectDistDisplay = display.newText( {parent = uiModGroup, text = objectDistance_re_xMid, x = 68, y = display.contentHeight - uiModSizeY/2, width = 500, height = 85, font = native.systemFont, fontSize = 65, align = "center"})
local objectDistHeader = display.newText( {parent = uiModGroup, text = "object distance", x = 68, y = display.contentHeight - 13, width = 75, height = 65, font = native.systemFont, fontSize = 17, align = "center"})

local objectHeightDisplay = display.newText( {parent = uiModGroup, text = objectHeight, x = 303, y = display.contentHeight - uiModSizeY/2, width = 500, height = 85, font = native.systemFont, fontSize = 65, align = "center"})
local objectHeightHeader = display.newText( {parent = uiModGroup, text = "object height", x = 303, y = display.contentHeight - 13, width = 75, height = 65, font = native.systemFont, fontSize = 17, align = "center"})

local radiusOfCurvDisplay = display.newText( {parent = uiModGroup, text = radiusOfCurvature, x = 538, y = display.contentHeight - uiModSizeY/2, width = 500, height = 85, font = native.systemFont, fontSize = 65, align = "center"})
local radiusOfCurvHeader = display.newText( {parent = uiModGroup, text = "radius of curvature", x = 538, y = display.contentHeight - 13, width = 75, height = 65, font = native.systemFont, fontSize = 17, align = "center"})

local imageDistDisplay = display.newText( {parent = uiModGroup, text = "0", x = 773, y = display.contentHeight - uiModSizeY/2, width = 500, height = 85, font = native.systemFont, fontSize = 65, align = "center"})
local imageDistHeader = display.newText( {parent = uiModGroup, text = "image distance", x = 773, y = display.contentHeight - 13, width = 75, height = 65, font = native.systemFont, fontSize = 17, align = "center"})

local imageHeightDisplay = display.newText( {parent = uiModGroup, text = "0", x = 1008, y = display.contentHeight - uiModSizeY/2, width = 500, height = 85, font = native.systemFont, fontSize = 65, align = "center"})
local imageHeightHeader = display.newText( {parent = uiModGroup, text = "image height", x = 1008, y = display.contentHeight - 13, width = 75, height = 65, font = native.systemFont, fontSize = 17, align = "center"})
--[[

functions

]]

local function getSlope(x1, y1, x2, y2)
    local numerator = y2 - y1
    local denominator = x2 - x1
    return numerator / denominator
end

local function getPointWithSlopePointFormula(input, slope, focusX, focusY)
    local x = input;
    local y = (-slope * (input - focusX)) + focusY

    return {x, y}
end

local function getXgivenYWithSlopePointFormula(y, slope, focusX, focusY)
    return -((y - focusY) / slope) + focusX
end

local function calculateFocus()
    focusDistance = radiusOfCurvature/2
end

local function updateImageText(dist, height)
    height = yMid - height
    dist = xMid - dist

    imageDistDisplay.text = dist
    imageHeightDisplay.text = height
end

local function updateObjectAndRadiusOfCurvText()
    objectDistDisplay.text = math.floor(objectDistance_re_xMid)
    objectHeightDisplay.text = math.floor(objectHeight)
    radiusOfCurvDisplay.text = radiusOfCurvature
end

local function calculateImage()
    horizontalRay_slope = getSlope(xMid, yMid + objectHeight, xMid - focusDistance, yMid)
    horizontalRay_finalPos = getPointWithSlopePointFormula(0, horizontalRay_slope, xMid - focusDistance, yMid)
    angledRay_slope = getSlope(xMid - objectDistance_re_xMid, yMid + objectHeight, xMid - focusDistance, yMid)
    angledRay_finalPos = getPointWithSlopePointFormula(xMid, angledRay_slope, xMid - focusDistance, yMid)

    xIntersection = getXgivenYWithSlopePointFormula(angledRay_finalPos[2], horizontalRay_slope, xMid - focusDistance, yMid)
    updateImageText(math.floor(xIntersection), math.floor(angledRay_finalPos[2]))
end

local function makeHorizontalFullRay()
    incidentRay_horizontal = display.newLine(mainGroup, xMid - objectDistance_re_xMid, yMid - objectHeight, xMid, yMid - objectHeight)
    incidentRay_horizontal.strokeWidth = 2
    incidentRay_horizontal:setStrokeColor(0,0,0)

    refractedRay_horizontal = display.newLine(mainGroup, xMid, yMid - objectHeight, horizontalRay_finalPos[1], horizontalRay_finalPos[2])
    refractedRay_horizontal.strokeWidth = 2
    refractedRay_horizontal:setStrokeColor(0,0,0)

    if objectDistance_re_xMid < focusDistance then
        needsImageRayLines = true
        imageRay_horizontalFinalPos = getPointWithSlopePointFormula(1100, horizontalRay_slope, xMid - focusDistance, yMid)
        imageRay_horizontal = display.newLine(mainGroup, xMid, yMid - objectHeight, imageRay_horizontalFinalPos[1], imageRay_horizontalFinalPos[2])
        imageRay_horizontal.strokeWidth = 3
        imageRay_horizontal:setStrokeColor(0,0,0,0.3)
    end

    -- check if image ray is active then do this
    if needsImageRayLines then
        if objectDistance_re_xMid < 0 then
            refractedRay_horizontal:setStrokeColor(0,0,0,0.3)
            imageRay_horizontal:setStrokeColor(0,0,0)
        else
            refractedRay_horizontal:setStrokeColor(0,0,0)
            imageRay_horizontal:setStrokeColor(0,0,0,0.3)
        end
    end
end

local function makeAngledFullRay()
    incidentRay_angled = display.newLine(mainGroup, xMid - objectDistance_re_xMid, yMid - objectHeight, angledRay_finalPos[1], angledRay_finalPos[2])
    incidentRay_angled.strokeWidth = 2
    incidentRay_angled:setStrokeColor(0,0,0)

    refractedRay_angled = display.newLine(mainGroup, angledRay_finalPos[1], angledRay_finalPos[2], 0, angledRay_finalPos[2])
    refractedRay_angled.strokeWidth = 2
    refractedRay_angled:setStrokeColor(0,0,0)

    if objectDistance_re_xMid < focusDistance then
        needsImageRayLines = true
        imageRay_angledFinalPos = getPointWithSlopePointFormula(1100, angledRay_slope, xMid - focusDistance, yMid)
        imageRay_angled = display.newLine(mainGroup, angledRay_finalPos[1], angledRay_finalPos[2], 1100, angledRay_finalPos[2])
        imageRay_angled.strokeWidth = 3
        imageRay_angled:setStrokeColor(0,0,0,0.3)
    end

    if needsImageRayLines then
        if objectDistance_re_xMid < 0 then
            refractedRay_angled:setStrokeColor(0,0,0,0.3)
            imageRay_angled:setStrokeColor(0,0,0)
        else
            refractedRay_angled:setStrokeColor(0,0,0)
            imageRay_angled:setStrokeColor(0,0,0,0.3)
        end
    end
end

local function makeFocus()
    realSide_focus = display.newCircle( mainGroup, xMid - focusDistance, yMid, 10 )
    realSide_focus:setFillColor(255/255,255/255,0)
    --realSide_focus = display.newLine(mainGroup, xMid - focusDistance, yMid + 15, xMid - focusDistance, yMid - 15)
    realSide_focus.strokeWidth = 2
    realSide_focus:setStrokeColor(0,0,0)
end

local function makeImageRay()
    imageLine = display.newLine(mainGroup, xIntersection, yMid, xIntersection, angledRay_finalPos[2])
    imageLine.strokeWidth = 3
    imageLine:setStrokeColor(0,25/255,191/255, 0.3) 

    if (yMid - angledRay_finalPos[2] > 0) then
        -- make arrow for the object, makes it more appealing lol
        imageLeftArrow = display.newLine(mainGroup, xIntersection, angledRay_finalPos[2], xIntersection - 20, angledRay_finalPos[2] + 20)
        imageLeftArrow.strokeWidth = 3
        imageLeftArrow:setStrokeColor(0,25/255,191/255, 0.3)
            
        imageRightArrow = display.newLine(mainGroup, xIntersection - 1, angledRay_finalPos[2], xIntersection + 20, angledRay_finalPos[2] + 20)
        imageRightArrow.strokeWidth = 3
        imageRightArrow:setStrokeColor(0,25/255,191/255, 0.3)
    else
        -- make arrow for the object, makes it more appealing lol
        imageLeftArrow = display.newLine(mainGroup, xIntersection, angledRay_finalPos[2], xIntersection - 20, angledRay_finalPos[2] - 20)
        imageLeftArrow.strokeWidth = 3
        imageLeftArrow:setStrokeColor(0,25/255,191/255, 0.3)
            
        imageRightArrow = display.newLine(mainGroup, xIntersection - 1, angledRay_finalPos[2], xIntersection + 20, angledRay_finalPos[2] - 20)
        imageRightArrow.strokeWidth = 3
        imageRightArrow:setStrokeColor(0,25/255,191/255, 0.3)
    end
end

local function makeObjectRay()
    objectLine = display.newLine(mainGroup, xMid - objectDistance_re_xMid, yMid, xMid - objectDistance_re_xMid, yMid - objectHeight)
    objectLine.strokeWidth = 3
    objectLine:setStrokeColor(0,25/255,191/255) 
    
    if (objectHeight > 0) then
        -- make arrow for the object, makes it more appealing lol
        objectLeftArrow = display.newLine(mainGroup, xMid - objectDistance_re_xMid, yMid - objectHeight, xMid - objectDistance_re_xMid - 20, yMid - objectHeight + 20)
        objectLeftArrow.strokeWidth = 3
        objectLeftArrow:setStrokeColor(0,25/255,191/255)

        objectRightArrow = display.newLine(mainGroup, xMid - objectDistance_re_xMid - 1, yMid - objectHeight, xMid - objectDistance_re_xMid + 20, yMid - objectHeight + 20)
        objectRightArrow.strokeWidth = 3
        objectRightArrow:setStrokeColor(0,25/255,191/255)
    else
        -- make arrow for the object, makes it more appealing lol
        objectLeftArrow = display.newLine(mainGroup, xMid - objectDistance_re_xMid, yMid - objectHeight, xMid - objectDistance_re_xMid - 20, yMid - objectHeight - 20)
        objectLeftArrow.strokeWidth = 3
        objectLeftArrow:setStrokeColor(0,25/255,191/255)

        objectRightArrow = display.newLine(mainGroup, xMid - objectDistance_re_xMid - 1, yMid - objectHeight, xMid - objectDistance_re_xMid + 20, yMid - objectHeight - 20)
        objectRightArrow.strokeWidth = 3
        objectRightArrow:setStrokeColor(0,25/255,191/255)
    end
end

local function startUI()
    calculateFocus()
    calculateImage()
    updateObjectAndRadiusOfCurvText()
    makeHorizontalFullRay()
    makeAngledFullRay()
    makeObjectRay()
    makeImageRay()
    makeFocus()
end

local function resetAllUI()
    display.remove(objectLine)
    display.remove(objectLeftArrow)
    display.remove(objectRightArrow)
    display.remove(realSide_focus)
    display.remove(imageLine)
    display.remove(imageLeftArrow)
    display.remove(imageRightArrow)
    display.remove(incidentRay_horizontal)
    display.remove(refractedRay_horizontal)
    display.remove(imageRay_horizontal)
    display.remove(incidentRay_angled)
    display.remove(refractedRay_angled)
    display.remove(imageRay_angled)

    needsImageRayLines = false
    startUI()
end

local function moveObject( event )
    local hover = event.target

    if event.phase == "began" then
        display.currentStage:setFocus(hover)
        hover.initialPosX = event.x - hover.x
        hover.initialPosY = event.y - hover.y
    elseif event.phase == "moved" then
        hover.x = math.max(math.min(event.x - hover.initialPosX, xMid + 525),25)
        hover.y = math.max(math.min(event.y - hover.initialPosY, yMid + 125),200)

        if hover.y > yMid then
            hover.height = (hover.y + hover.height/2) - yMid
            objectHeight = -hover.height
        else
            hover.height = yMid - (hover.y - hover.height/2)
            objectHeight = hover.height
        end
        objectDistance_re_xMid = xMid - hover.x
        
        resetAllUI()
    elseif event.phase == "ended" or event.phase == "cancelled" then
        display.currentStage:setFocus( nil )
    end

    --print(hover.x, hover.y)

    return true
end

local function increaseROC()
    if radiusOfCurvature < 1000 then
        radiusOfCurvature = radiusOfCurvature + 20
    end
    
    resetAllUI()
end

local function decreaseROC()
    if radiusOfCurvature > 0 then
        radiusOfCurvature = radiusOfCurvature - 20
    end
    
    resetAllUI()
end

--[[

actually make display here

]]

-- used for making the object bigger/smaller, change distance wtver..
local objectHover = display.newRect(mainGroup, xMid - objectDistance_re_xMid, yMid - objectHeight / 2, 40, objectHeight)
objectHover:setFillColor(0, 0, 0, 0.1)
objectHover:addEventListener( "touch", moveObject )

local decreaseROCButton = display.newRect(uiModGroup, display.contentCenterX - 95, display.contentHeight - uiModSizeY/2 + 5, 20, 20)
decreaseROCButton:setFillColor(188/255,154/255,149/255)
decreaseROCButton:rotate(45)

local increaseROCButton = display.newRect(uiModGroup, display.contentCenterX + 65, display.contentHeight - uiModSizeY/2 + 5, 20, 20)
increaseROCButton:setFillColor(153/255,232/255,146/255)
increaseROCButton:rotate(45)

decreaseROCButton:addEventListener("tap", decreaseROC)
increaseROCButton:addEventListener("tap", increaseROC)

local concaveText = display.newText( mainGroup, "Concave", 400, 50, 500, 65, native.systemFont, 55, "center")
concaveText:setFillColor(0,0,0,0.25)

local convexText = display.newText( mainGroup, "Convex", 985, 50, 500, 65, native.systemFont, 55, "center")
convexText:setFillColor(0,0,0,0.25)

local maxOfMidLine = 25
local marginX = 10
for i = 1, maxOfMidLine do
    local yMidLine = display.newLine(mainGroup, (display.contentWidth/maxOfMidLine)*(i - 1), yMid, (display.contentWidth/maxOfMidLine)*i - marginX, yMid)
    yMidLine.strokeWidth = 2
    yMidLine:setStrokeColor(255/255,0,0,0.5)
end

resetAllUI()
