local openfeint = require "openfeint"
local physics = require('physics')
local facebook = require("facebook")
local json = require("json")
local tableView = require("tableView")

physics.start()
physics.setGravity(0, 9.8)

director = require("director")

local mainGroup = display.newGroup()

local background
local firstLevelBackground
local cloud
local wind
local moon

local title
local startButton
local creditsButton
local highscoresButton

local titleView
local creditsView

local live

local livesTF
local lives = 3

local scoreTF
local score = 0
local alertScore

local respawnTF

local blocks
local monester
local ball
local anotherBall
local ghostBall

local ballDenisty = 10
local blockDenisty = 1
local ballBouncing = 0

local gameView

local moveSpeed = 2

local blockTimer
local liveTimer
local twoBallsPowerupTimer
local ghostBallPowerupTimer
local checkForGhostBallPowerupTimer
local cloudsTimer

local pauseButtonUI
local resetButtonUI

local alert
local playAgainIcon
local facebookIcon
local backToMainMenuIcon
local respawning = false

local livesHUD
local scoreHUD

local respawnTimer
local afterRespawnTimer

--Functions
local Main = {}
local addTitleView = {}
local initialListeners = {}
local showCredits = {}
local hideCredits = {}
local destroyCredits = {}
local gameView = {}
local addInitialBlocks = {}

local addBall = {}
local addAnotherBall = {}
local moveMonester = {}
local moveAnotherBall = {}
local addBlock = {}
local addLivePowerup = {}
local ghostBallPowerup = {}
local gameListeners = {}
local update = {}
local collisionHandler = {}
local showAlert = {}
local showAlertPlayAgainIcon = {}
local ghostBallPowerupTimerTable = {}
local disableGhostBallPowerupEffect = {}
local ghostBallPowerupEffect = {}
local pauseButton = {}
local resetButton = {}
local removeBadBlock = {}
local launchOpenFeint = {}
local moveClouds = {}
local callFacebook = {}
local respawn = {}
local respawnTimer = {}

local sprite = require('sprite')
local spriteSheet = sprite.newSpriteSheet("BackgroundSpriteSheet.png", 320, 193)
local backgroundSpriteSheet = sprite.newSpriteSet(spriteSheet, 1, 4)
sprite.add(backgroundSpriteSheet, "running", 1, 4, 10000, 0)

--local secondSpriteSheet = sprite.newSpriteSheet("Clouds.png", 320, 134)
--local cloudSpriteSheet = sprite.newSpriteSet(secondSpriteSheet, 1, 2)
--sprite.add(cloudSpriteSheet, "clouds", 1, 2, 7000, 0)

local firstBallDead
local secondBallDead
local twoBallsPowerupIsTaken

local ghostBallPowerupActive = false

local ghostBallPowerupStartTime = 0

local paused = false
local isFlying = false
local isBadBlock = false
local thisBadBlock

local isAlertShown = false
local moveSpeedWhenGhostBallPowerupTaken
local beforePauseMoveSpeed

local cloudPositionBeforeRespawn
local windPositionBeforeRespawn

function Main()
     display.setStatusBar(display.HiddenStatusBar)
     system.setAccelerometerInterval(27)
     physics.setScale(60)
     addTitleView()

     openfeint.init("vEIQcyk6tNGeHGrJLFFA", "WAQEekVOmhYJOLewycV9aaBtiiocikAj57MM4SpDe4", "Falling Ball")
end

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


     --local cloud = sprite.newSprite(cloudSpriteSheet)
     --cloud:prepare("clouds")
     --cloud:play()
     --cloud.x = 160
     --cloud.y = 240

     title = display.newImage("mainMenu.png")

     startButton = display.newImage("startBtn.png")
     startButton.x = display.contentCenterX - 70
     startButton.y = display.contentCenterY - 60
     startButton.name = "StartButton"
     startButton.xScale = 0.8
     startButton.yScale = 0.8

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
     scoreHUD.x = 290
     scoreHUD.y = 160
     --Lives
     livesHUD = display.newImage("hudforlives.png")
     livesHUD.x = 290
     livesHUD.y = 190
     --
     --Score Text
     scoreTF = display.newText('0', 289, 150, system.nativeFont, 12)
     scoreTF:setTextColor(0, 0, 0)
     --Lives Text
     livesTF = display.newText('x3', 282, 182, system.nativeFont, 12)
     livesTF:setTextColor(0, 0, 0)
     --Respawn Text
     respawnTF = display.newText(' ', display.contentWidth * 0.5, display.contentHeight * 0.5)
     respawnTF:setTextColor(255, 255, 255)
     respawnTF.size = 70

     pauseButton("PauseButton.png")
     resetButton()
end

function addInitialBlocks(n)
     blocks = display.newGroup()

     for i = 1, n do
          local block = display.newImage("Block_new.png")

          block.x = math.floor(math.random() * (display.contentWidth - block.width))
          block.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          physics.addBody(block, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          block.bodyType = "static"

          blocks:insert(block)
     end
     addBall()
end

function addBall()
     ball = display.newImage("Ball.png")
     ball.x = (display.contentWidth * 0.5)
     ball.y = ball.height
     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     gameListeners("add")
end

function gameListeners(action)
     if(action == "add") then
          Runtime:addEventListener("accelerometer", moveMonester)
          Runtime:addEventListener("enterFrame", update)
          blockTimer = timer.performWithDelay(1000, addBlock, 0)
          liveTimer = timer.performWithDelay(10000, addLivePowerup, 0)
          ghostBallPowerupTimer = timer.performWithDelay(11000, ghostBallPowerup, 0)
          checkForGhostBallPowerupTimer = timer.performWithDelay(10000, ghostBallPowerupEffect, 0)
          --cloudsTimer = timer.performWithDelay(1000, moveClouds, 0)
          ball:addEventListener("collision", collisionHandler)
          pauseButtonUI:addEventListener("tap", pauseButtonEffect)
          resetButtonUI:addEventListener("tap", resetButtonEffect)
     elseif(action == "rmv") then
          Runtime:removeEventListener("accelerometer", moveMonester)
          Runtime:removeEventListener("enterFrame", update)
          timer.cancel(blockTimer)
          timer.cancel(liveTimer)
          timer.cancel(ghostBallPowerupTimer)
          timer.cancel(checkForGhostBallPowerupTimer)
          --timer.cancel(cloudsTimer)
          --blockTimer = nil
          --liveTimer = nil
          --ghostBallPowerupTimer = nil
          --checkForGhostBallPowerupTimer = nil
          --cloudsTimer = nil
          ball:removeEventListener("collision", collisionHandler)
          pauseButtonUI:removeEventListener("tap", pauseButtonEffect)
          resetButtonUI:removeEventListener("tap", resetButtonEffect)

     elseif(action == "pause") then
          timer.pause(blockTimer)
          timer.pause(liveTimer)
          timer.pause(ghostBallPowerupTimer)
          timer.pause(checkForGhostBallPowerupTimer)
          --timer.pause(cloudsTimer)
     elseif(action == "resume") then
          timer.resume(blockTimer)
          timer.resume(liveTimer)
          timer.resume(ghostBallPowerupTimer)
          timer.resume(checkForGhostBallPowerupTimer)
          --timer.resume(cloudsTimer)
     end     
end

function moveMonester:accelerometer(e)
     --movement
     if(paused == false) then
          ball.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*3))
          --ball.rotation = ball.x
          ball.rotation = ball.x + e.xGravity + 9
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
          physics.addBody(ball, {denisty = ballDenisty, bounce = ballBouncing, isSensor = false, radius = 11})
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
     --if(ball.y > display.contentHeight) then
          --ball.y = display.contentHeight
     --end

     -- Screen Borders
     if(ball.x <= 0) then --Left
          ball.x = 0 + (ball.width * 0.5)
          --ball.x = display.contentWidth * 0.75
     --elseif(ball.x >= (display.contentWidth - ball.width)) then --right
     elseif(ball.x >= (display.contentWidth)) then --right
          ball.x = display.contentWidth - ball.width
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

          ball.x =  blocks[blocks.numChildren - 1].x
          ball.y = blocks[blocks.numChildren - 1].y - ball.height
          --ball.y = ball.height + 5
          --ball.y = display.contentHeight * 0.25

          if(lives > 0) then
               timer.performWithDelay(1000, respawnTimer())
               timer.performWithDelay(3000, respawn)
          else
               respawn()
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
          
          ball.x =  blocks[blocks.numChildren - 1].x
          ball.y = blocks[blocks.numChildren - 1].y - ball.height
          --ball.y = ball.height + 5
          --ball.y = display.contentHeight * 0.25

          if(lives > 0) then
               timer.performWithDelay(1000, respawnTimer())
               respawnTimer = timer.performWithDelay(4000, respawn)
          else
               respawn()
          end
               
          
     end

     --Check for game over
     if(lives == 0) then
          firstBallDead = true
          showAlert()
     end

     --Levels
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

function respawn()
     paused = false
     respawning = false
     physics.start()
     moveSpeed = 2
     physics.setGravity(0, 4.7)
     gameListeners("resume")
     afterRespawnTimer = timer.performWithDelay(2000, respawnTimerFive)
end

function respawnTimer()
     respawnTF.text = "3"
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
end

function respawnTimerFive()
     moveSpeed = beforePauseMoveSpeed
     physics.setGravity(0, 9.8)
end

function addBlock()
     --local r = math.floor(math.random() * 2)
     local r = math.floor(math.random() * 4)
     if(r ~= 0) then
          local block = display.newImage("Block_new.png")
          block.name = "block"
          block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          if(block.x < 0) then
               block.x = 5
          end
          if(block.x > display.contentWidth)then
               block.x = display.contentWidth - block.width
          end
          block.y = display.contentHeight + block.height
          physics.addBody(block, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          block.bodyType = "static"

          blocks:insert(block)
     else
          local badBlock = display.newImage("badBlock.png")
          badBlock.name = "bad"
          
          physics.addBody(badBlock, {denisty = 3, bounce = 0, isSensor = false, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          badBlock.bodyType = "static"
          badBlock.x = math.random() * (display.contentWidth - (badBlock.width * 0.5))

          if(badBlock.x < 0) then
               badBlock.x = 5
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
     transition.from(credits, {time = 400, x = display.contentWidth * 2, transition = easing.outQuad})
     credits:addEventListener("tap", hideCredits)
     startButton.isVisible = false
     creditsButton.isVisible = false
end

function  hideCredits()
     startButton.isVisible = true
     creditsButton.isVisible = true
     transition.to(credits, {time = 600, x = display.contentWidth * 2, transition = easing.outQuad, onComplete = destroyCredits})
end

function  destroyCredits()
     credits:removeEventListener("tap", hideCredits)
     display.remove(credits)
     credits = nil
end

function  pauseButton(photo)
     if(photo == "PauseButton.png") then
          pauseButtonUI = display.newImage("PauseButton.png")
     elseif(photo == "PlayButton.png") then
          pauseButtonUI = display.newImage("PlayButton.png")
     end

     pauseButtonUI.x = 290
     pauseButtonUI.y = 40
end

function  resetButton()
     resetButtonUI = display.newImage("ResetButton.png")
     resetButtonUI.x = 290
     resetButtonUI.y = 110
     resetButtonUI.xScale = 0.9
     resetButtonUI.yScale = 0.9
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
     display.remove(ghostBall)

     cloud.x = display.contentWidth
     wind.x = 0
     
     live = nil
     ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2
     --
     --remove Listeners
     Runtime:removeEventListener("enterFrame", update)
     timer.cancel(blockTimer)
     timer.cancel(liveTimer)
     timer.cancel(ghostBallPowerupTimer)
     timer.cancel(checkForGhostBallPowerupTimer)
     ball:removeEventListener("collision", collisionHandler)
     --
     --add Initial Blocks
     blocks = display.newGroup()

     for i = 1, 3 do
          local InitialBlock = display.newImage("Block_new.png")

          InitialBlock.x = math.floor(math.random() * (display.contentWidth - InitialBlock.width))
          InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          physics.addBody(InitialBlock, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          InitialBlock.bodyType = "static"

          blocks:insert(InitialBlock)
     end
     --
     --add Ball
     ball = display.newImage("Ball.png")
     ball.x = (display.contentWidth * 0.5)
     ball.y = ball.height
     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     --

     --add gameListeners
     Runtime:addEventListener("enterFrame", update)

     blockTimer = timer.performWithDelay(1000, addBlock, 0)
     liveTimer = timer.performWithDelay(10000, addLivePowerup, 0)
     ghostBallPowerupTimer = timer.performWithDelay(11000, ghostBallPowerup, 0)
     checkForGhostBallPowerupTimer = timer.performWithDelay(10000, ghostBallPowerupEffect, 0)

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
     display.remove(ghostBall)
     display.remove(alert)
     display.remove(alertScore)
     display.remove(playAgainIcon)
     display.remove(facebookIcon)
     display.remove(backToMainMenuIcon)

     cloud.x = display.contentWidth
     wind.x = 0
     
     live = nil
     ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2

     resetButton()

     --add Initial Blocks
     blocks = display.newGroup()

     for i = 1, 3 do
          local InitialBlock = display.newImage("Block_new.png")

          InitialBlock.x = math.floor(math.random() * (display.contentWidth - InitialBlock.width))
          InitialBlock.y = (display.contentHeight * 0.5) + math.floor(math.random() * (display.contentHeight * 0.5))

          physics.addBody(InitialBlock, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          InitialBlock.bodyType = "static"

          blocks:insert(InitialBlock)
     end
     --
     --add Ball
     ball = display.newImage("Ball.png")
     ball.x = (display.contentWidth * 0.5)
     ball.y = ball.height
     ball:setReferencePoint(display.CenterReferencePoint)
     ball.isBullet = true
     --
     gameListeners("add")

end

function showAlert()
     isAlertShown = true
     gameListeners("rmv")
     alert = display.newImage("alertBg.png", 70, 190)

     alertScore = display.newText(scoreTF.text .. "!", 134, 240, native.systemFontBold, 30)
     --livesTF.text = ""

     display.remove(ball)
     display.remove(live)
     display.remove(ghostBall)
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
     
     live = nil
     ghostBall = nil
     --
     score = 0
     scoreTF.text = score

     lives = 3
     livesTF.text = "x" .. lives

     moveSpeed = 2
     paused = false
     addTitleView()
end

function addLivePowerup()
     if(ball.y < (display.contentHeight * 0.33)) then
          live = display.newImage("live.png")

          live.name = "live"
          live.x = blocks[blocks.numChildren - 1].x
          live.y = blocks[blocks.numChildren - 1].y - live.height
          if(live.y < -5) then --at top, will fall
               live.y = live.y - 20
          end
          live.bodyType = "static"
          live.isFixedRotation = true
          physics.addBody(live, {denisty = 1, friction = 2, bounce = 0})
     end
end

function ghostBallPowerup()
     if(ball.y < (display.contentHeight * 0.33)) then
          ghostBall = display.newImage("ghost.png")

          ghostBall.name = "ghostBallPowerup"

          ghostBall.x = blocks[blocks.numChildren - 1].x + 0.8
          ghostBall.y = blocks[blocks.numChildren - 1].y - ghostBall.height
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

function removeBadBlock(e)
     display.remove(e)
end

function collisionHandler(e)
     if(e.other.name == "bad") then
          isBadBlock = true
          thisBadBlock = e.other

     end

     --Lives Powerup
     if(e.other.name == "live") then
          display.remove(e.other)
          e.other = nil
          if(lives < 3 and lives > 0) then
               lives = lives + 1
               livesTF.text = 'x' .. lives
          end
     end

     --ghostBallPowerup
     if(e.other.name == "ghostBallPowerup") then
          display.remove(e.other)
          e.other = nil
          if(live) then
               display.remove(live)
          end
          ghostBallPowerupActive = true
          ghostBallPowerupStartTime = os.time()
          moveSpeedWhenGhostBallPowerupTaken = moveSpeed
     end          
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















