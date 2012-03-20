local physics = require('physics')
physics.start()
physics.setGravity(0, 9.8)

local background

local title
local startButton
local creditsButton

local titleView
local creditsView

local live

local livesTF
local lives = 3

local scoreTF
local score = 0
local alertScore

local blocks
local monester
local ball
local anotherBall
local ghostBall

local ballDenisty = 20
local blockDenisty = 10

local gameView

local moveSpeed = 2
local blockTimer
local liveTimer
local twoBallsPowerupTimer
local ghostBallPowerupTimer
local checkForGhostBallPowerupTimer
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
local twoBallsPowerup = {}
local ghostBallPowerup = {}
local gameListeners = {}
local update = {}
local collisionHandler = {}
local showAlert = {}
local ghostBallPowerupTimerTable = {}
local disableGhostBallPowerupEffect = {}
local ghostBallPowerupEffect = {}
local pauseButton = {}

local sprite = require('sprite')
local spriteSheet = sprite.newSpriteSheet("animation.png", 50, 50)
local monesterSpriteSheet = sprite.newSpriteSet(spriteSheet, 1, 4)
sprite.add(monesterSpriteSheet, "running", 1, 4, 600, 0)

local firstBallDead
local secondBallDead
local twoBallsPowerupIsTaken

local ghostBallPowerupActive = false

local ghostBallPowerupStartTime = 0

local paused = false

local moveSpeedWhenGhostBallPowerupTaken
local beforePauseMoveSpeed
function Main()
     display.setStatusBar(display.HiddenStatusBar)
     system.setAccelerometerInterval(30)
     physics.setScale(60)
     addTitleView()
end

function addTitleView()
     background = display.newImage("blocksTexture_new.png")
     title = display.newImage("titleBG.jpg")
     startButton = display.newImage("startBtn.png")
     startButton.x = display.contentCenterX
     startButton.y = display.contentCenterY
     startButton.name = "StartButton"

     creditsButton = display.newImage("creditsBtn.png")
     creditsButton.x = display.contentCenterX
     creditsButton.y = display.contentCenterY + 60
     creditsButton.name = "CreditsButton"

     titleView = display.newGroup()
     titleView:insert(title)
     titleView:insert(startButton)
     titleView:insert(creditsButton)

     initialListeners("add")
end

function  initialListeners(action)
     if(action == "add") then
          startButton:addEventListener("tap", gameView)
          creditsButton:addEventListener("tap", showCredits)
     else
          startButton:removeEventListener("tap", gameView)
          creditsButton:removeEventListener("tap", showCredits)
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

function gameView()
     initialListeners("rmv")
     --Remove Menu View and Start the game
     transition.to(titleView, {time = 500, y = -titleView.height, transition = easing.outQuad, onComplete = function()display.remove(titleView) titleView = nil addInitialBlocks(3)end})
     --Score Text
     scoreTF = display.newText('0', 303, 22, system.nativeFont, 12)
     scoreTF:setTextColor(68, 68, 68)
     --Lives Text
     livesTF = display.newText('x3', 289, 56, system.nativeFont, 12)
     livesTF:setTextColor(245, 249, 248)
     pauseButton()
end

function  pauseButton()
     pauseButton = display.newImage("PauseButton.png")
     pauseButton.x = 30
     pauseButton.y = 30
end

function pauseButtonEffect()
     if(paused == false) then
          beforePauseMoveSpeed = moveSpeed
          paused = true
          physics.pause()
          moveSpeed = 0
          gameListeners("pause")
     elseif(paused == true) then
          paused = false
          physics.start()
          moveSpeed = beforePauseMoveSpeed
          gameListeners("resume")
     end 
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

function addBlock()
     --local r = math.floor(math.random() * 2)
     local r = math.random(0, 3)
     if(r ~= 3) then
          local block = display.newImage("Block_new.png")
          block.name = "block"
          block.x = math.random() * (display.contentWidth - (block.width * 0.5))
          block.y = display.contentHeight + block.height
          physics.addBody(block, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          block.bodyType = "static"

          blocks:insert(block)
     elseif(r ~= 1) then
          local badBlock = display.newImage("badBlock.png")
          badBlock.name = "bad"
          
          physics.addBody(badBlock, {denisty = blockDenisty, bounce = 0, shape = {-26, -7, 26, -7, 26, 7, -26, 7}})
          badBlock.bodyType = "static"
          badBlock.x = math.random() * (display.contentWidth - (badBlock.width * 0.5))
          badBlock.y = display.contentHeight + badBlock.height

          blocks:insert(badBlock)
     end
end

function addBall()
     ball = display.newImage("Ball_new.png")
     ball.x = (display.contentWidth * 0.5)
     ball.y = ball.height
     --ball.gravity = -6
     --ball.isFixedRotation = true
     gameListeners("add")
     --monester = sprite.newSprite(monesterSpriteSheet)
     --monester:prepare("running")
     --monester:play()
     
     --monester.x = display.contentWidth * 0.5
     --monester.y = monester.height
     --physics.addBody(monester, {denisty = 2, friction = 0, bounce = 0})
     --monester.isFixedRotation = true
     --gameListeners("add")
end

function addAnotherBall()
     anotherBall = display.newImage("Ball_new.png")
     anotherBall.x = display.contentWidth * 0.5
     anotherBall.y = anotherBall.height
     anotherBall.gravity = -6
     physics.addBody(anotherBall, {denisty = ballDenisty, bounce = 0, radius = 24})
     anotherBall.isFixedRotation = true
     anotherBallGameListeners("add")
end

function moveMonester:accelerometer(e)
     --movement
     ball.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*3))
     ball.rotation = ball.x
     --ball.xScale = 1


     --monester.x = monester.x + (60 * e.xGravity)
     --if(ball.x > display.contentWidth * 0.5) then
          --ball.xScale = 1
     --end
     --if(ball.x < display.contentWidth * 0.5) then
          --ball.xScale = -1
     --end

     --borders
     --if((monester.x - monester.width * 2) < 0) then
          --monester.x = monester.width * 0.5
     --elseif((monester.x + monester.width * 2) > display.contentWidth) then
          --monester.x = display.contentWidth - monester.width * 0.5
     --end
end

function  moveAnotherBall:accelerometer(e)
     anotherBall.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*3))
     anotherBall.xScale = 1
end

function gameListeners(action)
     if(action == "add") then
          Runtime:addEventListener("accelerometer", moveMonester)
          Runtime:addEventListener("enterFrame", update)
          blockTimer = timer.performWithDelay(1000, addBlock, 0)
          liveTimer = timer.performWithDelay(10000, addLivePowerup, 0)
          --twoBallsPowerupTimer = timer.performWithDelay(6000, twoBallsPowerup, 0)
          ghostBallPowerupTimer = timer.performWithDelay(11000, ghostBallPowerup, 0)
          checkForGhostBallPowerupTimer = timer.performWithDelay(10000, ghostBallPowerupEffect, 0)

          ball:addEventListener("collision", collisionHandler)
          pauseButton:addEventListener("tap", pauseButtonEffect)
     elseif(action == "rmv") then
          Runtime:removeEventListener("accelerometer", moveMonester)
          Runtime:removeEventListener("enterFrame", update)
          timer.cancel(blockTimer)
          timer.cancel(liveTimer)
          --timer.cancel(twoBallsPowerupTimer)
          timer.cancel(ghostBallPowerupTimer)
          timer.cancel(checkForGhostBallPowerupTimer)
          blockTimer = nil
          liveTimer = nil
          --twoBallsPowerupTimer = nil
          ghostBallPowerupTimer = nil
          checkForGhostBallPowerupTimer = nil
          ball:removeEventListener("collision", collisionHandler)
          pauseButton:removeEventListener("tap", pauseButtonEffect)
     elseif(action == "pause") then
          timer.pause(blockTimer)
          timer.pause(liveTimer)
          timer.pause(ghostBallPowerupTimer)
          timer.pause(checkForGhostBallPowerupTimer)
     elseif(action == "resume") then
          timer.resume(blockTimer)
          timer.resume(liveTimer)
          timer.resume(ghostBallPowerupTimer)
          timer.resume(checkForGhostBallPowerupTimer)
     end     
end

function anotherBallGameListeners(action)
     if(action == "add") then
          Runtime:addEventListener("accelerometer", moveAnotherBall)
          Runtime:addEventListener("enterFrame", updateAnotherBall)
          if(firstBallDead == true) then
               blockTimer = timer.performWithDelay(800, addBlock, 0)
               liveTimer = timer.performWithDelay(400, addLivePowerup, 0)
               twoBallsPowerupTimer = timer.performWithDelay(6000, twoBallsPowerup, 0)
               ghostBallPowerupTimer = timer.performWithDelay(12000, ghostBallPowerup, 0)
          end
          anotherBall:addEventListener("collision", collisionHandler)
     else
          Runtime:removeEventListener("accelerometer", moveAnotherBall)
          Runtime:addEventListener("enterFrame", updateAnotherBall)
          if(firstBallDead == true) then
               timer.cancel(blockTimer)
               timer.cancel(liveTimer)
               timer.cancel(twoBallsPowerupTimer)
               timer.cancel(ghostBallPowerupTimer)
               blockTimer = nil
               liveTimer = nil
               twoBallsPowerupTimer = nil
               ghostBallPowerupTimer = nil
          end
          anotherBall:removeEventListener("collision", collisionHandler)
     end     
end

function update(e)
if(paused == false) then
     if(ghostBallPowerupActive == false) then
          physics.addBody(ball, {denisty = ballDenisty, bounce = 0, radius = 24})
     end
     if(ghostBallPowerupActive == true) then
          physics.removeBody(ball)
          --ball.y = ball.y + 4
          moveSpeed = moveSpeed + 0.1
     end

     -- Screen Borders
     if(ball.x <= 0) then --Left
          --ball.x = 0
          ball.x = display.contentWidth * 0.75
     --elseif(ball.x >= (display.contentWidth - ball.width)) then --right
     elseif(ball.x >= (display.contentWidth)) then --right
          --ball.x = display.contentWidth - ball.width
          --ball.x = 0
          ball.x = display.contentWidth * 0.25
     end

     if(ball.y > display.contentHeight) then
          ball.y = display.contentHeight
     end
     
     for i = 1, blocks.numChildren do
          --Blocks Movement
          blocks[i].y = blocks[i].y - moveSpeed
     end

     --Score
     score = score + 1
     scoreTF.text = score

     --Lose Lives
     if(ball.y < -5) then
          ball.x =  blocks[blocks.numChildren - 1].x
          ball.y = blocks[blocks.numChildren - 1].y - ball.height
          lives = lives - 1
          livesTF.text = 'x' .. lives
     end

     --Check for game over
     if(lives == 0) then
          firstBallDead = true
          showAlert()
     end

     --Levels
     if(score < 500) then
          --Player Movement
          ball.y = ball.y + 2
     end

     if(score > 500 and score < 502) then
          moveSpeed = 3
          ball.y = ball.y + 2
     end

     if(score > 1000 and score < 1002) then
          moveSpeed = 4
          ball.y = ball.y + 2
     end

     if(score > 2000 and score < 2002) then
          moveSpeed = 5
          ball.y = ball.y + 2
     end

     if(score > 3000 and score < 3002) then
          moveSpeed = 6
          ball.y = ball.y + 2
     end 
end
end

function updateAnotherBall(e)
     -- Screen Borders
     if(anotherBall.x <= 0) then --Left
          anotherBall.x = 0
     elseif(anotherBall.x >= (display.contentWidth - anotherBall.width)) then --right
          anotherBall.x = display.contentWidth - anotherBall.width
     end

     --Score
     score = score + 1
     scoreTF.text = score

     --Lose Lives
     if(firstBallDead == true) then
          if(anotherBall.y > display.contentHeight or anotherBall.y < -5) then
               anotherBall.x =  blocks[blocks.numChildren - 1].x
               anotherBall.y = blocks[blocks.numChildren - 1].y - anotherBall.height
               lives = lives - 1
               livesTF.text = 'x' .. lives
          end

          --Check for game over
           if(lives == 0) then
               showAlert()
          end
     end
end

function showAlert()
     gameListeners("rmv")

     local alert = display.newImage("alertBg.png", 70, 190)

     alertScore = display.newText(scoreTF.text .. "!", 134, 240, native.systemFontBold, 30)
     livesTF.text = ""

     transition.from(alert, {time = 200, xScale = 0.8})
end

function addLivePowerup()
     if(ball.y < (display.contentHeight * 0.5)) then
          live = display.newImage("live.png")

          live.name = "live"
          live.x = blocks[blocks.numChildren - 1].x
          live.y = blocks[blocks.numChildren - 1].y - live.height

          physics.addBody(live, {denisty = 1, friction = 0, bounce = 0})
     end
end

function twoBallsPowerup()
     twoBalls = display.newImage("twoBallsPowerup.png")

     twoBalls.name = "twoBallsPowerup"
     twoBalls.x = blocks[blocks.numChildren - 1].x
     twoBalls.y = blocks[blocks.numChildren - 1].y - twoBalls.height

     physics.addBody(twoBalls, {denisty = 1, friction = 0, bounce = 0})
end

function ghostBallPowerup()
     if(ball.y < (display.contentHeight * 0.5)) then
          ghostBall = display.newImage("ghost.png")

          ghostBall.name = "ghostBallPowerup"

          ghostBall.x = blocks[blocks.numChildren - 1].x + 1
          ghostBall.y = blocks[blocks.numChildren - 1].y - ghostBall.height

          physics.addBody(ghostBall, {denisty = 1, friction = 0, bounce = 0})  

          if(ghostBall.y == live.y) then
               display.remove(ghostBall)
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
     moveSpeed = moveSpeedWhenGhostBallPowerupTaken
     ball.y = ball.y + 2
end

function collisionHandler(e)
     --Regular Blocks
     if(e.other.name == "block") then
          e.other.name = "busyBlock"
     end

     --Bad Block
     if(e.other.name == "bad") then
          ball:applyForce(0, -0.4, ball.x, ball.y)
          --ball:setLinearVelocity(0, -1)
          --lives = lives - 1
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

     --twoBallsPowerup
     if(e.other.name == "twoBallsPowerup") then
          display.remove(e.other)
          e.other = nil
          twoBallsPowerupIsTaken = true
          lives = lives * 2
          livesTF.text = "x" .. lives
          addAnotherBall()
     end

     --ghostBallPowerup
     if(e.other.name == "ghostBallPowerup") then
          display.remove(e.other)
          e.other = nil

          ghostBallPowerupActive = true
          ghostBallPowerupStartTime = os.time()
          moveSpeedWhenGhostBallPowerupTaken = moveSpeed
          --local timerID = timer.performWithDelay(0, moveThroughBlocks(true), 1)
          --ghostBallPowerupTimerTable[timerID] = {startTime = system.getTimer(), remainingTime = 5000}

          --for timerID, timerData in pairs(timersData) do
               --timer.cancel(timerID)
          --end

          --local currentTime = system.getTimer()
          --local elapsedTime = currentTime - timerData.startTime

          --if(elapsedTime == 5000) then
               --moveThroughBlocks(false)
          --end
     end          
end

Main()















