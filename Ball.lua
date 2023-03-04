Ball = class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:collise(Paddle)
    if self.x > Paddle.x + Paddle.width or self.x + self.width < Paddle.x then
        return false
    end

    if self.y > Paddle.y + Paddle.height or self.y + self.height < Paddle.y then
        return false
    end

    return true
end

function Ball:resert()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:update(dt)
    self.x = self.x + dt * self.dx
    self.y = self.y + dt * self.dy
end

function Ball:render() 
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
