module("TableView", package.seeall)
local serpent = require("serpent")

------------------------------------------------------------------------        
-- PROPERTIES
------------------------------------------------------------------------

local screenW, screenH 
local viewableScreenW, viewableScreenH 
local screenOffsetW, screenOffsetH 
local currentTarget
local enableSelected = true
local startTime, lastTime, prevTime = 0, 0, 0

local TView = Core.class(Shape)
	function TView:init(w, h)
		log("TView:init("..w..", "..h..")")
		self.rowSize = 0
		self.listItems = {}
		self.viewSize = 0
		self.numRender = 0
		self.itemData = {}
		self.renderParams = {}
		
		--self:setFillStyle(Shape.SOLID, 0x00FF00)
		self:beginPath()
		self:moveTo(0, 0)
		self:lineTo(0, h)
		self:lineTo(w, h)
		self:lineTo(w, 0)
		self:closePath()
		self:endPath()
	end


function rect(w, h)
	log({"rect",w=w,h=h})
	local shape = Shape.new()
	shape:setFillStyle(Shape.SOLID, 0x00FF00)
	shape:beginPath()
	shape:moveTo(0, 0)
	shape:lineTo(0, w)
	shape:lineTo(h, w)
	shape:lineTo(h, 0)
	shape:closePath()
	shape:endPath()
	return shape
end

function log(data)
	print(serpent.block(data))
end


------------------------------------------------------------------------        
-- RENDER EACH LIST ITEM IF IT DOESN'T EXIST OR RE-RENDER IT
------------------------------------------------------------------------

function render(thisItem, data, id)
	
	if thisItem == nil then
		print("Creating new row objects")
	    thisItem = newListItem{
	        data = data.objectData,
	        defaultBg = currentTarget.renderParams.defaultBg,
	        overBg = currentTarget.renderParams.overBg,
	        onRelease = currentTarget.renderParams.onRelease,
	        top = currentTarget.renderParams.top,
	        left = currentTarget.renderParams.left,
			rowSize = currentTarget.renderParams.rowSize,
			width = currentTarget.renderParams.width,
	        bgColor = currentTarget.renderParams.bgColor,
	        callback = currentTarget.renderParams.callback,
	        id = id
	    }
	else		
		thisItem:removeChildAt(thisItem:getNumChildren())
		local callback = currentTarget.renderParams.callback
		local t = callback(data.objectData)
		thisItem:addChild(t)    
		thisItem.id = id
	end

	print("rendering item: ".. id)
	return thisItem
end


------------------------------------------------------------------------        
-- START THE RENDERING OF A GIVEN NUMBER OF LIST ITEMS
------------------------------------------------------------------------

function createRender()

	local itemIndex = 1
	
	while itemIndex <= currentTarget.numRender do
		log("itemIndex="..itemIndex)
		local displayObject = render(nil, currentTarget.itemData[itemIndex], itemIndex)
		currentTarget.listItems:addChild(displayObject)
		displayObject:setPosition(currentTarget.itemData[itemIndex].xInit, currentTarget.itemData[itemIndex].yInit+itemIndex)
		itemIndex = itemIndex + 1
	end 
	currentTarget.listItems.yInit = currentTarget.listItems:getY()
end

function updateRender()
	-- Location of the bottom of the list
	local bottom = currentTarget.viewSize - currentTarget.listItems:getY()
	print("bottom", bottom, currentTarget.listItems:getY())
	
	local fillToTop = currentTarget.listItems:getChildAt(1):getY() > currentTarget.listItems:getY()*-1  
	local fillToBottom = currentTarget.listItems:getChildAt(currentTarget.numRender-1):getY() + currentTarget.rowSize < bottom
	
    -----------------------------------
    -- Fill in items from the bottom
	-- as the list scrolls up
    -----------------------------------

	if fillToBottom then
		log("fillToBottom")

		while (currentTarget.listItems:getChildAt(currentTarget.numRender-1):getY() + currentTarget.rowSize < bottom) and (currentTarget.listItems:getChildAt(currentTarget.numRender).id ~= #currentTarget.itemData) do
		
			local y = currentTarget.listItems:getChildAt(currentTarget.numRender):getY() + currentTarget.rowSize
			local displayObject = currentTarget.listItems:getChildAt(1)
			--
			render(displayObject, currentTarget.itemData[y/currentTarget.rowSize + 1], y/currentTarget.rowSize + 1)
			currentTarget.listItems:addChild(displayObject)
			displayObject.y = y			
		end
		
    -----------------------------------
    -- Fill in items from the top
	-- as the list scrolls down
    -----------------------------------

	elseif fillToTop then
		log("fillToTop")
    -----------------------------------
    -- redraw all, jumped in list?
    -----------------------------------

	elseif fillToBottom and fillToTop then
		
--		print("error - fill to both?")

	end
	
end


------------------------------------------------------------------------        
-- BLUEPRINT FOR EACH LIST ITEM
------------------------------------------------------------------------

function newListItem(params)
	
        local data = params.data
        local default = params.default
        local over = params.over
        local onRelease = params.onRelease
        local top = params.top
        local left = params.left
		local width = params.width
		local rowSize = params.rowSize
        local bgColor = params.bgColor
        local callback = params.callback 
        local id = params.id
 
        local thisItem = Shape.new()
		thisItem:setFillStyle(Shape.SOLID, 0x00FFAA)
		thisItem:beginPath()
		thisItem:moveTo(0,0)
		thisItem:lineTo(0, rowSize)
		thisItem:lineTo(width, rowSize)
		thisItem:lineTo(width, 0)
		thisItem:endPath()
			
		--local thisItem = Sprite.new()
		
        if params.default then
			default = Texture.new(params.default)
			thisItem:addChild(default)
			default.x = default.width*.5 - screenOffsetW
			thisItem.default  = default
        end
        
        if params.over then
			over = Texture.new(params.over)
			over.isVisible = false
			thisItem:addChild(over)
			over.x = over.width*.5 - screenOffsetW
			thisItem.over = over
        end
 
        thisItem.id = id
        thisItem.onRelease = onRelease          
        thisItem.top = top
        thisItem.bottom = bottom
 
        local t = callback(data)
        thisItem:addChild(t)
 
        --thisItem.touch = newListItemHandler
        thisItem:addEventListener("touchesBegin", newListItemTouchBegin)
		thisItem:addEventListener("touchesMove", newListItemTouchMove)
		thisItem:addEventListener("touchesEnd", newListItemTouchEnd)
		
        if bgColor then
			print(bgColor,thisItem:getWidth(), thisItem:getHeight())
			local bColor = Shape.new()
			--bColor:setFillStyle(Shape.SOLID, bgColor)
			bColor:beginPath()
			bColor:moveTo(0,0)
			bColor:lineTo(0, thisItem:getHeight())
			bColor:lineTo(thisItem:getWidth(), thisItem:getHeight())
			bColor:lineTo(thisItem:getWidth(), 0)
			bColor:endPath()
			thisItem:addChildAt(bColor, 1)
	    end        
        return thisItem
end


function newList(params) 
	screenW, screenH = application:getDeviceWidth(), application:getDeviceHeight()
	viewableScreenW, viewableScreenH = application:getContentWidth(), application:getContentHeight()
	screenOffsetW, screenOffsetH = screenW - viewableScreenW, screenH - viewableScreenH

	local debugMode = params.debug or false
	local textSize = 16
	local rowSize = params.rowSize or 40
	local onRelease = params.onRelease or nil
	local top = params.top or 20
	local left = params.left or 20
	local width = params.width or 100
	local height = params.height or 100
	local cat = params.cat or nil
	local order = params.order or {}
	local defaultBg = params.defaultBg or nil
	local overBg = params.overBg or nil		
	local categoryBg = params.categoryBg or nil
	local bgColor = params.bgColor or nil
	local data = params.data or {}
	local font = params.font or nil
	local callback = params.callback or function(item)
											local t = TextField.new(font,item)
											t:setTextColor(0, 0, 0)
											t:setPosition(24, 24)
											return t
										end		
	
	if debugMode then
		log({
			screenW		= screenW,
			screenH		= screenH,
			viewableScreenW	= viewableScreenW,
			viewableScreenH	= viewableScreenH,
			screenOffsetW	= screenOffsetW,
			screenOffsetH	= screenOffsetH,
			textSize	= textSize,
			rowSize		= rowSize,
			onRelease	= onRelease,
			top			= top,
			bottom		= bottom,
			cat			= cat,
			order		= order,
			defaultBg	= defaultBg,
			overBg		= overBg,
			categoryBg	= categoryBg,
			bgColor 	= bgColor
		})
	end

	local listView = TView.new(width, height)
	local listItems = Sprite.new()
	
	local finalData = {}
	local prevY, prevH, j,k,c = 0,0,0,0,{}
	
	while true do
		--iterate over the data and add items to the list view
		for i=1, #data do
			--if data[i][cat] == h then
				--print(data[i])
				k = k + 1
				finalData[k] = {}
				finalData[k].objectData = data[i]
				finalData[k].xInit = 0
				finalData[k].yInit = prevY + prevH

				prevY = finalData[k].yInit
				prevH = rowSize
				
			--end --if	            
		end --for
					
		j = j + 1
		if not order[j] then break end
	end
	
	listView:addChild(listItems)
	listView:setPosition(left,top)
	listView.rowSize = rowSize
	listView.listItems = listItems
	listView.viewSize = height

	listView.numRender = math.ceil(height/rowSize)
	if listView.numRender > #finalData then listView.numRender = #finalData end

	log(height)
	log(rowSize)
	log(math.ceil(height/rowSize))

	listView.itemData = finalData
	finalData = nil	--clear out the finalData table
	
	listView.renderParams = {
		defaultBg = defaultBg,
		overBg = overBg,
		onRelease = onRelease,
		top = top,
		left = left,
		width = width,
		height = height,
		bgColor = bgColor,
		callback = callback,
		rowSize = rowSize
	    }
	
    currentTarget = listView
	createRender()
		
	function listView:scrollTo(yVal, timeVal)
		local timeVal = timeVal or 400
		local yVal = yVal or 0
		self.yVal = yVal
		lastTime = system.getTimer()
		velocity = 100
		self:addEventListener("onEnterFrame", scrollList)
	end
	
	function listView:enableSelected()
		enableSelected = true
	end
	
	function listView:cleanUp()
		local i
		for i = listView.numChildren, 1, -1 do
			listView[i]:removeEventListener("touch", newListItemHandler)
			listView:remove(i)
			listView[i] = nil
		end
	end
	
	return listView
end

function scrollList()
end

function newListItemTouch(e, act)
	local delta, velocity,prevPos = 0, 0, 0
	local t = currentTarget.listItems
	local top,height = currentTarget:getY(), currentTarget:getHeight()

	if(act == "begin") then
		startPos = e.y
		prevPos = e.y
		delta, velocity = 0, 0
		
		stage:removeEventListener("enterFrame", scrollList) 
		stage:addEventListener("enterFrame", trackVelocity)	
	end
	
	if(act == "move") then
		delta = e.touch.y - prevPos
		prevPos = e.touch.y
		log(delta)
		if (t:getChildAt(1).id == 1 and t:getY() > top) or (t:getChildAt(currentTarget.numRender).id == #currentTarget.itemData  and t:getY() < height) then
			--make the list resist being pulled too far beyond edges
			t.y = t:getY() + delta/2
		else
			t.y = t:getY() + delta
		end            

		updateRender()     		
	end
	
	if(act == "end") then
	end
end

function newListItemTouchBegin(e)
	log("newListItemTouchBegin")
	newListItemTouch(e,"begin")
end

function newListItemTouchMove(e)
	log("newListItemTouchMove")
	newListItemTouch(e,"move")
end

function newListItemTouchEnd(e)
	log("newListItemTouchEnd")
end


------------------------------------------------------------------------        
-- SCROLL THE LIST UP OR DOWN.
------------------------------------------------------------------------

function scrollList(event)   
	
        --turn off scrolling if velocity is near zero
	if math.abs(velocity) < .01 then
		velocity = 0
		application:removeEventListener("enterFrame", scrollList )
   end 
end
------------------------------------------------------------------------        
-- TRACK THE VELOCITY OF THE TOUCH MOVING THE LIST.
------------------------------------------------------------------------

function trackVelocity(event) 	
	
	local timePassed = event.time - prevTime
	prevTime = prevTime + timePassed

	if prevY then 
		velocity = (currentTarget.listItems.y - prevY)/timePassed 
	end
	prevY = currentTarget.listItems.y
end