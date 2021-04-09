local mark = {
    [1] = createPickup(Job["start"][1],Job["start"][2],Job["start"][3],3,1275,0); -- Создаем пикап трудоустройства;
    [2] = createPickup(Job["take"][1],Job["take"][2],Job["take"][3],3,2060,0);    -- Пикап мешка который вращается
    [3] = createMarker(Job["put"][1],Job["put"][2],Job["put"][3] - 1,'cylinder',5); -- Создание чекпоинта для сдачи мешка
    [4] = createColSphere(Job["put"][1],Job["put"][2],Job["put"][3] - 1, 5)   
    
}

local blip = {
    [1] = createBlipAttachedTo(mark[1],42,2,255,0,0,255,0,500); -- Cоздаем метку о работе;
    [2] = createBlipAttachedTo (mark[2], 0,3 ); -- Cоздаем метку о поднятии мешка;
    [3] = createBlipAttachedTo (mark[3], 0,3 ); -- Cоздаем метку о тоам куда нести мешок;
    [4] = createBlipAttachedTo (mark[3], 0,3 ); -- Cоздаем метку о тоам куда нести мешок;
}
local workers = {}


function onResourceStart()
   for k, v in pairs(mark) do
        if k ~= 1 then 
            setElementVisibleTo(v, root, false)
            setElementVisibleTo(blip[k], root, false)
        end 
    end 
end

addEventHandler("onResourceStart",resourceRoot, onResourceStart)


addCommandHandler("user", function(player)
    outputChatBox("-------",player)
        for k, v in pairs(workers) do
            outputChatBox("List workers: "..k.name.." | step: "..v.step.." | $: "..v.cache,player)
        end 
        outputChatBox("-------",player)
end)


-- Трудоустройство/Увал
function StartJob(this)
    print('Попытка трудоустройства')

    -- Если нет в списке работников;
    if not workers[this] then 
        workers[this] = Loader(this)
    end
    
    local user = workers[this]

    if not user.status then 
        outputChatBox("#FFCC00• [Информация] #D5D5D5Вы успешно устроились на работу #75FF00\'Грузчика\'",this,255,255,255,true) 
        outputChatBox("#FFCC00• [Информация] #D5D5D5На карте отмечена красная метка, отправляйтесь к ней",this,255,255,255,true)
        user:start(); -- Начинаем работу;
        user:upgrade(); -- Обновляем счетчик;
        user:Marker(); -- Получаем инфу о пикапе с мешком;
    else
        user:stop(); -- Завершение работы
        workers[this] = nil
    end
end
addEventHandler("onPickupHit", mark[1] , StartJob)



-- Этап 2 (Поднятие мешка)
function eventTakeBadge(this)
    if not workers[this] then outputChatBox("#FFCC00• [Информация] #D5D5D5Вы тут не работаете",this,255,255,255,true)  return false end
    local user = workers[this];
    if user.step ~= 2 then outputChatBox("#FFCC00• [Информация] #D5D5D5Вам не сюда, смотрите на радар (#FF0000Красная метка)",this,255,255,255,true) return false end
    user:createObject() -- Создаем мешок
    user:upgrade(); -- Обновляем счетчик; 
    user:Marker(); -- Получаем инфу о пикапе с мешком;
end 
addEventHandler("onPickupHit", mark[2] , eventTakeBadge)


-- Мешок на складе
function puta(this)
    if not workers[this] then outputChatBox("#FFCC00• [Информация] #D5D5D5Вы тут не работаете",this,255,255,255,true)  return false end
    local user = workers[this];
    if user.step ~= 3 then return false end
    user:putObject(); -- Положили мешок;
    user:upgrade(); -- Обнуление; 
    user:Marker(); -- Новый маркер;
    user:giveCache(); -- Засчитываем +1 мешок
    outputChatBox("Количество мешков : #1FF000"..user.cache, user.player)
end 
addEventHandler('onColShapeHit',mark[4], puta)        -- Если мы встали на синий круг




addEventHandler( "onResourceStop", resourceRoot,
    function( resource )
        for k, v in pairs(workers) do
            if isElement(k) then
                v:stop(); -- Выдача ЗП при выкл ресурса
            end 
        end 
    end
)


function Loader(player)
    if not getElementData(player,'skin') then setElementData(player,'skin',getElementModel(player), false) end

    local st = {
        status = false; -- Status Job
        step = 1; -- Статус погрузки: 1 / 3 (1 - Доступ к поднятию | 2 - Доступ чтобы положить | 3 - Для выдачи денег)
        cache = 0; -- $$$$;
        player = player;
        badge;
        bone;
    }

    -- Начало работы
    function st:start()
        -- Cтатус работы
        self.status = not self.status
        -- Выдача скина id 260
        setElementModel(self.player, 260)
        -- Сброс багов анимок
        setPedAnimation(self.player,'CARRY','crry_prtial',0,false,false, false, false)
        return self.status
    end
    -- Окончание работы/Сбросить все
    function st:reset()
        -- Если есть обьекты
        if self.badge and isElement(self.badge) and type(self.badge) ~= "boolean" then 
            destroyElement(self.badge)
        end
        -- Если есть обьекты
        if self.bone and isElement(self.bone) and type(self.bone) ~= "boolean" then 
            destroyElement(self.bone)
        end 
        -- Cброс анимации;
        setPedAnimation(self.player,'CARRY','crry_prtial',0,false,false, false, false)
    end 
    -- Сброс все
    function st:stop()
        -- Возвращаем возможность бегать и т.п
        togggle(true,self.player)
        
        -- Cтатус работы
        self.status = false;
        -- Возврат его скина
        setElementModel(self.player, getElementData(player,'skin')) 
        -- Расчет ЗП
        local money = self.cache * Job["money"];
        print("[LOG]: "..getPlayerName(self.player).." завершил работу грузчика и получил: "..money.." $ ")
        -- Выдача денег;
        givePlayerMoney(self.player, money)

        -- Сброс анимок/обьектов;
        st:reset()
    end
    -- Обновление порядка
    function st:upgrade()
        -- Если отнес последний мешок;
        if self.step >= 3 then
            self.step = 1; 
            setElementVisibleTo(mark[4], self.player, false)
            setElementVisibleTo(mark[3], self.player, false)
            setElementVisibleTo(blip[3], self.player, false)
        end

        self.step = self.step + 1;
        return self.step
    end
    -- Маркеры
    function st:Marker()
        -- Делаем видимымми новые маркеры
       setElementVisibleTo(mark[self.step], self.player, true)
       setElementVisibleTo(blip[self.step], self.player, true) 

       -- Делаем скрытими старые маркеры
       setElementVisibleTo(mark[self.step - 1], self.player, false)
       setElementVisibleTo(blip[self.step - 1], self.player, false) 
    end

    -- создание мешка
    function st:createObject()
        togggle(false,self.player) -- Блокируем бег, оружие и прочее
        self.badge = createObject(2060,0,0,0) -- Создание мешка;
        setPedAnimation(self.player,'CARRY','liftup',1,false) -- Проигрываем анимацию поднятия мешка
        setTimer(function() -- Таймер на 1 секунду анимки
            setPedAnimation(self.player,'CARRY', 'crry_prtial',2,true,true,true) -- Анфриз игрока после анимки(без нее никак)
		end,1000,1)
        self.bone = exports.bone_attach:attachElementToBone(self.badge,self.player,11,-0.2,0.1,0,90,1,02.25,0.2) -- Прицепляем обьект на игрока, а именно на руку( id 11 )
    end 
    
    -- Обработка склада
    function st:putObject()
        setPedAnimation(player,'CARRY','putdwn',1,false) -- Анимация чтоб положить

        setTimer(function() -- Ждем 1 сек и отключаем се
            setPedAnimation(player,'CARRY','putdwn',0,false,false, false, false)
            togggle(true,player)
            st:reset()
        end,1000,1)

        -- Сбрасываем все лишнее
    
    end 

    function st:giveCache()
        self.cache = self.cache + 1
        return false;
    end 

    setmetatable(st, {})
    return st
end
