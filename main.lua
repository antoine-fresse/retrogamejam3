require "conf"
vector = require "vector"

local car 					= { name = "Car" }
car.rotationSpeed 			= 1000
car.speed 					= 10
car.x, car.y, car.w, car.h 	= 50, 50, 20, 10
car.bonet					= {}
car.bonet.w, car.bonet.h 	= 20, 5



function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)

	objects					= {}
	objects.car 			= {}
	objects.car.body 		= love.physics.newBody(world, car.x, car.y, "dynamic")
	objects.car.shape 		= love.physics.newRectangleShape(car.w, car.h)
	objects.car.bonetShape 	= love.physics.newPolygonShape(
		car.bonet.h, -car.h / 2,
		car.w / 2, -car.h / 2, 
		car.w / 2, car.h / 2, 
		car.bonet.h, car.h / 2)
	objects.car.fixture 	= love.physics.newFixture(objects.car.body, objects.car.shape, 0.1)
	objects.car.newFixture	= love.physics.newFixture(objects.car.body, objects.car.bonetShape, 0)
	objects.car.body:setAngularDamping(5)
end


function love.update(dt)
	world:update(dt)

	if love.keyboard.isDown("right") then
		car.rotation = car.rotationSpeed
		rotatePlayer(car, dt)
	elseif love.keyboard.isDown("left") then
		car.rotation = -car.rotationSpeed
		rotatePlayer(car, dt)
	else
		car.rotation = 0
	end

	if love.keyboard.isDown("up") then
		car.v = vector(car.x * car.speed, 0):rotated(objects.car.body:getAngle())
		movePlayer(car, dt)
	elseif love.keyboard.isDown("down") then
		car.v = vector(car.x * car.speed, 0):rotated(objects.car.body:getAngle()) * -1
		movePlayer(car, dt)
	end	
end


function rotatePlayer(player, dt)
	objects.car.body:applyTorque(player.rotation * dt)
end


function movePlayer(player, dt)
	objects.car.body:applyForce(player.v.x * dt, player.v.y * dt)
end


local function drawPlayer()
	love.graphics.setColor(255, 255, 255)
	love.graphics.polygon("line", objects.car.body:getWorldPoints(objects.car.shape:getPoints()))
	love.graphics.setColor(255, 0, 0)
	love.graphics.polygon("line", objects.car.body:getWorldPoints(objects.car.bonetShape :getPoints()))
end	


function love.draw()
    drawPlayer()
end