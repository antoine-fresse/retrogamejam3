local city = {}
local block_size = 128
city.buildings = {}

function city:generateBlock(x,y)

	local startX = x*block_size
	local startY = y*block_size

	for j=0,block_size do
		for i=0,block_size do
			local amp =  love.math.noise(startX + i, startY + j)
			if amp > 0.98 then
				local w = 5 + (amp-0.98)*10
				local h = 10 - (amp-0.98)*10


				w=1
				h=1
				table.insert(city.buildings, {x=startX+i-w/2, y=startY+j-h/2, w=w, h=h})
			end
		end
	end
end


function city:generateCity()
	self.rng = love.math.newRandomGenerator()

	city.streets = {}

	local main_street = {}
	table.insert(city.streets, main_street)

	main_street.depth = 0
	main_street.orientation = city.rng:random(0,1)
	main_street.spaceAfter = 2000
	local length = city.rng:random(750,1250)
	main_street.length = length
	if main_street.orientation == 0 then
		main_street.startPos = vector(-length, 0)
		main_street.endPos = vector(length, 0)
	else
		main_street.startPos = vector(0, -length)
		main_street.endPos = vector(0, length)
	end

	self:growStreet(main_street)

end

function city:growStreet(street)

	if(street.depth >= 4) then return end


	local new_streets_count = city.rng:random(2,5)

	local new_streets_pos = {}

	local spaceLeft = street.length
	local avg_space = spaceLeft / new_streets_count
	
	while(spaceLeft>0) do
		local space = city.rng:random(avg_space/2,avg_space)
		spaceLeft = spaceLeft - space
		table.insert(new_streets_pos, space)
	end

	local newStreets = {}
	new_streets_count =  #new_streets_pos - 1 


	local prev_street = nil
	local acc=0
	for i=1,new_streets_count do
		
		local sub_street = {}
		sub_street.depth = street.depth+1
		sub_street.length = street.spaceAfter
		if(i<new_streets_count) then
			sub_street.spaceAfter = acc + new_streets_pos[i+1]
		else
			sub_street.spaceAfter = street.length-acc
		end
		prev_street = sub_street
		
		acc = acc + new_streets_pos[i]
		if street.orientation == 0 then
			sub_street.startPos = vector(street.startPos.x+acc, street.startPos.y)
			sub_street.endPos = vector(street.startPos.x+acc, street.startPos.y+street.spaceAfter)
			sub_street.orientation = 1
		else
			sub_street.startPos = vector(street.startPos.x, street.startPos.y+acc)
			sub_street.endPos = vector(street.startPos.x+street.spaceAfter, street.startPos.y+acc)
			sub_street.orientation = 0
		end

		


		table.insert(self.streets, sub_street)

		self:growStreet(sub_street)
		
	end


end

function city:draw(cam)
	love.graphics.setColor(0,255,0)
	love.graphics.rectangle("fill", 0, 0, 200, 200)
	love.graphics.setColor(0,0,0)
	cam:attach()
	for i,v in ipairs(self.buildings) do
		love.graphics.rectangle("fill", v.x, v.y , v.w , v.h)
	end

	
	for i,v in ipairs(self.streets) do
		love.graphics.setColor((1-v.orientation)*(255-v.depth*50),0,v.orientation*(255-v.depth*50))
		love.graphics.line(v.startPos.x, v.startPos.y, v.endPos.x, v.endPos.y)
	end
	cam:detach()



end

return city