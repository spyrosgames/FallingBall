-- 
-- Abstract: List View sample app
--  
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Demonstrates how to create a list view using the Table View Library.
-- A list view is a collection of content organized in rows that the user
-- can scroll up or down on touch. Tapping on each row can execute a 
-- custom function.

--import the table view library
local tableView = require("tableView")

--import the button events library
local ui = require("ui")

display.setStatusBar( display.HiddenStatusBar ) 

--initial values
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local myList, backBtn, detailScreenText

local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(77, 77, 77)

--setup a destination for the list items
local detailScreen = display.newGroup()

local detailBg = display.newRect(0,0,display.contentWidth,display.contentHeight-display.screenOriginY)
detailBg:setFillColor(255,255,255)
detailScreen:insert(detailBg)

detailScreenText = display.newText("You tapped item", 0, 0, native.systemFontBold, 24)
detailScreenText:setTextColor(0, 0, 0)
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

-- setup some data
local data = {}
for i=1, 20 do
	data[i] = "List item ".. i
end

local topBoundary = display.screenOriginY + 40
local bottomBoundary = display.screenOriginY + 0

-- create the list of items
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

local function scrollToTop()
	myList:scrollTo(topBoundary-1)
end

--Setup the nav bar 
local navBar = ui.newButton{
	default = "navBar.png",
	onRelease = scrollToTop
}
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

