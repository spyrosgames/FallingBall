module(..., package.seeall)
--
--====================================================================--
-- TABLE VIEW LIBRARY
--====================================================================--
--
-- tableView.lua
-- Version 1.8.1
-- Created by: Gilbert Guerrero, UI Developer at Ansca Mobile
-- 
-- This library is free to use and modify.  Add it to your projects!
--
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
--====================================================================--
--====================================================================--        
-- CHANGES
--====================================================================--
--
-- 28-MARCH-2011 - Gilbert Guerrero - Added scroll bar
-- 30-MARCH-2011 - Gilbert Guerrero - Fixed scroll bar bugs which prevented fading
--									- Added support for wide Android screens
--									- Scroll bar now moves with the list while user is touching screen
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
-- myList:addScrollBar( [r, g, b, a ])
------------------------------------------------------------------------         
--
-- Allows you to add a scrollbar to the right hand side of your list view.
-- Fades after a few seconds and reappears and fades again after touch.
--
-- ARGUMENTS
--        
-- r, g, b, a  
-- RGB and Alpha values for the color and opacity of the scroll bar.
-- All are optional.  Places light grey bar by default.
--
------------------------------------------------------------------------         
-- myList:scrollTo( yVal[, timeVal] )  
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

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local currentTarget, detailScreen, velocity, currentDefault, currentOver, prevY
local startTime, lastTime, prevTime = 0, 0, 0  
 

------------------------------------------------------------------------        
-- SETUP THE LIST VIEW.
------------------------------------------------------------------------

function newList(params) 
    local listView = display.newGroup()
    local prevY, prevH = 0, 0

	------------------------------------------------------------------------        
	-- PUBLIC METHODS
	------------------------------------------------------------------------

	--   object:addOnTop(object, xVal, yVal) 
	--   object:addOnBottom(object, xVal, yVal)
	--   object:scrollTo(yVal, timeVal)
	--   object:addScrollBar(r,g,b,a)
	--   object:cleanUp()	

	-----------------------------------      
	-- APPEND AN OBJECT TO TOP OF LIST
	-----------------------------------

	function listView:addOnTop(object, xVal, yVal)
		
		for i=1,self.numChildren do
			self[i].y = self[i].y + object.height
		end	
		self:insert(object)
		--
		object.x = xVal or 0
		object.y = yVal or 0
		
	end

	-----------------------------------      
	-- APPEND AN OBJECT TO BOTTOM
	-----------------------------------

	function listView:addOnBottom(object, xVal, yVal)
		
		self:insert(object)
		--
		object.x = xVal or 0
		object.y = yVal or self[self.numChildren].y + self[self.numChildren].height

	end

	-----------------------------------      
	-- DYNAMICALLY SCROLL THE LIST
	-----------------------------------

	function listView:scrollTo(yVal, timeVal)
		
	          local timeVal = timeVal or 400
	          local yVal = yVal or 0

	          self.yVal = yVal

	          Runtime:removeEventListener("enterFrame", scrollList )          
	          --Runtime:addEventListener("enterFrame", moveCat )          

	          lastTime = system.getTimer()
	          Runtime:addEventListener("enterFrame", onScrollTo )          
	          --self.tween = transition.to(self, { time=timeVal, y=yVal, transition=easing.outQuad})
							
	end
	
	-----------------------------------      
	-- ADD A SCROLLBAR
	-----------------------------------
	function listView:addScrollBar(r,g,b,a)

		if self.scrollBar then self.scrollBar:removeSelf() end

		local scrollColorR = r or 0
		local scrollColorG = g or 0
		local scrollColorB = b or 0
		local scrollColorA = a or 120
						
		local viewPortH = screenH - self.top - self.bottom 
		local scrollH = viewPortH*self.height/(self.height*2 - viewPortH)		
		local scrollBar = display.newRoundedRect(display.screenOriginX + display.viewableContentWidth - 8 ,0,5,scrollH,2)
		scrollBar:setFillColor(scrollColorR, scrollColorG, scrollColorB, scrollColorA)

		print(display.screenOriginX)
		print(display.contentWidth)
		print(display.viewableContentWidth)
		local yRatio = scrollH/self.height
		self.yRatio = yRatio	

		if sbY then

			scrollBar.y = sbY
			sbY = nil

		else
			
			scrollBar.y = scrollBar.height*0.5 + self.top + 5

		end

		self.scrollBar = scrollBar

		transition.to(scrollBar,  { time=400, alpha=0 } )		
			
	end

	-----------------------------------      
	-- REMOVE THE SCROLLBAR
	-----------------------------------

	function listView:removeScrollBar()
		if self.scrollBar then 
			sbY = self.scrollBar.y
			self.scrollBar:removeSelf() 
			self.scrollBar = nil
		end
	end
	
	function listView:cleanUp()
		print("tableView cleanUp")
		Runtime:removeEventListener("enterFrame", moveCat )
		Runtime:removeEventListener("enterFrame", scrollList )
	          Runtime:removeEventListener( "enterFrame", showHighlight )
			Runtime:removeEventListener("enterFrame", trackVelocity)
		local i
		for i = listView.numChildren, 1, -1 do
			--test
			listView[i]:removeEventListener("touch", newListItemHandler)
			listView:remove(i)
			listView[i] = nil
		end
		listView:removeScrollBar()
	end	

	local textSize = 16
	local data = params.data
	local default = params.default
	local over = params.over
	local onPress = params.onPress
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

	if cat then         
		local catTable = {}

		--get the implicit categories
		local prevCat = 0
		for i=1, #data do
			if data[i][cat] ~= prevCat then
				table.insert(catTable, data[i][cat])
				prevCat = data[i][cat]
			end
		end --for

		if order then	 
			--clean up the user provided order table by removing any empty categories
			local n = 1
			while n < #order do
	  			if not in_table(order[n], catTable) then
	 				table.remove(order, n)
	  			else 
	 				n = n + 1
	  			end
	  		end

			--add any categories not specified to the user order of categories
			for i=1, #catTable do
	  			if not in_table(catTable[i], order) then
	 				table.insert(order, catTable[i])
			  	end
			end  --for
		else 
			order = catTable
		end --if        	
	end --if     
        
	local j = 1
	local c = {}
	local offset = 12
	while true do
		local h = order[j]
	
		if h then
			local g = display.newGroup()
			local b
			if categoryBackground then 
				b = display.newImage(categoryBackground, true)
			else
	 			b = display.newRect(0, 0, screenW, textSize*1.5)
	 			b:setFillColor(0, 0, 0, 100)
			end
			--Allow user to move list by touching categories
	        b.touch = newListItemHandler
	        b:addEventListener( "touch", b )         
	        b.top = top
	        b.bottom = bottom

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
	 	end

	    local firstItem = true
	    local lastItem = false             	
	 	local defaultVal = default
	 	local overVal = over
	        	
	 	--iterate over the data and add items to the list view
	 	for i=1, #data do
	 		if data[i][cat] == h then
 	
	 			if i == #data then
		 			lastItem = true
		 		elseif (h ~= "" and data[i+1][cat] ~= h) then
		 			lastItem = true
		 		end
				
				--Place different first and last row images, if they exist
				--Doesn't work on Android, because warning messages crash the app
		 		if system.getInfo("platformName") ~= "Android" then 
					local firstImg = system.pathForFile( string.gsub(default, ".png", "_first.png"), system.ResourceDirectory )
					local lastImg = system.pathForFile( string.gsub(default, ".png", "_last.png"), system.ResourceDirectory )

					if firstItem and firstImg then
						defaultVal = string.gsub(default, ".png", "_first.png")
						firstItem = false
		 			elseif lastItem and lastImg then
							defaultVal = string.gsub(default, ".png", "_last.png")
		 			else
		 				defaultVal = default
		 			end --if
				end
 			        		  
				local thisItem = newListItem{
		            data = data[i],
		            default = defaultVal,
		            over = overVal,
					onPress = onPress,
		            onRelease = onRelease,
		            top = top,
		            bottom = bottom,
		            callback = callback,
		            id = i
		         }
         
		         listView:insert( 1, thisItem )     

		         thisItem.x = 0 + screenOffsetW*.5
		         thisItem.y = prevY + prevH

		         --save the Y and height 
		         prevY = thisItem.y
		         prevH = thisItem.height
			end --if
		end --for
 	        
		j = j + 1

		if not order[j] then break end		                        	
	end --while

	if backgroundColor then 
		local bgColor = display.newRect(0, 0, screenW, screenH)
		bgColor:setFillColor(backgroundColor[1], backgroundColor[2], backgroundColor[3])
	 	bgColor.width = listView.width
	 	bgColor.height = listView.height
	 	bgColor.y = bgColor.height*.5
		listView:insert(1, bgColor)
	end
        
	listView.y = top
	listView.top = top
	listView.bottom = bottom
	listView.c = c

	currentTarget = listView
  
	return listView
end

------------------------------------------------------------------------        
-- EVENT HANDLER FOR EACH LIST ITEM
------------------------------------------------------------------------

function newListItemHandler(self, event) 

	local t = currentTarget --could use self.target.parent possibly
	local phase = event.phase
	print("touch: ".. phase)

	local default = self.default
	local over = self.over
	local top = self.top
	local bottom = self.bottom
	local upperLimit, bottomLimit = top, screenH - currentTarget.height - bottom

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

		transition.to(currentTarget.scrollBar,  { time=200, alpha=1 } )									

        if over then
            currentDefault = default
            currentOver = over
            startTime = system.getTimer()
            Runtime:addEventListener( "enterFrame", showHighlight )
        end

		if self.onPress then
			result = self.onPress( event )
		end
             
		elseif( self.isFocus ) then

			if( phase == "moved" ) then     

			    Runtime:removeEventListener( "enterFrame", showHighlight )
			    if over then 
			        default.isVisible = true
			        over.isVisible = false
			    end

			    delta = event.y - prevPos
			    prevPos = event.y
			    if ( t.y > upperLimit or t.y < bottomLimit ) then 
			        t.y  = t.y + delta/2
			    else
			        t.y = t.y + delta       
			    end

                moveScrollBar()
       
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
					velocity = 0
	                result = self.onRelease(event)
	             end

	             -- Allow touch events to be sent normally to the objects they "hit"
	             display.getCurrentStage():setFocus( nil )
	             self.isFocus = false

	             if over then 
	                 default.isVisible = true
	                 over.isVisible = false
	                 Runtime:removeEventListener( "enterFrame", showHighlight )
	             end 
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
		local onPress = params.onPress
        local onRelease = params.onRelease
        local top = params.top
        local bottom = params.bottom
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
        thisItem.data = data
		thisItem.onPress = onPress
        thisItem.onRelease = onRelease          
        thisItem.top = top
        thisItem.bottom = bottom
 
        local t = callback(data)
        thisItem:insert( t )
 
        thisItem.touch = newListItemHandler
        thisItem:addEventListener( "touch", thisItem )
        
        return thisItem
end

------------------------------------------------------------------------        
-- INTERNAL FUNCTION TO MOVE LIST ACTIVATED BY scrollTo() ABOVE
------------------------------------------------------------------------

function onScrollTo(event)

	local timePassed = event.time - lastTime
	lastTime = lastTime + timePassed  
	
    velocity = 2
	if currentTarget.y <= currentTarget.yVal then
		currentTarget.y = math.floor(currentTarget.y + velocity*timePassed)  
		moveCat()   
	else 
        currentTarget.y = currentTarget.yVal
        Runtime:removeEventListener("enterFrame", onScrollTo )  
		moveCat()        
	end
	
end
 
------------------------------------------------------------------------        
-- SCROLLS THE LIST ON ENTER FRAME
------------------------------------------------------------------------

function scrollList(event)   

		local friction = 0.9
		local timePassed = event.time - lastTime
		lastTime = lastTime + timePassed       

        --turn off scrolling if velocity is near zero
        if math.abs(velocity) < .01 then
                velocity = 0
                Runtime:removeEventListener("enterFrame", scrollList )

				transition.to(currentTarget.scrollBar,  { time=400, alpha=0 } )									
        end       

        velocity = velocity*friction
        
        currentTarget.y = math.floor(currentTarget.y + velocity*timePassed)
        
        moveCat()
        moveScrollBar()

        local upperLimit = currentTarget.top 
        local bottomLimit = screenH - currentTarget.height - currentTarget.bottom
        
        if ( currentTarget.y > upperLimit ) then

                velocity = 0
                Runtime:removeEventListener("enterFrame", scrollList )          
                Runtime:addEventListener("enterFrame", moveCat )          
                currentTarget.tween = transition.to(currentTarget, { time=400, y=upperLimit, transition=easing.outQuad, onComplete=function() currentTarget.y=upperLimit end})
 
				transition.to(currentTarget.scrollBar,  { time=400, alpha=0 } )									

       elseif ( currentTarget.y < bottomLimit and bottomLimit < 0 ) then 

                velocity = 0
                Runtime:removeEventListener("enterFrame", scrollList )          
                Runtime:addEventListener("enterFrame", moveCat )          
                currentTarget.tween = transition.to(currentTarget, { time=400, y=bottomLimit, transition=easing.outQuad, onComplete=function() currentTarget.y=bottomLimit end})

				transition.to(currentTarget.scrollBar,  { time=400, alpha=0 } )									

        elseif ( currentTarget.y < bottomLimit ) then 

                velocity = 0
                Runtime:removeEventListener("enterFrame", scrollList )          
                Runtime:addEventListener("enterFrame", moveCat )          
                currentTarget.tween = transition.to(currentTarget, { time=400, y=upperLimit, transition=easing.outQuad, onComplete=function() currentTarget.y=upperLimit end})        

				transition.to(currentTarget.scrollBar,  { time=400, alpha=0 } )									

        end 
                 
        return true
end

------------------------------------------------------------------------        
-- MOVES THE SCROLL BAR ON ENTER FRAME
------------------------------------------------------------------------

function moveScrollBar()
	
	if currentTarget.scrollBar then						
		local scrollBar = currentTarget.scrollBar
		
		scrollBar.y = -currentTarget.y*currentTarget.yRatio + scrollBar.height*0.5 + currentTarget.top
		
		if scrollBar.y <  5 + currentTarget.top + scrollBar.height*0.5 then
			scrollBar.y = 5 + currentTarget.top + scrollBar.height*0.5
		end
		if scrollBar.y > screenH - currentTarget.bottom  - 5 - scrollBar.height*0.5 then
			scrollBar.y = screenH - currentTarget.bottom - 5 - scrollBar.height*0.5
		end
		
	end
	
end

------------------------------------------------------------------------        
-- MOVES THE CATEGORY HEADERS WITH THE LIST VIEW
------------------------------------------------------------------------

function moveCat()

	if currentTarget.y then
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

end

------------------------------------------------------------------------        
-- TRACKS VELOCITY OF THE TOUCH
------------------------------------------------------------------------

function trackVelocity(event) 
		
	local timePassed = event.time - prevTime
	prevTime = prevTime + timePassed

	if prevY then 
		velocity = (currentTarget.y - prevY)/timePassed 
	end
	prevY = currentTarget.y

end			

------------------------------------------------------------------------        
-- HIGHLIGHT TOUCH LIST ITEM IF HELD FOR .1 MILLISECONDS
------------------------------------------------------------------------

function showHighlight(event)

    local timePassed = system.getTimer() - startTime
 
    if timePassed > 100 then 
        print("highlight")
        currentDefault.isVisible = false
        currentOver.isVisible = true
        Runtime:removeEventListener( "enterFrame", showHighlight )
    end

end

------------------------------------------------------------------------        
-- LOOK FOR AN ITEM IN A TABLE
------------------------------------------------------------------------

function in_table ( e, t )

	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false

end
