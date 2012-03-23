-- 
-- Abstract: List View sample app (showing a background image)
--  
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Demonstrates how to create a list view using the Table View Library.
-- This example shows the list with a transparent background, 
-- allowing an image beneath to show through.

--import the table view library
local tableView = require("tableView")

--import the button events library
local ui = require("ui")

display.setStatusBar( display.HiddenStatusBar ) 

--initial values
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local myList, backBtn, detailScreenText

local background = display.newImage("bg.png", true)

--setup a destination for the list items
local detailScreen = display.newGroup()

detailScreenText = display.newText("You tapped item", 0, 0, native.systemFontBold, 24)
detailScreenText:setTextColor(255, 255, 255)
detailScreen:insert(detailScreenText)
detailScreenText.x = math.floor(display.contentWidth/2)
detailScreenText.y = math.floor(display.contentHeight/2) 	
detailScreen.x = display.contentWidth

--setup functions to execute on touch of the list view items
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

function backBtnRelease( event )
	print("back button released")
	transition.to(myList, {time=400, x=0, transition=easing.outExpo })
	transition.to(detailScreen, {time=400, x=display.contentWidth, transition=easing.outExpo })
	transition.to(backBtn, {time=400, x=math.floor(backBtn.width/2)+backBtn.width, transition=easing.outExpo })
	transition.to(backBtn, {time=400, alpha=0 })

	delta, velocity = 0, 0
end

local topBoundary = display.screenOriginY + 40
local bottomBoundary = display.screenOriginY + 0

-- setup the data
local data = {}
for i=1, 20 do
	data[i] = "List item ".. i
end

-- Create a list with no background, allowing the background image to show through 
myList = tableView.newList{
	data=data,
	default="listItemBg_white.png",
	over="listItemBg_over.png",
	onRelease=listButtonRelease,
	top=topBoundary,
	bottom=bottomBoundary,
	callback=function(row) 
			local t = display.newText(row, 0, 0, native.systemFontBold, 16)
			t:setTextColor(255, 255, 255)
			t.x = math.floor(t.width/2) + 12
			t.y = 46 
			return t
		end
}

--Setup the nav bar 
local navBar = display.newImage("navBar.png", 0, 0, true)
navBar.x = display.contentWidth*.5
navBar.y = math.floor(display.screenOriginY + navBar.height*0.5)

local navHeader = display.newText("My List", 0, 0, native.systemFontBold, 16)
navHeader:setTextColor(255, 255, 255)
navHeader.x = display.contentWidth*.5
navHeader.y = navBar.y

--Setup the back button
backBtn = ui.newButton{ 
	default = "backButton.png", 
	over = "backButton_over.png", 
	onRelease = backBtnRelease
}
backBtn.x = math.floor(backBtn.width/2) + backBtn.width + screenOffsetW
backBtn.y = navBar.y 
backBtn.alpha = 0

