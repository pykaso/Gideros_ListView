local tableView = require("TableView")
application:setOrientation(Application.PORTRAIT) 

local data = {}
for i=1, 50 do
	data[i] = "List item ".. i
end

local myList = tableView.newList{
	debug=true,
	top=10,
	left=10,
	width=200,
	height=400,
	data=data,
	bgColor = 0xff00ff
	}

stage:addChild(myList)