module("TableViewXL", package.seeall)
--
--====================================================================--        
-- TABLE VIEW LIBRARY EXTENDED
--====================================================================--
--
-- tableViewXL.lua
-- Version 1.0
-- Created by: Gilbert Guerrero, UI Developer at Ansca Mobile
-- 
-- This library is free to use and modify.  Add it to your projects!
--
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
--====================================================================--        
-- CHANGES
--====================================================================--
--
-- 28-MARCH-2011 - Gilbert Guerrero - First public release
--
--====================================================================--
-- METHODS AND ARGUMENTS  Note: arguments in brackets [] are optional
--====================================================================--
--
------------------------------------------------------------------------         
-- .newList{ data, default[, over, onRelease, top, bottom, cat, order, callback] }
------------------------------------------------------------------------         
--
-- Creates a list view and returns it as an object
--
-- USAGE
--
-- local myList = tableView.newList{
--   data = {"item 1", "item 2", "item 3"}, 
--   default = "listItemBg.png",
--   over = "listItemBg_over.png",
--   onRelease = listButtonRelease,
--   top = 40,
--   bottom = 0,
--   backgroundColor = { 255, 255, 255 },
--   callback = function(row) 
--			local t = display.newText( row, 0, 0, native.systemFontBold, 16 )
--			t:setTextColor( 0, 0, 0 )
--			t.x = math.floor( t.width/2 ) + 12
--			t.y = 46 
--			return t
--		end
-- }

--
-- ARGUMENTS
--
-- data
-- A table containing elements that the list can iterate through to 
-- display in each row.
--
-- default
-- An image for the row background. Defines the hit area for the touch.
--
-- over
-- An image that will show on touch.
--
-- onRelease (optional)
-- A function name that defines the action to take after a row is tapped.
--
-- top
-- Distance from the top of the screen that the list should start and 
-- snap back to.
-- 
-- bottom
-- Distance from the bottom of the screen that the list should snap back 
-- to when scrolled upward.
-- 
-- cat
-- Specify the table key name used to store the category value for each item. 
-- Example: myData[1]["category"] = "Fruit" and myData[1]["text"] = "Banana". 
-- Requires using a multi-dimensional table where each row in the table 
-- stores different values for each item.
-- 
-- order
-- Optional modifier for cat that will allow you to specify an arbitrary 
-- order for headers. Specify order as a table containing the header names 
-- in the order you would like them to appear.
-- 
-- callback
-- A function that defines how to display the data in each row. Each element 
-- in the data table will be used in place of the argument ("item") assigned 
-- to the callback function.
-- 
------------------------------------------------------------------------         
-- myList:scrollTo( yVal[, timeVal] )  NOT REALLY READY YET!!!...
------------------------------------------------------------------------         
--
-- Allows you to move the list dynamically. It'll scroll right before 
-- the user's eyes. This is helpful if the user touches your nav bar 
-- at the top of the screen. Most apps will scroll a long list back to 
-- the top.
--
-- ARGUMENTS
--        
-- yVal 
-- Y value the list should scroll to.
-- 
-- timeVal 
-- Speed in miliseconds. Usually doesn't need to be adjusted.

------------------------------------------------------------------------        
-- myList:cleanUp()
------------------------------------------------------------------------         
--
-- Use this to destroy you list, clear it out of memory, and 
-- stop all event listeners.
--
--====================================================================--
-- INFORMATION
--====================================================================--
-- The table view library was created to allow for easy creation of 
-- list views.  A list view has a series of rows of text and images.  
-- The rows scroll up and down on touch.  When a row item is tapped 
-- a custom function can execute.  This table view was rewritten and 
-- called "extended" for this release.  It is significantly faster and
-- performs well with thousands of items.  This is due to the fact that
-- rows are generated on the fly, or virtualized, instead of being
-- generated all at once.  
 
------------------------------------------------------------------------        
-- PROPERTIES
------------------------------------------------------------------------

local screenW, screenH 
local viewableScreenW, viewableScreenH 
local screenOffsetW, screenOffsetH 

local currentTarget, detailScreen, velocity, currentDefault, currentOver, prevY, enableSelected, lastDefault, lastOver
local startTime, lastTime, prevTime = 0, 0, 0
 
------------------------------------------------------------------------        
-- SHOW HIGHLIGHT WHEN ITEM IS TOUCHED
------------------------------------------------------------------------
 
function showHighlight(event)

    local timePassed = system.getTimer() - startTime
 
    if timePassed > 100 then 
        print("highlight")

        if( lastDefault and lastOver ) then
			lastDefault.isVisible = true
        	lastOver.isVisible = false
		end
		
        currentDefault.isVisible = false
        currentOver.isVisible = true
		--
		lastDefault = currentDefault
		lastOver = currentOver
		--
        Runtime:removeEventListener( "enterFrame", showHighlight )
    end
end

------------------------------------------------------------------------        
-- RENDER EACH LIST ITEM IF IT DOESN'T EXIST OR RE-RENDER IT
------------------------------------------------------------------------

function render(thisItem, data, id)
	
	if thisItem == nil then
		
		print("Creating new row objects")
	
	    thisItem = newListItem{
	        data = data.objectData,
	        default = currentTarget.renderParams.default,
	        over = currentTarget.renderParams.over,
	        onRelease = currentTarget.renderParams.onRelease,
	        top = currentTarget.renderParams.top,
	        bottom = currentTarget.renderParams.bottom,
	        backgroundColor = currentTarget.renderParams.backgroundColor,
	        callback = currentTarget.renderParams.callback,
	        id = id,
	    }
	   
	else
		 		
		thisItem:remove(thisItem.numChildren)
		local callback = currentTarget.renderParams.callback
		local t = callback(data.objectData)
		thisItem:insert(t)    
				
		thisItem.id = id
	
	end

	print("rendering item: ".. id)
	
--[[ 
		--### headers
		local g = display.newGroup()
		local b
		if categoryBackground then 
			b = display.newImage(categoryBackground, true)
		else
			b = display.newRect(0, 0, screenW, textSize*1.5)
			b:setFillColor(0, 0, 0, 100)
		end
		g:insert( b )
	
		local labelShadow = display.newText( h, 0, 0, native.systemFontBold, textSize )
		labelShadow:setTextColor( 0, 0, 0, 128 )
		g:insert( labelShadow, true )
		labelShadow.x = labelShadow.width*.5 + 1 + offset + screenOffsetW*.5
		labelShadow.y = textSize*.8 + 1
	
		local t = display.newText(h, 0, 0, native.systemFontBold, textSize)
	    t:setTextColor(255, 255, 255)
	    g:insert( t )
	    t.x = t.width*.5 + offset + screenOffsetW*.5
	    t.y = textSize*.8   
	    
	    listView:insert( g )
	    g.x = 0
	    g.y = prevY + prevH     
	    prevY = g.y
	    prevH = g.height
	    table.insert(c, g)           
	    c[#c].yInit = g.y     
--]] 

	return thisItem
end

------------------------------------------------------------------------        
-- START THE RENDERING OF A GIVEN NUMBER OF LIST ITEMS
------------------------------------------------------------------------

function createRender()

	local itemIndex = 1

	while itemIndex <= currentTarget.numRender do
		
		local displayObject = render(nil, currentTarget.itemData[itemIndex], itemIndex)
		
		currentTarget.listItems:insert(displayObject)
	    displayObject.x = currentTarget.itemData[itemIndex].xInit
	    displayObject.y = currentTarget.itemData[itemIndex].yInit
		
		itemIndex = itemIndex + 1

	end 
	
	currentTarget.listItems.yInit = currentTarget.listItems.y

end

------------------------------------------------------------------------        
-- AS THE LIST MOVES UPDATE RENDERING
------------------------------------------------------------------------

function updateRender(event)

	-- Location of the bottom of the list
	local bottom = currentTarget.viewSize - currentTarget.listItems.y
	--
	local fillToTop = currentTarget.listItems[1].y > currentTarget.listItems.y*-1  
	local fillToBottom = currentTarget.listItems[currentTarget.numRender-1].y + currentTarget.rowSize < bottom
	
    -----------------------------------
    -- Fill in items from the bottom
	-- as the list scrolls up
    -----------------------------------

	if fillToBottom then
		
		while (currentTarget.listItems[currentTarget.numRender-1].y + currentTarget.rowSize < bottom) and (currentTarget.listItems[currentTarget.numRender].id ~= #currentTarget.itemData) do
		
			local y = currentTarget.listItems[currentTarget.numRender].y + currentTarget.rowSize
			
			local displayObject = currentTarget.listItems[1]
			--
			render(displayObject, currentTarget.itemData[y/currentTarget.rowSize + 1], y/currentTarget.rowSize + 1)
			currentTarget.listItems:insert(displayObject)
			--
			displayObject.y = y
			
		end

    -----------------------------------
    -- Fill in items from the top
	-- as the list scrolls down
    -----------------------------------

	elseif fillToTop then

		while (currentTarget.listItems[1].y > currentTarget.listItems.y*-1) and (currentTarget.listItems[1].id ~= 1) do
			
			local y = currentTarget.listItems[1].y - currentTarget.rowSize
			
			local displayObject = currentTarget.listItems[currentTarget.numRender]
			--
			render(displayObject, currentTarget.itemData[y/currentTarget.rowSize + 1], y/currentTarget.rowSize + 1)
			currentTarget.listItems:insert(1, displayObject)
			--
			displayObject.y = y
			
		end

    -----------------------------------
    -- redraw all, jumped in list?
    -----------------------------------

	elseif fillToBottom and fillToTop then
		
--		print("error - fill to both?")

	end

end 

------------------------------------------------------------------------        
-- EVENT HANDLER ATTACHED TO EACH LIST ITEM
------------------------------------------------------------------------
  
function newListItemHandler(self, event) 
	
        local t = currentTarget.listItems --could use self.target.parent possibly
        local phase = event.phase
        print("touch: ".. phase)
		 
        local default = self.default
        local over = self.over
        local top = self.top
        local bottom = self.bottom
        --local upperLimit, bottomLimit = top, screenH - currentTarget.height - bottom

		local result = true        
        
        if( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the stageBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

            startPos = event.y
            prevPos = event.y                                       
            delta, velocity = 0, 0
            if currentTarget.tween then transition.cancel(currentTarget.tween) end

            Runtime:removeEventListener("enterFrame", scrollList ) 
            Runtime:addEventListener("enterFrame", moveCat)

			-- Start tracking velocity
			Runtime:addEventListener("enterFrame", trackVelocity)
 
            if over then            
    			currentDefault = default
                currentOver = over
                startTime = system.getTimer()
                Runtime:addEventListener( "enterFrame", showHighlight )
            end
             
        elseif( self.isFocus ) then
 
            if( phase == "moved" ) then     
  
                Runtime:removeEventListener( "enterFrame", showHighlight )
                if over and not enableSelected then 
                    default.isVisible = true
                    over.isVisible = false
                end
  
                delta = event.y - prevPos
                prevPos = event.y
				
                
                if (t[1].id == 1 and t.y > top) or (t[currentTarget.numRender].id == #currentTarget.itemData  and t.y < bottom) then
					--make the list resist being pulled too far beyond edges
        	        t.y  = t.y + delta/2               
                else
                     t.y = t.y + delta       
                end            

				updateRender()                    

            elseif( phase == "ended" or phase == "cancelled" ) then 

				lastTime = event.time
 
                local dragDistance = event.y - startPos
                --velocity = delta 
				Runtime:removeEventListener("enterFrame", moveCat)
	 			Runtime:removeEventListener("enterFrame", trackVelocity)
                Runtime:addEventListener("enterFrame", scrollList )             

                local bounds = self.stageBounds
                local x, y = event.x, event.y
                local isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
        
                -- Only consider this a "click", if the user lifts their finger inside button's stageBounds
                if isWithinBounds and (dragDistance < 10 and dragDistance > -10 ) then
					
	                if( (lastDefault and lastOver) and (lastDefault ~= default and lastOver ~= over) ) then
	                    default.isVisible = false
	                    over.isVisible = true
						lastDefault.isVisible = true
	                	lastOver.isVisible = false
						lastDefault = default
						lastOver = over					
					end

                    result = self.onRelease(event)
                end
  
                if over and not enableSelected then 
                    default.isVisible = true
                    over.isVisible = false
                end 
                Runtime:removeEventListener( "enterFrame", showHighlight )

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
 
           end
        end
        
        return result
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
        local bottom = params.bottom
        local backgroundColor = params.backgroundColor
        local callback = params.callback 
        local id = params.id
 
        local thisItem = display.newGroup()
 
        if params.default then
                default = display.newImage( params.default )
                thisItem:insert( default )
                default.x = default.width*.5 - screenOffsetW
                thisItem.default  = default
        end
        
        if params.over then
                over = display.newImage( params.over )
                over.isVisible = false
                thisItem:insert( over )
                over.x = over.width*.5 - screenOffsetW
                thisItem.over = over 
        end
 
        thisItem.id = id
        --thisItem.data = data
        thisItem.onRelease = onRelease          
        thisItem.top = top
        thisItem.bottom = bottom
 
        local t = callback(data)
        thisItem:insert( t )
 
        thisItem.touch = newListItemHandler
        thisItem:addEventListener( "touch", thisItem )

        if backgroundColor then 
        	local bgColor = display.newRect(0, 0, thisItem.width, thisItem.height)
        	bgColor:setFillColor(backgroundColor[1], backgroundColor[2], backgroundColor[3])
	        bgColor.width = thisItem.width
	        bgColor.height = thisItem.height
	        bgColor.y = bgColor.height*.5
        	thisItem:insert(1, bgColor)
	    end	    
        
        return thisItem
end

------------------------------------------------------------------------        
-- SETUP THE LIST VIEW.
------------------------------------------------------------------------
 
function newList(params) 
	screenW, screenH = display.contentWidth, display.contentHeight
	viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
	screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

        local listView = display.newGroup()

		local textSize = 16
        local data = params.data
        local default = params.default
        local over = params.over
        local onRelease = params.onRelease
        local top = params.top or 20
        local bottom = params.bottom or 48
        local cat = params.cat
        local order = params.order or {}
        local categoryBackground = params.categoryBackground
        local backgroundColor = params.backgroundColor
        local callback = params.callback or function(item)
	                                            local t = display.newText(item, 0, 0, native.systemFontBold, textSize)
	                                            t:setTextColor(255, 255, 255)
	                                            t.x = math.floor(t.width/2) + 20
	                                            t.y = 24 
	                                            return t
			            					end
	 	local headerSize = 24 --REPLACE FIXED NUMBER WITH PARAM FOR HEADER SIZE!
	 	local rowSize = 93 --REPLACE FIXED NUMBER WITH PARAM FOR HEADER SIZE!
	 	
        local prevY, prevH = 0, 0
        
        if cat then         
			local catTable = {}
    
        	--get the implicit categories
        	local prevCat = 0
        	for i=1, #data do
        		if data[i][cat] ~= prevCat then
        			table.insert(catTable, data[i][cat])
        			prevCat = data[i][cat]
        			print(prevCat)
        		end
        	end
        	
	       	--sort the data arbitrarily
        	if order then	 
        		--add any categories not specified to the user order of categories
        		for i=1, #catTable do
		        	if not in_table(catTable[i], order) then
	        			table.insert(order, catTable[i])
		        	end
		        end
		    else 
				order = catTable
        	end        	

        end      
                
		local finalData = {}

        local j = 1
        local k = 0
        local c = {}
        local offset = 12
        while true do
        	--local h = data[j][cat]
        	local h = order[j]
        	
        	if h then

        		k = k + 1
        		finalData[k] = {}
        		finalData[k].objectData = h
        		finalData[k].typeData = "header"
				finalData[k].xInit = 0
        		finalData[k].yInit = prevY + headerSize
        		
        		c[#c].yInit = finalData[k].yInit
        		
        		prevY = finalData[k].yInit
        		prevH = headerSize

	        end
        	        	
	        --iterate over the data and add items to the list view
	        for i=1, #data do
	        	if data[i][cat] == h then
	        		
	        		k = k + 1
	        		finalData[k] = {}
	        		finalData[k].objectData = data[i]
	        		finalData[k].typeData = "data"
	        		finalData[k].xInit = 0 + screenOffsetW*.5
	        		finalData[k].yInit = prevY + prevH

	        		prevY = finalData[k].yInit
	        		prevH = rowSize
	        		
	            end --if	            
	        end --for
	        	        
	    	j = j + 1
	    	
	    	if not order[j] then break end		                        	
        end --while
        
        --clear out the data table
        data = nil
        
        local listItems = display.newGroup()
        listView:insert(listItems)       
        
        listView.y = top
        listView.top = top
        listView.bottom = bottom
        listView.rowSize = rowSize
        listView.c = c
        listView.listItems = listItems
		--
		local viewSize = viewableScreenH - top - bottom
		listView.viewSize = viewSize
		--
        listView.numRender = math.ceil(viewSize/rowSize) + 2
		if listView.numRender > #finalData then listView.numRender = #finalData end
		--
        listView.itemData = finalData
		--
        --clear out the finalData table
        finalData = nil
        --
		listView.renderParams = {
	        default = default,
	        over = over,
	        onRelease = onRelease,
	        top = top,
	        bottom = bottom,
			backgroundColor = backgroundColor,
	        callback = callback,
	    }
        
        currentTarget = listView

		createRender()


        ---------------------------------------
        -- Allow items to stay seleceted
        ---------------------------------------

		function listView:scrollTo(yVal, timeVal)
		          local timeVal = timeVal or 400
		          local yVal = yVal or 0

		          self.yVal = yVal     

		          lastTime = system.getTimer()
				  velocity = 100
				
		          Runtime:addEventListener("enterFrame", scrollList)
		end

        ---------------------------------------
        -- Allow items to stay seleceted
        ---------------------------------------

		function listView:enableSelected()
			enableSelected = true
		end

        ---------------------------------------
        -- Clean up function
        ---------------------------------------

		function listView:cleanUp()
			print("tableView cleanUp")
			local i
			for i = listView.numChildren, 1, -1 do
				--test
				listView[i]:removeEventListener("touch", newListItemHandler)
				listView:remove(i)
				listView[i] = nil
			end
		end	
        
        return listView
end

------------------------------------------------------------------------        
-- SCROLL THE LIST UP OR DOWN.
------------------------------------------------------------------------

function scrollList(event)   
	
        --turn off scrolling if velocity is near zero
        if math.abs(velocity) < .01 then
                velocity = 0
                Runtime:removeEventListener("enterFrame", scrollList )
        end 
      
		-- Set the amount of friction to slow down the list as it moves
		local friction = 0.9
		--
		-- Calculate the amount of time passed since last frame
		local timePassed = event.time - lastTime
		lastTime = lastTime + timePassed       
		--
        -- Slow the list down as it moves using friction
		velocity = velocity*friction
        
		-- Update the y value of the list, i.e. move it up or down, based on velocity and time passed
        currentTarget.listItems.y = math.floor(currentTarget.listItems.y + velocity*timePassed)
        
        -- Move the categories as the list moves
		moveCat()
		
		-- Update the items on the screen as the list moves
		updateRender()                    
       
		-----------------------------------
	    -- Check the boundries of the list.
	    -----------------------------------
	    --
		local firstItem = currentTarget.listItems[1]
		local lastItem = currentTarget.listItems[currentTarget.numRender]
        --local upperLimit = currentTarget.top 
        --local bottomLimit = screenH - currentTarget.height - currentTarget.bottom
		--
	    -- If the first item in the list is at the top and moves down, stop scrolling and snap back.
        if firstItem.id == 1 and currentTarget.listItems.y > currentTarget.top then
	
                velocity = 0
				--
                Runtime:removeEventListener("enterFrame", scrollList )          
                Runtime:addEventListener("enterFrame", moveCat )  
				--        
                currentTarget.tween = transition.to(currentTarget.listItems, { time=400, y=currentTarget.listItems.yInit, transition=easing.outQuad})
		end
		
		if lastItem.id == #currentTarget.itemData and currentTarget.listItems.y < 0 then
		
			if currentTarget.rowSize*#currentTarget.itemData > currentTarget.viewSize and currentTarget.listItems.y < -currentTarget.rowSize*(#currentTarget.itemData)+currentTarget.viewSize-currentTarget.rowSize*0.5 then 	
						
				velocity = 0
				--
				Runtime:removeEventListener("enterFrame", scrollList )          
				Runtime:addEventListener("enterFrame", moveCat )
				--          
				currentTarget.tween = transition.to(currentTarget.listItems, { 
											time=400, 
											y=math.ceil( currentTarget.viewSize - (currentTarget.rowSize * #currentTarget.itemData) ),
											transition=easing.outQuad
										})

        	elseif currentTarget.rowSize*#currentTarget.itemData < currentTarget.viewSize then 

				velocity = 0
				--
				Runtime:removeEventListener("enterFrame", scrollList )          
				Runtime:addEventListener("enterFrame", moveCat )          
				--
				currentTarget.tween = transition.to(currentTarget.listItems, { time=400, y=currentTarget.listItems.yInit, transition=easing.outQuad})        
			
			end
			
        end 
                 
        return true
end

------------------------------------------------------------------------        
-- MOVE THE CATEGORY HEADERS WITH THE LIST.
------------------------------------------------------------------------

function moveCat()
	
        local upperLimit = currentTarget.top 

		for i=1, #currentTarget.c do
			if( currentTarget.y > upperLimit - currentTarget.c[i].yInit ) then
				currentTarget.c[i].y = currentTarget.c[i].yInit 
			end
			
			if ( currentTarget.y < upperLimit - currentTarget.c[i].yInit ) then
				currentTarget.c[i].y = upperLimit - currentTarget.y
			end
	
			if( i > 1 ) then
				if ( currentTarget.c[i].y < currentTarget.c[i-1].y + currentTarget.c[i].height ) then
					currentTarget.c[i-1].y = currentTarget.c[i].y - currentTarget.c[i].height
				end
			end
		end
		
		return true
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

------------------------------------------------------------------------        
-- LOOK FOR AN ITEM IN A TABLE UTILITY FUNCTION.
------------------------------------------------------------------------

function in_table ( e, t )
	
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end