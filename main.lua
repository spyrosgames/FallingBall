--Includes--
local openfeint = require "openfeint"
local physics = require('physics')
local facebook = require("facebook")
local json = require("json")
local tableView = require("tableView")
director = require("director")

--Physics--
physics.start()
physics.setGravity(0, 9.8)
--

local mainGroup = display.newGroup()

--UI Elements--
local background
local firstLevelBackground
local cloud
local wind
local moon

--Main Menu Stuff--
local title
local startButton
local creditsButton
local highscoresButton
local titleView
local creditsView
local credits
local website
local backFromCreditsButton

--Powerups Stuff--
local live
local ghostBall
local slowDown

--HUDs--
local livesTF
local lives = 3

local scoreTF
local score = 0
local alertScore
local respawnTF

local pauseButtonUI
local resetButtonUI
local muteButtonUI

local livesHUD
local scoreHUD

--Game View Elements--
local gameView

local blocks
local monester
local ball

local alert
local playAgainIcon
local facebookIcon
local backToMainMenuIcon

--GameView Physics--
local ballDenisty = 2
local blockDenisty = 1
local ballBouncing = 0

--Game Controllers
local moveSpeed = 2
local moveSpeedWhenSlowDownPowerupTaken
local moveSpeedWhenGhostBallPowerupTaken
local beforePauseMoveSpeed

local respawning = false
local muted = false
local livePowerUpStarted = false
local slowDownPowerupActive = false
local ghostBallPowerupActive = false
local ghostBallPowerupStartTime = 0
local paused = false
local isFlying = false
local isBadBlock = false
local thisBadBlock
local isAlertShown = false

local cloudPositionBeforeRespawn
local windPositionBeforeRespawn

--Timers--
local blockTimer
local liveTimer
local ghostBallPowerupTimer
local checkForGhostBallPowerupTimer
local cloudsTimer
local checkForLivePowerupPositionTimer
local slowDownPowerupTimer
local checkForSlowDownPowerupTimer

local respawnTimer
local afterRespawnTimer

--Sound--
local ballSound = audio.loadSound('Ball_Hit.mp3')

--Functions
local Main = {}
local initialListeners = {}
local addTitleView = {}
local showCredits = {}
local hideCredits = {}
local destroyCredits = {}

--GameView Elements--
local gameView = {}
local addInitialBlocks = {}
local addBall = {}
local moveMonester = {}
local addBlock = {}
local showAlert = {}
local showAlertPlayAgainIcon = {}
local callFacebook = {}
local backToMainMenu = {}


local pauseButton = {}
local resetButton = {}
local muteButton = {}

local pauseButtonEffect = {}
local resetButtonEffect = {}
local muteButtonEffect = {}

local moveClouds = {}
local resetWind = {}
local resetCloud = {}

--Game Controllers--
local gameListeners = {}
local update = {}
local collisionHandler = {}

local removeBadBlock = {}
local respawn = {}
local launchOpenFeint = {}
local goToWebsite = {}

--Timers
local respawnTimer = {}
local respawnTimerTwo = {}
local respawnTimerThree = {}
local respawnTimerFour = {}
local respawnTimerFive = {}

--Powerups Functions--
local addLivePowerup = {}
local ghostBallPowerup = {}
local slowDownPowerup = {}

local ghostBallPowerupEffect = {}
local slowDownPowerupEffect = {}

local disableGhostBallPowerupEffect = {}
local disableSlowDownPowerupEffect = {}

local checkForLivePowerupPosition = {}
--
local sprite = require('sprite')
local spriteSheet = sprite.newSpriteSheet("BackgroundSpriteSheet.png", 320, 193)
local backgroundSpriteSheet = sprite.newSpriteSet(spriteSheet, 1, 4)
sprite.add(backgroundSpriteSheet, "running", 1, 4, 10000, 0)

--local secondSpriteSheet = sprite.newSpriteSheet("Clouds.png", 320, 134)
--local cloudSpriteSheet = sprite.newSpriteSet(secondSpriteSheet, 1, 2)
--sprite.add(cloudSpriteSheet, "clouds", 1, 2, 7000, 0)

function Main()
     display.setStatusBar(display.HiddenStatusBar)
     system.setAccelerometerInterval(35)
     physics.setScale(60)
     addTitleView()

     openfeint.init("vEIQcyk6tNGeHGrJLFFA", "WAQEekVOmhYJOLewycV9aaBtiiocikAj57MM4SpDe4", "Falling Ball")

     --local sysFonts = native.getFontNames()
     --for k,v in pairs(sysFonts) do print(v) end
end

--Game UI Elements--
function addMoon()
     moon = display.newImage("Moon.png")
     moon.x = 180
     moon.y = 60
end

function  addCloud()
     cloud = display.newImage("Clouds.png")
     cloud.x = display.contentWidth
     cloud.y = 270
end

function addWind()
     wind = display.newImage("Wind.png")
     wind.x = 0
     wind.y = 130
end

function addTitleView()
     firstLevelBackground = display.newImage("FirstLevelBackground.png")

     addMoon()
     addCloud()
     addWind()

     background = sprite.newSprite(backgroundSpriteSheet)
     background:prepare("running")
     --background:play()
     background.x = 160
     background.y = 390

     title = display.newImage("mainMenu.png")

     startButton = display.newImage("startBtn.png")
     startButton.x = display.contentCenterX - 72
     startButton.y = display.contentCenterY - 60
     startButton.name = "StartButton"
     startButton.xScale = 0.9
     startButton.yScale = 0.9

     creditsButton = display.newImage("creditsBtn.png")
     creditsButton.x = display.contentCenterX + 89
     creditsButton.y = display.contentCenterY + 100
     creditsButton.xScale = 0.9
     creditsButton.yScale = 0.9
     creditsButton.rotation = 31
     creditsButton.name = "CreditsButton"

     highscoresButton = display.newImage("highscoresBtn.png")
     highscoresButton.x = display.contentCenterX - 25
     highscoresButton.y = display.contentCenterY + 90
     highscoresButton.xScale = 0.7
     highscoresButton.yScale = 0.7
     highscoresButton.rotation = -30

     titleView = display.newGroup()
     titleView:insert(title)
     titleView:insert(startButton)
     titleView:insert(creditsButton)
     titleView:insert(highscoresButton)

     initialListeners("add")
end

function  initialListeners(action)
     if(action == "add") then
          startButton:addEventListener("tap", gameView)
          creditsButton:addEventListener("tap", showCredits)
          highscoresButton:addEventListener("tap", launchOpenFeint)

     else
          startButton:removeEventListener("tap", gameView)
          creditsButton:removeEventListener("tap", showCredits)
          highscoresButton:removeEventListener("tap", launchOpenFeint)

     end 
end

function gameView()
     initialListeners("rmv")
     --Remove Menu View and Start the game
     transition.to(titleView, {time = 500, y = titleView.height, transition = easing.outQuad, onComplete = function()display.remove(titleView) titleView = nil addInitialBlocks(3)end})
     --transition.to(titleView, {time = 500, x = display.contentWidth * 2, transition = easing.inQuad, onComplete = function()display.remove(titleView) titleView = nil addInitialBlocks(3)end})
     
     --HUDs
     --Score
     scoreHUD = display.newImage("hudforscore.png")
     scoreHUD.x = 287
     scoreHUD.y = 210
     --Lives
     livesHUD = display.newImage("hudforlives.png")
     livesHUD.x = 290
     livesHUD.y = 261
     --
     --Score Text
     scoreTF = display.newText('0', 285, 200, native.systemFont, 12)
     scoreTF:setTextColor(255, 255, 255)
     --Lives Text
     livesTF = display.newText('x3', 283, 253, native.systemFont, 12)
     livesTF:setTextColor(0, 0, 0)

     --respawnTF.size = 70

     pauseButton("PauseButton.png")
     resetButton()
     muteButton()
end

function addInitialBlocks(n)
     blocks = display.newGroup()

     for i = 1, n do
          local block = display.newImage("Block_new.png")
          block.name = "block"
          block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          if((block.x - (block.contentWidth * 0.5)) < 0) then
               block.x = display.contentWidth * 0.25
          end
          if(block.x > display.contentWidth)then
               block.x = display.contentWidth - block.width
          end
          --block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          block.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))
          --block.y = display.contentHeight + block.height

          physics.addBody(block, {denisty = blockDenisty, friction = 20, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          block.bodyType = "static"

          blocks:insert(block)
     end
     addBall()
end

function addBall()
     ball = display.newImage("Ball.png")
     
     --ball.x = (display.contentWidth * 0.5)
     --ball.y = ball.height

     ball.x =  blocks[1].x
     ball.y = blocks[1].y - ball.height

     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     gameListeners("add")
end

function gameListeners(action)
     if(action == "add") then
          Runtime:addEventListener("accelerometer", moveMonester)
          Runtime:addEventListener("enterFrame", update)
          blockTimer = timer.performWithDelay(770, addBlock, 0)
          liveTimer = timer.performWithDelay(6000, addLivePowerup, 0)
          checkForLivePowerupPositionTimer = timer.performWithDelay(1000, checkForLivePowerupPosition, 0)
          slowDownPowerupTimer = timer.performWithDelay(12000, slowDownPowerup,0)
          checkForSlowDownPowerupTimer = timer.performWithDelay(24000, slowDownPowerupEffect, 0)
          --ghostBallPowerupTimer = timer.performWithDelay(11000, ghostBallPowerup, 0)
          --checkForGhostBallPowerupTimer = timer.performWithDelay(10000, ghostBallPowerupEffect, 0)
          ball:addEventListener("collision", collisionHandler)
          pauseButtonUI:addEventListener("tap", pauseButtonEffect)
          resetButtonUI:addEventListener("tap", resetButtonEffect)
          muteButtonUI:addEventListener("tap", muteButtonEffect)
     elseif(action == "rmv") then
          Runtime:removeEventListener("accelerometer", moveMonester)
          Runtime:removeEventListener("enterFrame", update)
          timer.cancel(blockTimer)
          timer.cancel(liveTimer)
          timer.cancel(checkForLivePowerupPositionTimer)
          timer.cancel(slowDownPowerupTimer)
          timer.cancel(checkForSlowDownPowerupTimer)
          --timer.cancel(ghostBallPowerupTimer)
          --timer.cancel(checkForGhostBallPowerupTimer)

          --blockTimer = nil
          --liveTimer = nil
          --ghostBallPowerupTimer = nil
          --checkForGhostBallPowerupTimer = nil
          --cloudsTimer = nil
          ball:removeEventListener("collision", collisionHandler)
          pauseButtonUI:removeEventListener("tap", pauseButtonEffect)
          resetButtonUI:removeEventListener("tap", resetButtonEffect)
          muteButtonUI:removeEventListener("tap", muteButtonEffect)
     elseif(action == "pause") then
          timer.pause(blockTimer)
          timer.pause(liveTimer)
          timer.pause(checkForLivePowerupPositionTimer)
          timer.pause(slowDownPowerupTimer)
          timer.pause(checkForSlowDownPowerupTimer)
          --timer.pause(ghostBallPowerupTimer)
          --timer.pause(checkForGhostBallPowerupTimer)
     elseif(action == "resume") then
          timer.resume(blockTimer)
          timer.resume(liveTimer)
          timer.resume(checkForLivePowerupPositionTimer)
          timer.resume(slowDownPowerupTimer)
          timer.resume(checkForSlowDownPowerupTimer)
          --timer.resume(ghostBallPowerupTimer)
          --timer.resume(checkForGhostBallPowerupTimer)
     end     
end

function moveMonester:accelerometer(e)
     --movement
     if(paused == false) then
          --ball.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*3))
          ball.x = ball.x + (20 * e.xGravity)
          --ball.y = ball.y - (35 * e.yGravity)
          ball.rotation = ball.x + (e.xGravity * 40)
          physics.setGravity( ( 9.8 * event.xGravity ), ( -9.8 * event.yGravity ) )
     end
end

function  moveClouds()
     cloud.x = cloud.x + 30
     if(cloud.x > (display.contentWidth * 3)) then

          cloud.x = 0
     end
end

function resetCloud()
     if(respawning == false) then
          cloud.x = display.contentWidth
     end
end

function  resetWind()
     if(respawning == false) then
          wind.x = 0
     end
end
function update(e)
if(paused == false) then
     --[[
     if(livePowerUpStarted == true)then
     if(live.y < -5) then --at top, will fall
          live.x = blocks[blocks.numChildren - 1].x
          live.y = blocks[blocks.numChildren - 1].y - live.height
          --display.remove(live)
          livePowerUpStarted = false
     end
     
     end
     --]]
     if(cloud.x > (-cloud.width)) then
          transition.from(cloud, {time = 500, x = cloud.x - 0.2 , transition = easing.outQuad})
     else
          transition.from(cloud, {time = 500, x = display.contentWidth + cloud.width , transition = easing.outQuad})          
     end

     if(wind.x < (display.contentWidth + (wind.width) )) then
          transition.from(wind, {time = 500, x = wind.x + 0.4 , transition = easing.outQuad})
     else
          transition.from(wind, {time = 500, x = -(wind.width) , transition = easing.outQuad})     
     end

     if(ghostBallPowerupActive == false) then
          physics.addBody(ball, {denisty = ballDenisty, bounce = ballBouncing, friction = 15, isSensor = false, radius = 11})
     end

     if(ghostBallPowerupActive == true) then
               if(ball.y < (blocks[blocks.numChildren - 1].y - ball.height)) then
                    physics.removeBody(ball)
                    ball.y = ball.y + moveSpeed
                    moveSpeed = moveSpeed + 0.1
               else
                    ghostBallPowerupActive = false
               end
     end

     if(isBadBlock == true) then
          timer.performWithDelay(10000, removeBadBlock(thisBadBlock), 0)
          isBadBlock = false
     end

     if(slowDownPowerupActive == true)then
          moveSpeed = 2
          ball.y = ball.y + moveSpeed
     end
     --if(ball.y > display.contentHeight) then
          --ball.y = display.contentHeight
     --end

     -- Screen Borders
     if(ball.x <= 0) then --Left
          --ball.x = 5 + (ball.width * 0.5)
          --ball.x = display.contentWidth * 0.25
          ball.x = 0
     --elseif(ball.x >= (display.contentWidth - ball.width)) then --right
     elseif(ball.x >= (display.contentWidth)) then --right
          ball.x = display.contentWidth
          --ball.x = display.contentWidth - (ball.width * 2)
          --ball.x = 0
          --ball.x = display.contentWidth * 0.25
          --ball.x = display.contentWidth + (ball.width * 0.5)
     end
     
     for i = 1, blocks.numChildren do
          --Blocks Movement
          blocks[i].y = blocks[i].y - moveSpeed
     end
     --Score
     score = score + 1
     scoreTF.text = score


     --Lose Lives
     if(ball.y < -5) then --top

          respawning = true
          lives = lives - 1
          livesTF.text = 'x' .. lives

          beforePauseMoveSpeed = moveSpeed

          paused = true
          physics.pause()
          moveSpeed = 0
          gameListeners("pause")


          --ball.y = ball.height + 5
          --ball.y = display.contentHeight * 0.25

          if(lives > 0) then
               timer.performWithDelay(1000, respawnTimer())
               --timer.performWithDelay(3000, respawn)
          else
               respawn()
          end

          if(blocks[blocks.numChildren].name == "block")then
          ball.x =  blocks[blocks.numChildren].x
          ball.y = blocks[blocks.numChildren].y - ball.height
          else
          ball.x =  blocks[blocks.numChildren-1].x
          ball.y = blocks[blocks.numChildren-1].y - ball.height
          end

     elseif(ball.y > display.contentHeight) then --bottom

          respawning = true
          lives = lives - 1
          livesTF.text = 'x' .. lives

          beforePauseMoveSpeed = moveSpeed

          paused = true
          physics.pause()
          moveSpeed = 0
          gameListeners("pause")
          

          --ball.y = ball.height + 5
          --ball.y = display.contentHeight * 0.25

          if(lives > 0) then
               timer.performWithDelay(1000, respawnTimer())
               --respawnTimer = timer.performWithDelay(3000, respawn)
          else
               respawn()
          end
               
          if(blocks[blocks.numChildren].name == "block")then
          ball.x =  blocks[blocks.numChildren].x
          ball.y = blocks[blocks.numChildren].y - ball.height
          else
          ball.x =  blocks[blocks.numChildren-1].x
          ball.y = blocks[blocks.numChildren-1].y - ball.height
          end
     end

     --Check for game over
     if(lives == 0) then
          firstBallDead = true
          showAlert()
     end

     --Levels
     if(slowDownPowerupActive == false)then
     if(score < 500) then
          --Player Movement
          ball.y = ball.y + moveSpeed
     end

     if(score > 500 and score < 502) then
          moveSpeed = 3
          ball.y = ball.y + moveSpeed
     end

     if(score > 1000 and score < 1002) then
          moveSpeed = 4
          ball.y = ball.y + moveSpeed
     end

     if(score > 2000 and score < 2002) then
          moveSpeed = 5
          ball.y = ball.y + moveSpeed
     end

     if(score > 3000 and score < 3002) then
          moveSpeed = 6
          ball.y = ball.y + moveSpeed
     end

     if(score > 4000 and score < 4002) then
          moveSpeed = 7
          ball.y = ball.y + moveSpeed
     end

     if(score > 4000 and score < 4002) then
          moveSpeed = 8
          ball.y = ball.y + moveSpeed
     end 
     end
end
end

function respawn()
     paused = false
     respawning = false
     physics.start()
     moveSpeed = 2
     physics.setGravity(0, 4.7)
     gameListeners("resume")
     afterRespawnTimer = timer.performWithDelay(1000, respawnTimerFive)
end

function respawnTimer()
     --respawnTF.text = "3"
     --Respawn Text
     respawnTF = display.newText('3', display.contentWidth * 0.5, display.contentHeight * 0.4, native.systemFont, 70)
     respawnTF:setTextColor(255, 255, 255)

     timer.performWithDelay(1000, respawnTimerTwo)
end

function respawnTimerTwo()
     respawnTF.text = " "
     respawnTF.text = "2"
     timer.performWithDelay(1000, respawnTimerThree)
end

function respawnTimerThree()
     respawnTF.text = " "
     respawnTF.text = "1"
     timer.performWithDelay(1000, respawnTimerFour)
end

function respawnTimerFour()
     respawnTF.text = " "
     respawn()
end

function respawnTimerFive()
     moveSpeed = beforePauseMoveSpeed
     physics.setGravity(0, 9.8)
end

function addBlock()
     --local r = math.floor(math.random() * 2)
     --local r = math.floor(math.random(0, 3))
     local r = math.random(0, 6)
     if(r ~= 4) then
          local block = display.newImage("Block_new.png")
          block.name = "block"
          block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          if((block.x - (block.contentWidth * 0.5)) < 0) then
               block.x = display.contentWidth * 0.25
          end
          if(block.x > display.contentWidth)then
               block.x = display.contentWidth - block.width
          end
          block.y = display.contentHeight + block.height
          physics.addBody(block, {denisty = blockDenisty, friction = 20, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          block.bodyType = "static"

          blocks:insert(block)
     elseif(r == 4) then
          local badBlock = display.newImage("badBlock.png")
          badBlock.name = "bad"
          
          physics.addBody(badBlock, {denisty = 6, friction = 20, bounce = 0, isSensor = false, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          badBlock.bodyType = "static"
          badBlock.x = math.random() * (display.contentWidth - (badBlock.width * 0.5))

          if((badBlock.x - (badBlock.contentWidth * 0.5)) < 0) then
               badBlock.x = display.contentWidth * 0.25
          end
          if(badBlock.x > display.contentWidth)then
               badBlock.x = display.contentWidth - badBlock.width
          end

          badBlock.y = display.contentHeight + badBlock.height

          blocks:insert(badBlock)
     end
end

function showCredits()
     credits = display.newImage("creditsView.png")
     website = display.newImage("website.png")
     website.y = display.contentHeight * 0.5 + 60
     website.x = display.contentWidth * 0.5

     backFromCreditsButton = display.newImage("backToMainMenuIcon.png")
     backFromCreditsButton.rotation = 360
     backFromCreditsButton.y = display.contentHeight * 0.9
     backFromCreditsButton.x = 50

     transition.from(credits, {time = 400, x = display.contentWidth * 2, transition = easing.outQuad})
     transition.from(website, {time = 400, x = display.contentWidth * 2, transition = easing.outQuad})
     transition.from(backFromCreditsButton, {time = 400, x = display.contentWidth * 2, transition = easing.outQuad})

     backFromCreditsButton:addEventListener("tap", hideCredits)
     website:addEventListener("tap", goToWebsite)

     startButton.isVisible = false
     creditsButton.isVisible = false
end

function goToWebsite()
     native.showWebPopup(10, 100, 300, 300, "http://www.spyros-games.com")
end

function  hideCredits()
     startButton.isVisible = true
     creditsButton.isVisible = true
     transition.to(credits, {time = 600, x = display.contentWidth * 2, transition = easing.outQuad, onComplete = destroyCredits})
     transition.to(website, {time = 600, x = display.contentWidth * 2, transition = easing.outQuad, onComplete = destroyCredits})
     transition.to(backFromCreditsButton, {time = 600, x = display.contentWidth * 2, transition = easing.outQuad, onComplete = destroyCredits})
     native.cancelWebPopup()
end

function  destroyCredits()
     credits:removeEventListener("tap", hideCredits)

     display.remove(credits)
     display.remove(website)
     display.remove(backFromCreditsButton)

     credits = nil
     website = nil
     backFromCreditsButton = nil
end

function  pauseButton(photo)
     if(photo == "PauseButton.png") then
          pauseButtonUI = display.newImage("PauseButton.png")
     elseif(photo == "PlayButton.png") then
          pauseButtonUI = display.newImage("PlayButton.png")
     end

     pauseButtonUI.x = 290
     pauseButtonUI.y = 44
end

function resetButton()
     resetButtonUI = display.newImage("ResetButton.png")
     resetButtonUI.x = 290
     resetButtonUI.y = 101
     resetButtonUI.xScale = 0.9
     resetButtonUI.yScale = 0.9
end

function muteButton()
     if(muted == true) then
          muteButtonUI = display.newImage("UnMute.png")
     elseif(muted == false) then
          muteButtonUI = display.newImage("Mute.png")
     end

     muteButtonUI.x = 290
     muteButtonUI.y = 158
end
function pauseButtonEffect()
     if(respawning == false)then
     if(paused == false) then
          --display.remove(pauseButtonUI)
          pauseButton("PlayButton.png")

          beforePauseMoveSpeed = moveSpeed
          paused = true
          physics.pause()
          moveSpeed = 0
          gameListeners("pause")

     elseif(paused == true) then
          --display.remove(pauseButtonUI)
          pauseButton("PauseButton.png")

          paused = false
          physics.start()
          moveSpeed = beforePauseMoveSpeed
          gameListeners("resume")
     end
     end
end

function muteButtonEffect()
     if(muted == false)then
          muted = true
          --display.remove(muteButtonUI)
          muteButton()
     elseif(muted == true)then
          muted = false
          display.remove(muteButtonUI)
          muteButton()
     end
end

function  resetButtonEffect()
     if(respawning == false) then
     if(paused == true) then
          pauseButton("PauseButton.png")

          paused = false
          physics.start()
          moveSpeed = beforePauseMoveSpeed
     end

     display.remove(blocks)
     display.remove(ball)
     display.remove(live)
     --display.remove(ghostBall)

     cloud.x = display.contentWidth
     wind.x = 0
     
     --live = nil
     --ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2
     livePowerUpStarted = false
     --
     --remove Listeners
     Runtime:removeEventListener("enterFrame", update)
     timer.cancel(blockTimer)
     timer.cancel(liveTimer)
     timer.cancel(checkForLivePowerupPositionTimer)
     timer.cancel(slowDownPowerupTimer)
     timer.cancel(checkForSlowDownPowerupTimer)
     --timer.cancel(ghostBallPowerupTimer)
     --timer.cancel(checkForGhostBallPowerupTimer)
     ball:removeEventListener("collision", collisionHandler)
     --
     --add Initial Blocks
     blocks = display.newGroup()

     for i = 1, 3 do
          local InitialBlock = display.newImage("Block_new.png")
          InitialBlock.name = "block"
          --InitialBlock.x = math.floor(math.random() * (display.contentWidth - InitialBlock.width))
          --InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          InitialBlock.x = math.random() * (display.contentWidth - (InitialBlock.width * 0.5))
          if((InitialBlock.x - (InitialBlock.contentWidth * 0.5)) < 0) then
               InitialBlock.x = display.contentWidth * 0.25
          end
          if(InitialBlock.x > display.contentWidth)then
               InitialBlock.x = display.contentWidth - InitialBlock.width
          end
          --block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          physics.addBody(InitialBlock, {denisty = blockDenisty, friction = 20, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          InitialBlock.bodyType = "static"

          blocks:insert(InitialBlock)
     end
     --
     --add Ball
     ball = display.newImage("Ball.png")
     ball.x =  blocks[1].x
     ball.y = blocks[1].y - ball.height
     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     --

     --add gameListeners
     Runtime:addEventListener("enterFrame", update)

     blockTimer = timer.performWithDelay(1000, addBlock, 0)
     liveTimer = timer.performWithDelay(6000, addLivePowerup, 0)
     checkForLivePowerupPositionTimer = timer.performWithDelay(1000, checkForLivePowerupPosition, 0)
     slowDownPowerupTimer = timer.performWithDelay(12000, slowDownPowerup,0)
     checkForSlowDownPowerupTimer = timer.performWithDelay(24000, slowDownPowerupEffect, 0)

     --ghostBallPowerupTimer = timer.performWithDelay(11000, ghostBallPowerup, 0)
     --checkForGhostBallPowerupTimer = timer.performWithDelay(10000, ghostBallPowerupEffect, 0)

     ball:addEventListener("collision", collisionHandler)
     --
     end
end

function showAlertPlayAgainIcon()
     if(paused == true) then
          pauseButton("PauseButton.png")

          paused = false
          physics.start()
          moveSpeed = beforePauseMoveSpeed
     end

     display.remove(blocks)
     display.remove(ball)
     display.remove(live)
     --display.remove(ghostBall)
     display.remove(alert)
     display.remove(alertScore)
     display.remove(playAgainIcon)
     display.remove(facebookIcon)
     display.remove(backToMainMenuIcon)

     cloud.x = display.contentWidth
     wind.x = 0
     
     --live = nil
     --ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2
     livePowerUpStarted = false

     resetButton()

     --add Initial Blocks
     blocks = display.newGroup()

     for i = 1, 3 do
          local InitialBlock = display.newImage("Block_new.png")
          InitialBlock.name = "block"

          --InitialBlock.x = math.floor(math.random() * (display.contentWidth - InitialBlock.width))
          --InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          InitialBlock.x = math.random() * (display.contentWidth - (InitialBlock.width * 0.5))
          if((InitialBlock.x - (InitialBlock.contentWidth * 0.5)) < 0) then
               InitialBlock.x = display.contentWidth * 0.25
          end
          if(InitialBlock.x > display.contentWidth)then
               InitialBlock.x = display.contentWidth - InitialBlock.width
          end
          --block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          physics.addBody(InitialBlock, {denisty = blockDenisty, friction = 20, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          InitialBlock.bodyType = "static"

          blocks:insert(InitialBlock)
     end
     --
     --add Ball
     ball = display.newImage("Ball.png")
     ball.x =  blocks[1].x
     ball.y = blocks[1].y - ball.height
     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     --
     gameListeners("add")

end

function showAlert()
     isAlertShown = true
     gameListeners("rmv")
     alert = display.newImage("alertBg.png", 70, 190)

     alertScore = display.newText(scoreTF.text .. "!", 134, 240, native.systemFont, 30)
     --livesTF.text = ""
     --live = nil

     display.remove(ball)
     display.remove(live)
     --display.remove(ghostBall)
     

     display.remove(resetButtonUI)
     transition.from(alert, {time = 200, xScale = 0.8})
     
     playAgainIcon = display.newImage("ResetButton.png", 84, 300)
     playAgainIcon:addEventListener("tap", showAlertPlayAgainIcon)

     facebookIcon = display.newImage("Facebook.png", 142, 298)

     facebookIcon:addEventListener("tap", callFacebook)

     backToMainMenuIcon = display.newImage("backToMainMenuIcon.png", 198, 298)
     backToMainMenuIcon:addEventListener("tap", backToMainMenu)

     openfeint.setHighScore( { leaderboardID="1116637", score=score } )
end

function backToMainMenu()
     scoreTF.text = ""
     
     display.remove(blocks)
     display.remove(alert)
     display.remove(pauseButtonUI)
     display.remove(playAgainIcon)
     display.remove(facebookIcon)
     display.remove(backToMainMenuIcon)
     display.remove(livesTF)
     display.remove(scoreTF)
     display.remove(firstLevelBackground)
     display.remove(cloud)
     display.remove(wind)
     display.remove(moon)
     display.remove(background)

     cloud.x = display.contentWidth
     wind.x = 0
     
     --live = nil
     --ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2
     paused = false
     livePowerUpStarted = false
     addTitleView()
end

--Powerups--
function checkForLivePowerupPosition()
     if(live ~= nil)then
          if(live.y < -5)then
               display.remove(live)
          end
     end
end

function addLivePowerup()
     if(ball.y < (blocks[blocks.numChildren - 1].y)) then
          live = display.newImage("live.png")

          live.name = "live"
          live.x = blocks[blocks.numChildren - 1].x
          live.y = blocks[blocks.numChildren - 1].y - live.height

          live.bodyType = "kinematic"
          live.isFixedRotation = true
          physics.addBody(live, {denisty = 1, friction = 20, bounce = 0})
          livePowerUpStarted = true
     end
end

function ghostBallPowerup()
     if(ball.y < (blocks[blocks.numChildren].y)) then
          ghostBall = display.newImage("ghost.png")

          ghostBall.name = "ghostBallPowerup"

          ghostBall.x = blocks[blocks.numChildren].x + 0.8
          ghostBall.y = blocks[blocks.numChildren].y - ghostBall.height
          if(ghostBall.y < -5) then --at top, will fall
               ghostBall.y = ghostBall.y - 20
          end
          ghostBall.bodyType = "static"
          ghostBall.isFixedRotation = true
          physics.addBody(ghostBall, {denisty = 1, friction = 0, bounce = 0})
          if(live and live.y == ghostBall.y) then
               display.removeBody(ghostBall)
          end
     end
end

function ghostBallPowerupEffect()
     if(ghostBallPowerupActive == true) then
          timer.performWithDelay(20000, disableGhostBallPowerupEffect(), 0)
     end
end

function disableGhostBallPowerupEffect()
     ghostBallPowerupActive = false
     --moveSpeed = moveSpeedWhenGhostBallPowerupTaken
     moveSpeed = moveSpeed - 0.1
     ball.y = ball.y + moveSpeed
end

function slowDownPowerup()
     if(ball.y < (blocks[blocks.numChildren - 1].y)) then
          slowDown = display.newImage("slowDown.png")

          slowDown.name = "slowDown"
          
          if(live) then
               if(slowDown.y == live.y) then
                    slowDown.y = blocks[blocks.numChildren - 2].y - slowDown.height
                    slowDown.x = blocks[blocks.numChildren - 2].x
               else
                    slowDown.y = blocks[blocks.numChildren - 2].y - slowDown.height
                    slowDown.x = blocks[blocks.numChildren - 2].x
               end
          else
                    slowDown.y = blocks[blocks.numChildren - 1].y - slowDown.height
                    slowDown.x = blocks[blocks.numChildren - 1].x
          end
          
          
          slowDown.bodyType = "kinematic"
          slowDown.isFixedRotation = true
          physics.addBody(slowDown, {denisty = 1, friction = 20, bounce = 0})
     end
end

function slowDownPowerupEffect()
     if(slowDownPowerupActive == true)then
          timer.performWithDelay(2000, disableSlowDownPowerupEffect(), 0)
     end
end

function  disableSlowDownPowerupEffect()
     slowDownPowerupActive = false
     moveSpeed = moveSpeedWhenSlowDownPowerupTaken
end

function collisionHandler(e)
     if(e.other.name == "bad") then
          if(muted == false) then
               audio.play(ballSound)
          end
          isBadBlock = true
          thisBadBlock = e.other
     end

     if(e.other.name == "block") then
          if(muted == false) then
               audio.play(ballSound)
          end
     end

     --Lives Powerup
     if(e.other.name == "live") then
          display.remove(e.other)
          --e.other = nil
          if(lives < 3 and lives > 0) then
               lives = lives + 1
               livesTF.text = 'x' .. lives
          end
     end

     --ghostBallPowerup
     if(e.other.name == "ghostBallPowerup") then
          display.remove(e.other)
          --e.other = nil
          ghostBallPowerupActive = true
          ghostBallPowerupStartTime = os.time()
          moveSpeedWhenGhostBallPowerupTaken = moveSpeed
     end    

     --slowDown Powerup
     if(e.other.name == "slowDown") then
          display.remove(e.other)
          slowDownPowerupActive = true
          moveSpeedWhenSlowDownPowerupTaken = moveSpeed
     end      
end

function removeBadBlock(e)
     display.remove(e)
end

function launchOpenFeint()
     openfeint.launchDashboard("leaderboards")
end

function  callFacebook()
     local facebookListener = function (event)
          if("session" == event.type) then
               if("login" == event.phase) then
                    local gamescore = toString(score)
                    local theMessage = "Just scored" .. gamescore .. "playing the Falling Ball on iPhone!"

                    facebook.request("me/feed", "POST", {
                    message=theMessage})
               end
          end
     end
     facebook.login("200498513395966", facebookListener, {"publish_stream"})
end

Main()















