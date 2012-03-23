--
--====================================================================--        
-- EXAMPLE OF TABLE VIEW LIBRARY EXTENDED WITH IMAGES
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
-- Library "Extended" with more sophisticated rows.  Each row has an
-- image, bold text, and small lighter color text.
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
-- SETUP THE DATA TABLE
------------------------------------------------------------------------        

myData = {}  --note: the declaration of this variable was moved up higher to broaden its scope

--setup each row as a new table, then add title, subtitle, and image
myData[1] = {}
myData[1].title = "Hot Coffee"
myData[1].subtitle = "Grounds brewed in hot water"
myData[1].image = "coffee1.png"
myData[1].id = 1

myData[2] = {}
myData[2].title = "Iced Coffee"
myData[2].subtitle = "Chilled coffee with ice"
myData[2].image = "coffee2.png"
myData[2].id = 2

myData[3] = {}
myData[3].title = "Espresso"
myData[3].subtitle = "Hot water forced through"
myData[3].image = "coffee3.png"
myData[3].id = 3

myData[4] = {}
myData[4].title = "Cappuccino"
myData[4].subtitle = "Espresso with frothy milk"
myData[4].image = "coffee4.png"
myData[4].id = 4

myData[5] = {}
myData[5].title = "Latte"
myData[5].subtitle = "More milk and less froth"
myData[5].image = "coffee5.png"
myData[5].id = 5

myData[6] = {}
myData[6].title = "Americano"
myData[6].subtitle = "Espresso with hot water"
myData[6].image = "coffee6.png"
myData[6].id = 6

--duplicate the sample data to make the list longer
for i=1, 494 do
	myData[i+6] = {}
	myData[i+6].title = myData[i].title
	myData[i+6].subtitle = myData[i].subtitle
	myData[i+6].image = myData[i].image
	myData[i+6].id = i+6
end

------------------------------------------------------------------------        
-- CREATE THE INITIAL LIST VIEW
------------------------------------------------------------------------        

local topBoundary = display.screenOriginY + 40
local bottomBoundary = display.screenOriginY + 0
--
myList = tableView.newList{
	data=myData, 
	default="listItemBg.png",
	over="listItemBg_over.png",
	onRelease=listButtonRelease,
	top=top,
	bottom=bottom,
	backgroundColor={ 255, 255, 255 }, 
    callback = function( row )
                         local g = display.newGroup()

                         local img = display.newImage(row.image)
                         g:insert(img)
						 --
                         img.x = math.floor(img.width*0.5 + 6)
                         img.y = math.floor(img.height*0.5) 

                         local title =  display.newText( row.title .." ("..row.id..")", 0, 0, native.systemFontBold, 14 )
                         title:setTextColor(0, 0, 0)
                         g:insert(title)
						 --
                         title.x = title.width*0.5 + img.width + 6
                         title.y = 30

                         local subtitle =  display.newText( row.subtitle, 0, 0, native.systemFont, 12 )
                         subtitle:setTextColor(80,80,80)
                         g:insert(subtitle)
						 --
                         subtitle.x = subtitle.width*0.5 + img.width + 6
                         subtitle.y = title.y + title.height + 6

                         return g   
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

local navHeader = display.newText("My List (".. #myData .." items)", 0, 0, native.systemFontBold, 16)
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
