push = require 'push'

class = require 'class'

require 'Ball'
require 'Paddle'

WIN_WIDTH = 1280
WIN_HEIGHT = 720

-- окно, после размытия пикселей
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 234

PADDLE_SPEED = 200


-- init function --
function love.load() 
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    small_font = love.graphics.newFont('font.ttf', 8)

    score_font = love.graphics.newFont('font.ttf', 32)

    largeFont = love.graphics.newFont('font.ttf', 16)

    love.graphics.setFont(small_font)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sound/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sound/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sound/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT,  WIN_WIDTH, WIN_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.window.setTitle('Pong')

    player1Score = 0
    player2Score = 0

    servePlayer = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt) 
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servePlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end

    elseif gameState == 'play' then
        if ball:collise(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            sounds["paddle_hit"]:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collise(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 5

            sounds["paddle_hit"]:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
    end

    if ball.y < 1 or ball.y > VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        sounds["wall_hit"]:play()
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

    isScore()
end

function love.keypressed(key) 
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' or gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            player1Score = 0
            player2Score = 0
            ball:resert()
            gameState = 'serve'
            if wonPlayer == 1 then
                servePlayer = 2
            else
                servePlayer = 1
            end

        else 
            gameState = 'start'
            
            ball:resert()
        end
    end
end

function love.draw() 
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(small_font)

    if gameState == 'start' then
        love.graphics.printf('Welcome!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('PLayer ' .. tostring(servePlayer) .. '\'s serve', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(wonPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(small_font)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(score_font)

    love.graphics.print(
        tostring(player1Score),
        VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3
    )

    love.graphics.print(
        tostring(player2Score),
        VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3
    )

    player1:render()

    player2:render()

    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(small_font)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function isScore()
    if ball.x < 0 then
        player2Score = player2Score + 1
        servePlayer = 1
        sounds["score"]:play()
        if player2Score == 10 then
            gameState = 'done'
            wonPlayer = 2
        else
            gameState = 'serve'
            ball:resert()
        end
    elseif ball.x > VIRTUAL_WIDTH then
        player1Score = player1Score + 1
        servePlayer = 2
        sounds["score"]:play()
        if player1Score == 10 then
            gameState = 'done'
            wonPlayer = 1
        else
            gameState = 'serve'
            ball:resert()
        end
    end
end