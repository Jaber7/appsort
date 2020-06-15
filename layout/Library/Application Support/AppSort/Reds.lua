function sort(apps)
	a = {}
	appcount = #apps
	currentColor = tonumber("FF",16)
	i = 1
	while i <= appcount do
		for key,table in ipairs(apps) do
			x = tonumber(string.sub(table["color"],5,6),16) - tonumber(string.sub(table["color"],1,2),16)
			if x == currentColor then
				a[i] = table
				print(a[i]["color"], a[i]["id"])
				i = i + 1
			end
		end
		currentColor = currentColor - 1
	end
	apps = a
	table.sort(apps, function(app1, app2) return cap(app1) < cap(app2) end)
	return apps
end

function cap(str)
    return  tonumber(string.sub(str["color"],1),16)
end
