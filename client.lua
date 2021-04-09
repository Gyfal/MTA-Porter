
-- Создание текста на пикапе с возможность обходить обьект(Чтоб сквозь стены не смотреть)
function dxDrawTextOnElement(x,y,z,text,height,distance,R,G,B,alpha,size,font,offset)
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or 20
	local height = height or 1

	if (isLineOfSightClear(x, y, z, x2, y2, z2,true,false,false,false,false)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, offset and sy + offset or sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or "arial", "center", "top",false,false,false,true)
			end
		end
	end
end




addEventHandler("onClientRender", getRootElement(), 
function ()
	dxDrawTextOnElement(Job["start"][1],Job["start"][2],Job["start"][3],"Трудоустройство\nна работу грузчика",1,15,236,147,106,255,2,"default")
end)

