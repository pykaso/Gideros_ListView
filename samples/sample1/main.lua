application:setOrientation(Application.PORTRAIT) 

font = TTFont.new("resources/fonts/Roboto-Medium-webfont.ttf", 20)
fontSub = TTFont.new("resources/fonts/Roboto-Medium-webfont.ttf", 12)

local ListView = require("ui/ListView")
local info = TextField.new(font, "Selected row")
local infoSub = TextField.new(fontSub, "Click to arrow icon")

local data = loadRowData()

function updateInfo(item)
	info:setText(item.text)
	infoSub:setText(item.desc or "")
	
	info:setPosition((application:getContentWidth() - info:getWidth())/2, 600)
	infoSub:setPosition((application:getContentWidth() - infoSub:getWidth())/2, 660)

	myList:getFirstVisibleRow()
end


myList = ListView.new({
	width=280,
	height=390,	
	bgTexture = Texture.new("resources/images/texture.png"),
	-- rowSnap = true, -- experimental feature
	data=data
})
myList:setPosition(100,100)
stage:addChild(myList)

stage:addChild(Bitmap.new(Texture.new("resources/images/bg.png")))

local title = TextField.new(font, "Gideros ListView widget sample1")
title:setPosition((application:getContentWidth() - title:getWidth())/2, 60)
stage:addChild(title)

info:setPosition((application:getContentWidth() - info:getWidth())/2, 600)
stage:addChild(info)

infoSub:setPosition((application:getContentWidth() - infoSub:getWidth())/2, 660)
stage:addChild(infoSub)


