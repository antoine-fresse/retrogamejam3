Gamestate = require 'gamestate'
vector = require 'vector'
Camera = require 'camera'
useful = require 'useful'
gfx = love.graphics
kb = love.keyboard
phy = love.physics

menu = {}
game = require 'game'



function menu:keyreleased(key, code)
	if key == 'escape' then
		love.event.quit()
	end
	if key == 'return' then
		Gamestate.switch(game)
	end
end


function menu:draw()
	local txt = "Atomic Driver 2 : Electric Boolaloo"
	local txt_w = gfx.getFont():getWidth(txt)
	local w,h = love.window.getWidth(), love.window.getHeight()
	gfx.print(txt, w/2 - txt_w/2, h/2)
end




function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
