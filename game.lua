local game = {}


function game:keyreleased(key, code)
	if key == 'escape' then
		love.event.quit()
	end
end

function preSolve(fixture_a, fixture_b, contact)

	local car = fixture_a:getUserData() == game.entities.car and fixture_a or nil
	car = fixture_b:getUserData() == game.entities.car and fixture_b or car

	if car == nil then return end

	local other = car == fixture_a and fixture_b or fixture_a

	local otherData = other:getUserData()

	if(otherData ~= nil) then
		local speed = vector(car:getBody():getLinearVelocity()):len()
		if otherData.type == 'wall' and  speed > 75 then
			contact:setEnabled(false)
			game.toDelete[otherData] = otherData
			car:getBody():applyLinearImpulse((vector(contact:getNormal())*speed/5000):unpack())
			--table.insert(game.toDelete, otherData)
		end
	end

end

function game:enter()
	self.entities = {}
	self.toDelete = {}
	phy.setMeter(64)


	self.world = phy.newWorld(0,0,true)


	self.world:setCallbacks(nil,nil,preSolve,nil)

	self.startpos = vector()
	self:load_map("images/area/map1.tga", 100,100)


	self.cam = Camera(self.startpos:unpack())

	local car = {}

	car.w = 20
	car.h = 10
	car.bonet_w = 20
	car.bonet_h = 5
	car.speed = 200
	car.steering_speed = 300
	car.type = 'car'
	car.shapes = {}

	car.body 		= phy.newBody(self.world, self.startpos.x, self.startpos.y, "dynamic")
	car.shapes.shape 		= phy.newRectangleShape(20, 10)
	car.fixture = phy.newFixture(car.body, car.shapes.shape, 0.1)

	car.fixture:setUserData(car)
	car.color = {255,255,255}
	car.mode = "line"

	-- car.shapes.bonetShape 	= phy.newPolygonShape(
	-- 	car.bonet_h, -car.h / 2,
	-- 	car.w / 2, -car.h / 2, 
	-- 	car.w / 2, car.h / 2, 
	-- 	car.bonet_h, car.h / 2)
	-- car.bonetFixture = phy.newFixture(car.body, car.shapes.bonetShape, 0)
	-- car.bonetFixture:setUserData(car)


	car.body:setAngularDamping(2)
	car.body:setLinearDamping(0.5)
	self.entities.car = car

	

end


	
function game:create_wall(x,y,w,h)
	local wall = {}

	wall.w = w
	wall.h = h

	wall.body = phy.newBody(self.world, x, y, "static")
	wall.shapes = {}
	wall.shapes.shape 		= phy.newRectangleShape(w, h)
	wall.color = {0,255,0}
	wall.mode = "fill"
	wall.fixture 	= phy.newFixture(wall.body, wall.shapes.shape, 0.1)
	wall.fixture:setUserData(wall)
	wall.type = 'wall'
	return wall
end

function game:load_map(file, gx,gy)
	local img = love.image.newImageData(file)
	local mult = 32
	local div = 4

	local block_size = mult/div

	for y=0,img:getHeight()-1 do
		for x=0,img:getWidth()-1 do
			local r,g,b = img:getPixel(x,y)

			if r==255 and g==0 and b==0 then
				
				for i=0,div-1 do
					for j=0,div-1 do
						table.insert(self.entities, self:create_wall(gx + x*mult + i*block_size, gy+ y*mult + j*block_size, block_size, block_size))
					end
				end
				
			else if r==0 and g==255 and b==0 then
				self.startpos = vector(gx+(x+0.5)*mult,gy+(y+0.5)*mult)
			end



			end
		end
	end
end


function game:update(dt)
	local v_arrows = vector()
	local car_pos = vector(self.entities.car.body:getWorldPoints(0,0))
	local car_front = vector(self.entities.car.body:getWorldPoints(1,0))

	local forward_force = 0

	if kb.isDown("up") then 
		forward_force = forward_force + self.entities.car.speed
	end

	if(kb.isDown("down")) then
		forward_force = forward_force - self.entities.car.speed/2
	end
	
	
	local left = kb.isDown("left")
	local right = kb.isDown("right")
	if left or right then
		if left then 
			self.entities.car.body:applyTorque(-self.entities.car.steering_speed*dt)
		end
		if right then 
			self.entities.car.body:applyTorque(self.entities.car.steering_speed*dt) 
		end
		forward_force = forward_force + self.entities.car.speed / 5
	end
	if forward_force ~= 0 then
		self.entities.car.body:applyForce(((car_front-car_pos)*dt*forward_force):unpack())
	end
	self.world:update(dt)

	self.cam:lookAt(self.entities.car.body:getX(), self.entities.car.body:getY())

	local speed = vector(self.entities.car.body:getLinearVelocity()):len()

	speed = math.min(speed, 100)

	local current_scale = self.cam.scale
	local target_scale = 1/(speed/100+1);

	self.cam:zoomTo(current_scale + (target_scale-current_scale)*dt)
	for k,v in pairs(self.toDelete) do
		v.body:destroy()
		for i,v2 in ipairs(self.entities) do
			if(v==v2) then
				table.remove(self.entities, i)
				break
			end
		end
	end
	self.toDelete = {}
end

function game:draw()
	gfx.setColor(255,128,128)
	

	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.polygon("line", game.entities.car.body:getWorldPoints(game.entities.car.shapes.shape:getPoints()))
	-- love.graphics.setColor(255, 0, 0)
	-- love.graphics.polygon("line", game.entities.car.body:getWorldPoints(game.entities.car.shapes.bonetShape :getPoints()))

	self.cam:attach()
	for k,v in pairs(self.entities) do
		gfx.setColor(unpack(v.color))

		for k2,s in pairs(v.shapes) do
			gfx.polygon(v.mode and v.mode or "fill", v.body:getWorldPoints(s:getPoints()))
		end
	end
	self.cam:detach()
end

return game