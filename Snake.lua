function love.load()

    timer = 0

    directionQueue = {'right'}

    gridXCount = 20
    gridYCount = 15

    --establishing the movefood as a function to spawn someplace new after getting hit by snake
    function moveFood()
        local possibleFoodPositions = {}

        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true

                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                -- if possible then insert food location in open location
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        -- randomize the location for the food to go after it has deemed a spot is not occupied by the snake.
        foodPosition = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]
    end

    function reset()
        snakeSegments = {
        {x = 3, y = 1},
        {x = 2, y = 1},
        {x = 1, y = 1},
        }
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
        moveFood()
    end

    reset()

    snakeAlive = true
end

function love.update(dt)
    timer = timer + dt --dt stands for delta time which means the amount of time passed since last update called or roughly will move time by 1 second

        
        if snakeAlive then
            if timer >= 0.15 then
                timer = 0

        if #directionQueue > 1 then
            table.remove(directionQueue, 1)
        end

        local nextXPosition = snakeSegments[1].x
        local nextYPosition = snakeSegments[1].y

        if directionQueue[1] == 'right' then
            nextXPosition = nextXPosition + 1
            --telling the game to loop back to the far left if about to go off screen
            if nextXPosition > gridXCount then
                nextXPosition = 1
            end
        elseif directionQueue[1] == 'left' then
            nextXPosition = nextXPosition - 1
            --telling the game to loop back to the far right if about to go off screen
            if nextXPosition < 1 then
                nextXPosition = gridXCount
            end
        elseif directionQueue[1] == 'up' then
            nextYPosition = nextYPosition - 1
            --telling to loop the y to loop back down to the bottom once reach the very top stopping from going off screen
            if nextYPosition < 1 then
                nextYPosition = gridYCount
            end
        elseif directionQueue[1] == 'down' then
            nextYPosition = nextYPosition + 1
            --telling to loop the y to loop back up to the top once reach the very bottom stopping from going off screen
            if nextYPosition > gridYCount then
                nextYPosition = 1
            end
        end

        --if you can move the snake, then...
        local canMove = true

        for segmentIndex, segment in ipairs(snakeSegments) do
            if segmentIndex ~= #snakeSegments
            and nextXPosition == segment.x 
            and nextYPosition == segment.y then
                -- this stops the snake from being able to move around upon hitting something other than fruit
                canMove = false
            end
        end
        

        if canMove then
            table.insert(snakeSegments, 1, {
                x = nextXPosition, y = nextYPosition
            })

            --this code is to allowe the snake to eat the food, then have it spawn somewhere else randomly 
            if snakeSegments[1].x == foodPosition.x 
            and snakeSegments[1].y == foodPosition.y then
                moveFood()
            else 
                table.remove(snakeSegments)
            end
        else 
            --when the snake is not alive...
            snakeAlive = false
        end
    end

    -- makes the game stop for 2 seconds when crashes the snake to signify the game ended before restarting
    elseif timer >= 2 then
            -- reload the game because it crashed or game overed.
        reset()
    end
end

function love.keypressed(key)
    if key == 'right'
    -- if key is pressed right and not facing right already
    and directionQueue[#directionQueue] ~= 'right'
    -- and not facing left already
    and directionQueue[#directionQueue] ~= 'left' then
        -- then insert the direction right
        table.insert(directionQueue, 'right')
    
    elseif key == 'left'
    -- if key pressed left and not facing left already
    and directionQueue[#directionQueue] ~= 'left'
    -- and not facing right either
    and directionQueue[#directionQueue] ~= 'right' then
        -- then insert left into the queue for next move
        table.insert(directionQueue, 'left')

    elseif key == 'up'
    and directionQueue[#directionQueue] ~= 'up'
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif key == 'down'
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end


-- to create the grey background
function love.draw()

    local cellSize = 15

    love.graphics.setColor(.28, .28, .28)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        gridYCount * cellSize
    )

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(.6, 1, .32)
        -- if not alive then change color of the snake
        else 
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        drawCell(segment.x, segment.y)
    end

    love.graphics.setColor(1, .3, .3)
    drawCell(foodPosition.x, foodPosition.y)

end

