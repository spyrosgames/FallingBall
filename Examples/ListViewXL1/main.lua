--
--====================================================================--        
-- BASIC EXAMPLE OF TABLE VIEW LIBRARY EXTENDED
--====================================================================--
--
-- main.lua
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
-- 28-MARCH-2011 - Gilbert Guerrero - Prep for release
--
--====================================================================--
-- INFORMATION
--====================================================================--
--
-- Demonstrates how to create a list view using the new Table View 
-- Library "Extended".  This library differs from the old table view 
-- library because it virtualizes the list.  Only the number of items 
-- that need to be shown on screen plus one on top and one on the bottom 
-- are generated.  This significantly increases the performance, which 
-- is evident in how fast the list view scrolls.  This library is still 
-- in beta.  It does not support grouping items in categories with headings yet.  
-- A list view is a collection of content organized in rows that the user
-- can scroll up or down on touch. Tapping on each row can execute a 
-- custom function.
-- 

------------------------------------------------------------------------        
-- IMPORT EXTERNAL LIBRARIES
------------------------------------------------------------------------

local tableView = require("tableViewXL")
local ui = require("ui")

display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------------------------------------        
-- INITIAL VALUES
------------------------------------------------------------------------
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local myList, backBtn, detailScreenText

local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(77, 77, 77)

------------------------------------------------------------------------        
-- SETUP THE DETAIL SCREEN WHICH SHOWS AFTER AN ITEM IS TAPPED
------------------------------------------------------------------------

local detailScreen = display.newGroup()

local detailBg = display.newRect(0,0,display.contentWidth,display.contentHeight-display.screenOriginY)
detailBg:setFillColor(255,255,255)
--
detailScreen:insert(detailBg)

detailScreenText = display.newText("You tapped item", 0, 0, native.systemFontBold, 24)
detailScreenText:setTextColor(0, 0, 0)
--
detailScreen:insert(detailScreenText)
--
detailScreenText.x = math.floor(display.contentWidth/2)
detailScreenText.y = math.floor(display.contentHeight/2) 	

detailScreen.x = display.contentWidth

------------------------------------------------------------------------        
-- EXECUTES WHEN AN ITEM IS TAPPED
------------------------------------------------------------------------

function listButtonRelease( event )

	self = event.target
	local id = self.id
	print(self.id)
	
	detailScreenText.text = "You tapped item ".. self.id
			
	transition.to(myList, {time=400, x=display.contentWidth*-1, transition=easing.outExpo })
	transition.to(detailScreen, {time=400, x=0, transition=easing.outExpo })
	transition.to(backBtn, {time=400, x=math.floor(backBtn.width/2) + screenOffsetW*.5 + 6, transition=easing.outExpo })
	transition.to(backBtn, {time=400, alpha=1 })
	
	delta, velocity = 0, 0

end

------------------------------------------------------------------------        
-- EXECUTES WHEN BACK BUTTON IS TAPPED
------------------------------------------------------------------------

function backBtnRelease( event )
	
	print("back button released")
	transition.to(myList, {time=400, x=0, transition=easing.outExpo })
	transition.to(detailScreen, {time=400, x=display.contentWidth, transition=easing.outExpo })
	transition.to(backBtn, {time=400, x=math.floor(backBtn.width/2)+backBtn.width, transition=easing.outExpo })
	transition.to(backBtn, {time=400, alpha=0 })

	delta, velocity = 0, 0
	
end

------------------------------------------------------------------------        
-- SETUP SOME DATA TO SHOW IN THE LIST
------------------------------------------------------------------------

local data = {}

for i=1, 500 do

	data[i] = "List item ".. i

end

------------------------------------------------------------------------        
-- CREATE THE LIST VIEW
------------------------------------------------------------------------

local topBoundary = display.screenOriginY + 40
local bottomBoundary = display.screenOriginY + 0
--
myList = tableView.newList{
	data=data, 
	default="listItemBg.png",
	over="listItemBg_over.png",
	onRelease=listButtonRelease,
	top=topBoundary,
	bottom=bottomBoundary,
	backgroundColor={ 255, 255, 255 },
	callback=function(row) 
			local t = display.newText(row, 0, 0, native.systemFontBold, 16)
			t:setTextColor(0, 0, 0)
			t.x = math.floor(t.width/2) + 12
			t.y = 46 
			return t
		end
}

------------------------------------------------------------------------        
-- WHEN TOP NAV BAR IS TAPPPED, CAUSE THE LIST TO SCROLL BACK TO TOP
------------------------------------------------------------------------

local function scrollToTop()

	myList:scrollTo(topBoundary-1)

end

------------------------------------------------------------------------        
-- SETUP THE NAV BAR AT THE TOP OF THE SCREEN
------------------------------------------------------------------------

local navBar = ui.newButton{
	default = "navBar.png",
	onRelease = scrollToTop
}
--
navBar.x = display.contentWidth*.5
navBar.y = math.floor(display.screenOriginY + navBar.height*0.5)

local navHeader = display.newText("My List (".. #data .." items)", 0, 0, native.systemFontBold, 16)
navHeader:setTextColor(255, 255, 255)
--
navHeader.x = display.contentWidth*.5
navHeader.y = navBar.y

------------------------------------------------------------------------        
-- SETUP THE BACK BUTTON
------------------------------------------------------------------------

backBtn = ui.newButton{ 
	default = "backButton.png", 
	over = "backButton_over.png", 
	onRelease = backBtnRelease
}
--
backBtn.x = math.floor(backBtn.width/2) + backBtn.width + screenOffsetW
backBtn.y = navBar.y 
--
backBtn.alpha = 0
