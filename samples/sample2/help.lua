font = TTFont.new("resources/fonts/Roboto-Medium-webfont.ttf", 28)
fontSub = TTFont.new("resources/fonts/Roboto-Medium-webfont.ttf", 20)

function box(w, h, padding, color)
	local outer = rect(w, h)
	local box = rect(w-padding*2, h-padding*2, color)
	box:setPosition(padding,padding)
	
	local maurice = Bitmap.new(Texture.new("resources/images/maurice.png"))
	maurice:setPosition(20,20)
	box:addChild(maurice)
	
	local name = TextField.new(font, "Maurice Moss")
	name:setPosition(140, 42)
	box:addChild(name)	
	
	local subrow = TextField.new(fontSub, "IT Department")
	subrow:setPosition(140, 70)
	box:addChild(subrow)	
	
	outer:addChild(box)
	return outer
end

--create rectangle
function rect(width, height, color)
	local shape = Shape.new()
	if(color ~= nil) then
		shape:setFillStyle(Shape.SOLID, color, 1)
	end
	shape:beginPath()
	shape:moveTo(0, 0)
	shape:lineTo(0, width)
	shape:lineTo(height, width)
	shape:lineTo(height, 0)
	shape:closePath()
	shape:endPath()
	return shape
end