module("ListView", package.seeall)
--
--====================================================================--        
-- ListView widget for Gigerosmobile
--====================================================================--
--
-- ListView.lua
-- Version 0.1 beta
-- Author: Lukas Gergel, http://pykaso.net
-- 
-- This library is free to use and modify.  Use it for free!
--
-- TODO: add methods for programatic manipulating with ListView
--
-- USAGE
--
-- myList = ListView.new({
--	width=280,
--	height=390,
--	bgTexture = Texture.new("texture.png"),
--  bgColor = 0xffffff,
--  rowSnap = true, -- experimental feature
--  friction = 0.92 -- number lower then 1
--	data=data
-- })
--
-- minimal example
--
-- myList = ListView.new({
--	width=280,
--	height=390,
--	data=data

ListView = Core.class(Shape)

function ListView:init(params)
	-- properties
	self.velocityPrevTime = 0
	self.listHeight = 0
	
	--data items (pre rendered sprites)
	local data = params.data or {}
	
	--configuration
	self.cfg = {
		--dimension
		width = params.width or self.screenW,
		height = params.height or self.screenH,
		bgColor = params.bgColor or nil,
		bgTexture = params.bgTexture or nil,
		rowSnap = params.rowSnap or false,
		friction = params.friction or 0.92,		
		callback = params.callback or function(row) return row end,
		onScroll = params.onScroll or nil
	}

	local prevY, prevH, i, finalData = 0,0,0,{}
	
	for i=1, #data do
		finalData[i] = {}
		finalData[i].objectData = data[i]
		finalData[i].height = data[i]:getHeight()
		finalData[i].xInit = 0
		finalData[i].yInit = prevY + prevH
		prevY = finalData[i].yInit
		prevH = finalData[i].height         
		self.listHeight = self.listHeight +  finalData[i].height
	end
	
	if(self.cfg.bgTexture ~= nil) then
		self:setFillStyle(Shape.TEXTURE, self.cfg.bgTexture)
	elseif(self.cfg.bgColor ~= nil) then
		self:setFillStyle(Shape.SOLID, self.cfg.bgColor, 1)
	end
	
	-- create defined shape
	self:beginPath()
	self:moveTo(0, 0)
	self:lineTo(0, self.cfg.height)
	self:lineTo(self.cfg.width, self.cfg.height)
	self:lineTo(self.cfg.width, 0)
	self:closePath()
	self:endPath()
	
	-- create defined shape
	self.mask = Shape.new()
	self.mask:beginPath()
	self.mask:moveTo(0, 0)
	self.mask:lineTo(0, self.cfg.height)
	self.mask:lineTo(self.cfg.width, self.cfg.height)
	self.mask:lineTo(self.cfg.width, 0)
	self.mask:closePath()
	self.mask:endPath()
	self:addChild(self.mask)
	
	self.listItems = Sprite.new()
	self:addChild(self.listItems)
	self.viewSize = self.cfg.height
	
	self.itemData = finalData
	finalData = nil
	self:createRender()
end

function ListView:newListItem(id, data)	
		local thisItem = Sprite.new() 
		local callback = self.cfg.callback
        local t = callback(data)
		local tv = self;
		thisItem.id = id
        thisItem:addChild(t)

        thisItem:addEventListener(Event.TOUCHES_BEGIN,
			function(e)
				if(self.mask:hitTestPoint(e.touch.x, e.touch.y)) then
					tv:listItemTouch(e,"begin")
				end
			end)
			
		thisItem:addEventListener(Event.TOUCHES_MOVE,
			function(e) tv:listItemTouch(e,"move") end)
			
		thisItem:addEventListener(Event.TOUCHES_END,
			function(e) tv:listItemTouch(e,"end") end)

        return thisItem
end

function ListView:listItemTouch(e, act)	
	local li = self.listItems
	local top, height = self:getY(), self:getHeight()
	
	if(act == "begin") then
		delta, velocity, prevPos = 0, 0, 0
		self.isFocus = true		
		
		startPos = e.touch.y
		prevPos = e.touch.y

		if self.tween then 
			self.tween:setPaused(true)
			self.tween = nil
		end
		
		self:removeEventListener("enterFrame", self.scrollList, self) 
		self:addEventListener("enterFrame", self.trackVelocity, self)	
		
	elseif( self.isFocus ) then
		if(act == "move") then
			local lastItem = li:getChildAt(li:getNumChildren())
			delta = e.touch.y - prevPos
			prevPos = e.touch.y

			if (li:getChildAt(1).id == 1 and li:getY() > 0) or 
			(lastItem.id == #self.itemData and (self.listHeight - lastItem:getY()-lastItem:getHeight()) <= 0) then
				li:setY(math.floor(li:getY() + delta/3))
			else
				li:setY(math.floor(li:getY() + delta))
			end
			self:updateRender()     		
		end

		if(act == "end") then
			self:removeEventListener("enterFrame", self.trackVelocity, self)
			self:addEventListener("enterFrame", self.scrollList, self )
			self.isFocus = false
		end
	end
end

function ListView:scrollList(event)

	if math.abs(velocity) < 0.3 then
		velocity = 0
		self:removeEventListener("enterFrame", self.scrollList, self)
		
		-- experimental feature
		if self.cfg.rowSnap then
			local _me = self
			local lastItem = self.listItems:getChildAt(self.listItems:getNumChildren())
			local firstVisibleItem = self:getFirstVisibleRow()

			if(firstVisibleItem ~= nil and self.listItems:getY() < 0 and (self.listHeight - lastItem:getY()-lastItem:getHeight()) > 0) then
				local x, y = firstVisibleItem:getBounds(self)
				local vx, vy = self.listItems:localToGlobal(self.listItems:getBounds(self))
				local final = self.listItems:getY()
				if ((firstVisibleItem:getHeight()+y) >= firstVisibleItem:getHeight()/2) then
					final = self.listItems:getY() - y
				else
					final = self.listItems:getY() - (firstVisibleItem:getHeight()+y)
				end
				self.tween = GTween.new(self.listItems, 0.7, {y=final}, {delay = 0.01, ease = easing.outQuartic, onChange = function() self:updateRender() end})
			end
		else
			
		end
	end 

	local timePassed = event.deltaTime*300 
	local li = self.listItems

	-- Slow the list down
	velocity = velocity * self.cfg.friction
	li:setY(math.floor(self.listItems:getY() + velocity*timePassed))

	self:updateRender()
		
	local firstItem = li:getChildAt(1)
	local lastItem = li:getChildAt(li:getNumChildren())
	local lx,ly = self:localToGlobal(li:getBounds(self))
	local x, y, w, h = self:getBounds(self)
	local x2, y2 = self:localToGlobal(x, y)
	--local lx,ly = lastItem:getBounds(self)

	if firstItem.id == 1 and li:getY() > 0 then
		velocity = 0
		self:removeEventListener("enterFrame", self.scrollList, self)
		self.tween = GTween.new(li, 0.4, {y=li.yInit}, {delay = 0.01, ease = easing.outQuartic})	
	end	
	
	if lastItem.id == #self.itemData and (self.listHeight - lastItem:getY()-lastItem:getHeight()) <= 0 then
		if self.listHeight > self.viewSize and li:getY() < -self.listHeight+self.viewSize-lastItem:getHeight()*0.5 then
			velocity = 0
			self:removeEventListener("enterFrame", self.scrollList, self)
			self.tween = GTween.new(li, 0.4, {y=math.ceil(self.viewSize - self.listHeight)}, {delay = 0.01, ease = easing.outQuartic})
		elseif self.listHeight < self.viewSize then 
			velocity = 0
			self:removeEventListener("enterFrame", self.scrollList, self)
			self.tween = GTween.new(li, 0.4, {y=li.yInit}, {delay = 0.01, ease = easing.outQuartic})
		end
	end 
	return true
end

function ListView:getFirstVisibleRow()
	local index = 1
	local posY = self:getY()
	local item = nil
	
	while posY <= self:getY() do
		if(index < self.listItems:getNumChildren()) then
			item = self.listItems:getChildAt(index)
			local x1, y1 = self:localToGlobal(item:getBounds(self))
			posY = y1 + item:getHeight()
			index = index + 1
		else
			return nil
		end
	end
	return item
end

function ListView:createRender()
	local lastY = 0
	local position = 1
	while lastY < self.viewSize and position<=#self.itemData do
		local rowObject = self:render(nil, position)
		if (rowObject == nil) then break end
		self.listItems:addChild(rowObject)
		rowObject:setPosition(self.itemData[position].xInit, self.itemData[position].yInit)
		lastY = rowObject:getY()
		position = position + 1
	end
	self.listItems.yInit = self.listItems:getY()
end

function ListView:render(thisItem, id)
	if thisItem == nil then
	    thisItem = self:newListItem(id, self.itemData[id].objectData)
	else
		thisItem:removeChildAt(thisItem:getNumChildren())
		local callback = self.cfg.callback
		local t = callback(self.itemData[id].objectData)
		thisItem:addChild(t)
		thisItem.id = id
	end	
	return thisItem
end

function ListView:updateRender()
	local firstItem = self.listItems:getChildAt(1)	
	local lastItem = self.listItems:getChildAt(self.listItems:getNumChildren())
	local fx,fy = firstItem:getBounds(self)
	local lx,ly = lastItem:getBounds(self)
	local bottom = self.viewSize + self:getY()
	local fillToTop =  fy > 0
	local fillToBottom = ly + lastItem:getHeight() < self.viewSize

	if fillToBottom then
		if (ly + lastItem:getHeight() < self.viewSize) and (lastItem.id ~= #self.itemData) then
			local y = lastItem:getY() + lastItem:getHeight()
			local recycledRow = firstItem
			self:render(recycledRow, lastItem.id+1)
			self.listItems:addChild(recycledRow)
			recycledRow:setY(y)
		end	

	elseif fillToTop then
		if fy > 0 and (firstItem.id ~= 1) then
			local recycledRow = lastItem
			local newItem = self:render(recycledRow, firstItem.id-1)
			local y = firstItem:getY() - newItem:getHeight()
			self.listItems:addChildAt(recycledRow, 1)
			recycledRow:setY(y)
		end
	end

	if (self.cfg.onScroll ~= nil) then
		self.cfg.onScroll(self, firstItem)
	end
end

function ListView:trackVelocity(event) 	
	local timePassed = msTimer() - self.velocityPrevTime
	self.velocityPrevTime = self.velocityPrevTime + timePassed

	if prevY then 
		velocity = (self.listItems:getY() - prevY)/timePassed 
	end
	prevY = self.listItems:getY()
end

function msTimer()
	return math.floor(os.timer() * 1000)
end

return ListView