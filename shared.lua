Job = {
	start = {-2239, 2754, 19}; -- Координаты где взять работу
	--take = {2180, -2256, 15}; -- Рядом с работой
	take = {-2230, 2764, 19}; -- Координаты где взять мешок
	put = {-2228, 2736, 19}; -- Координаты куда положить мешок
	money = 200; -- Сколько чеканных монет нужно заплатить за 1 груз
} 

function togggle(bool,this)
    setPedWeaponSlot(this, 0 ) -- Переключаем на фист(ган: Кулак)
	toggleControl(this, "jump", bool ) -- Блокируем/Разрешаем прыгать
	toggleControl(this, "fire", bool )  -- Блокируем/Разрешаем стрелять
	toggleControl(this, "sprint", bool ) -- Блокируем/Разрешаем бегать
    toggleControl(this, "enter_exit", bool ) -- Блокируем/Разрешаем Cесть в кар F
    toggleControl(this, "aim_weapon", bool ) -- Блокируем/Разрешаем ПКМ
	toggleControl(this, "next_weapon", bool ) -- Блокируем/Разрешаем менять оружие
    toggleControl(this, "previous_weapon", bool ) -- Блокируем/Разрешаем менять оружие
    toggleControl(this, "enter_passenger", bool ) -- Блокируем/Разрешаем Сесть на пассажирку    
end
