--colors
local c = {}
	c[1]=0xEEE9BF
	c[2]=0xCDC9A5
	c[3]=0x8B8970
	c[4]=0xFFEC8B
	c[5]=0xEEDC82
	c[6]=0xCDBE70
	c[7]=0x8B814C
	c[8]=0xE3CF57
	c[9]=0xFFD700
	c[10]=0xEEC900
	c[11]=0xCDAD00
	c[12]=0x8B7500
	c[13]=0xFFF8DC
	c[14]=0xEEE8CD
	c[15]=0xCDC8B1
	c[16]=0x8B8878
	c[17]=0xDAA520
	c[18]=0xFFC125
	c[19]=0xEEB422
	c[20]=0xCD9B1D

--resources
_arrow = "resources/images/arrow_right.png"
_arrow_dw = "resources/images/arrow_right_down.png"


--create rectangle
function rect(w, h, color)
	local shape = Shape.new()
	if(color ~= nil) then
		shape:setFillStyle(Shape.SOLID, color, 1)
	end
	shape:beginPath()
	shape:moveTo(0, 0)
	shape:lineTo(0, w)
	shape:lineTo(h, w)
	shape:lineTo(h, 0)
	shape:closePath()
	shape:endPath()
	return shape
end

function row(item, index)
	local height, width = 48, 280
	if(index%4 == 0) then height = 80 end
	
	--fist 20 rows
	if(index<=20) then
		 item.color = 0xe6e6e6
	end
	local row = rect(height, width, item.color)
	
	local border1 = rect(1, width, 0x9e9e9e)
	local border2 = rect(1, width, 0xffffff)
	
	local t = TextField.new(font, item.text)
	t:setPosition(24, 30)
	
	local button = Button.new(Bitmap.new(Texture.new(_arrow)), Bitmap.new(Texture.new(_arrow_dw)))
	button:setPosition(width-48, height/2 - button:getHeight()/2 )
	button:addEventListener("click", 
	function()
		updateInfo(item)
	end)
	row:addChild(button)
	
	border1:setPosition(0, height-3)
	border1:setPosition(0, height-1)
	row:addChild(border1)
	row:addChild(border2)
	row:addChild(t)
	
	if(index%4 == 0) then
		local t2 = TextField.new(fontSub, item.desc)
		t2:setPosition(24,52)	
		row:addChild(t2)
	end
	
	return row
end


function loadRowData()
	local data = {}
	local ci = 1
	for i=1, 100 do
		data[i] = row({index = i, text = "List item ".. i,  desc = "Second line description ("..i..")",  color = c[ci]}, i)
		if ci == 20 then ci = 1 end
		ci = ci + 1
	end
	return data
end