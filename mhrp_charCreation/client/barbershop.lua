barberShops = {
	{1932.0756835938, 3729.6706542969, 32.844413757324},
	{-278.19036865234, 6228.361328125, 31.695510864258},
	{1211.9903564453, -472.77117919922, 66.207984924316},
	{-33.224239349365, -152.62608337402, 57.076496124268},
	{136.7181854248, -1708.2673339844, 29.291622161865},
	{-815.18896484375, -184.53868103027, 37.568943023682},
	{-1283.2886962891, -1117.3210449219, 6.9901118278503}
}



local addBlips = function()
	for _,barber in ipairs(barberShops) do
		blip = AddBlipForCoord(barber[1], barber[2], barber[2])
		SetBlipSprite(blip, 71)
		SetBlipColour(blip, 5)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Kinky Clipz")
		EndTextCommandSetBlipName(blip)
	end
end



addBlips() -- Start Blips on Resource Start