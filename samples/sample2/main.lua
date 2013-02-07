application:setOrientation(Application.PORTRAIT) 
local ListView = require("ui/ListView")

local data = {}
data[1] = box(300, 480, 25,  0xffffff)
data[2] = box(300, 480, 25, 0xffffff)
data[3] = box(300, 480, 25, 0xffffff)
data[4] = box(300, 480, 25, 0xffffff)

myList = ListView.new({
	width=480,
	height=700,
	friction = 0.97,
	bgTexture = Texture.new("resources/images/texture.png"),
	data=data
})
myList:setPosition(0,100)
stage:addChild(myList)

stage:addChild(Bitmap.new(Texture.new("resources/images/bg.png")))