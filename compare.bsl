#Использовать json
#Использовать logos
#Использовать v8runner

Перем Лог;
Перем Параметры;
Перем ИмяОбъектаМД;

Функция УбедитьсяВНаличииФайла(Путь, Фатально = Ложь)
	Лог.Отладка("Проверяю наличие файла "+Путь);
	ПроверкаФайла = Новый Файл(Путь);
	Если ПроверкаФайла.Существует() Тогда
		Возврат Истина;
	Иначе
		Если Фатально Тогда
			Лог.КритичнаяОшибка("Не обнаружен файл "+Путь);
			Exit(2);
		Иначе
			Лог.Ошибка("Не обнаружен файл "+Путь);
		КонецЕсли;
	Возврат Ложь;
	КонецЕсли;
КонецФункции

Процедура Инициализация()
	Если АргументыКоманднойСтроки.Количество() = 0 Тогда
		Лог.КритичнаяОшибка("Требуется параметр - полное имя объекта метаданных");
		Exit(5);
	Иначе
		ИмяОбъектаМД = АргументыКоманднойСтроки[0];
	КонецЕсли;
	
	Скрипт = СтрЗаменить(СтартовыйСценарий().Источник, СтартовыйСценарий().Каталог+"\", "");
	Лог.Информация("Сравнение двух версий метаданного: """+Скрипт+""" Имя метаданного: "+ИмяОбъектаМД);
	Лог.Отладка("Очищаю каталог left");
	Попытка
		УдалитьФайлы("left", "*.*");
	Исключение
	КонецПопытки;
	Лог.Отладка("Очищаю каталог right");
	Попытка
		УдалитьФайлы("right", "*.*");			
	Исключение
	КонецПопытки;

	УбедитьсяВНаличииФайла("./currentSet.json", Истина);
	ЧтениеТекста = Новый ЧтениеТекста("./currentSet.json", КодировкаТекста.UTF8);
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Парсер = Новый ПарсерJSON();
	Параметры = Парсер.ПрочитатьJSON(СтрокаJSON);

	УбедитьсяВНаличииФайла(ОбъединитьПути("ibs",Параметры["leftIB"]+".json"), Истина);
	ЧтениеТекста = Новый ЧтениеТекста(ОбъединитьПути("ibs",Параметры["leftIB"]+".json"), КодировкаТекста.UTF8);
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Парсер = Новый ПарсерJSON();
	ЛеваяИБ = Парсер.ПрочитатьJSON(СтрокаJSON);
	Для Каждого эл Из ЛеваяИБ Цикл
		Параметры.Вставить("left."+эл.Ключ, эл.Значение)
	КонецЦикла;

	УбедитьсяВНаличииФайла(ОбъединитьПути("ibs",Параметры["rightIB"]+".json"), Истина);
	ЧтениеТекста = Новый ЧтениеТекста(ОбъединитьПути("ibs",Параметры["rightIB"]+".json"), КодировкаТекста.UTF8);
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Парсер = Новый ПарсерJSON();
	ПраваяИБ = Парсер.ПрочитатьJSON(СтрокаJSON);
	Для Каждого эл Из ПраваяИБ Цикл
		Параметры.Вставить("right."+эл.Ключ, эл.Значение)
	КонецЦикла;

	Лог.Отладка("Прочитанные параметры:");
	 Для Каждого эл Из Параметры Цикл
		Лог.Отладка(""+эл.Ключ+" = ("+Параметры[эл.Ключ]+")");
		Если ТипЗнч(Параметры[эл.Ключ]) = Тип("Соответствие") Тогда
			ВеткаПараметров = Параметры[эл.Ключ];
			Для Каждого нн Из ВеткаПараметров Цикл
				Лог.Отладка("    "+нн.Ключ+" = ("+ВеткаПараметров[нн.Ключ]+")");
			КонецЦикла;
		КонецЕсли;
	 КонецЦикла;
	
	Запись = Новый ЗаписьТекста("md.lst", "utf-8");
	Запись.Записать(ИмяОбъектаМД);
	Запись.Закрыть();
	УточнитьПаролиВПараметрах();
КонецПроцедуры

Процедура УточнитьПаролиВПараметрах()
	Лог.Отладка("Получаю пароли из переменных среды при необходимости");
	МассивТребующихУточнения = Новый Массив;
	Для Каждого эл Из Параметры Цикл
		Если СтрНачинаетсяС(эл.Значение, "env:") Тогда 
			МассивТребующихУточнения.Добавить(эл);
		КонецЕсли;
	КонецЦикла;
	Для Каждого мм Из МассивТребующихУточнения Цикл
		Прм = ПолучитьПеременнуюСреды(СтрЗаменить(мм.Значение, "env:", ""));
		Параметры[мм.Ключ] = Прм;
	КонецЦикла;
КонецПроцедуры

Функция ВыгрузитьМетаданные(Сторона)
	ЛевыйКонфигуратор = Новый УправлениеКонфигуратором;
	ЛевыйКонфигуратор.ИспользоватьВерсиюПлатформы("8.3.12");
	ЛевыйКонфигуратор.УстановитьКонтекст("/IBConnectionString "+Параметры[Сторона+".connString"], Параметры[Сторона+".suuser"], Параметры[Сторона+".passwd"]);
	ПараметрыЗапуска = ЛевыйКонфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/DumpConfigToFiles """+Сторона+""" -listFile ""md.lst"""); 
	
	Лог.Информация("Выполняется выгрузка в файлы из "+Сторона+" ИБ "+Параметры[Сторона+".connString"]);

	Попытка
		ЛевыйКонфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Возврат 0;
	Исключение
		Лог.Ошибка(ЛевыйКонфигуратор.ВыводКоманды());
		Возврат 3;
	КонецПопытки;
КонецФункции

Процедура Выполнение()
	Лог.Информация("Выгружается МД из левой ИБ");
	Если ВыгрузитьМетаданные("left") > 0 Тогда
		Лог.Ошибка("Завершение из-за неудачной выгрузки левой ИБ");
		Exit(3);
	КонецЕсли;

	Лог.Информация("Выгружается МД из правой ИБ");
	Если ВыгрузитьМетаданные("right") > 0 Тогда
		Лог.Ошибка("Завершение из-за неудачной выгрузки правой ИБ");
		Exit(3);
	КонецЕсли;
	КомСтрока = СтрЗаменить(Параметры["diffTool"], "{LEFT}", """"+Параметры["left.description"]+"""");
	КомСтрока = СтрЗаменить(КомСтрока, "{RIGHT}", """"+Параметры["right.description"]+"""");
	Лог.Информация("Запускается средство сравнения - WinMergeU");
	ЗапуститьПриложение(КомСтрока);
КонецПроцедуры
////////////////////////////////////////////////////////////////////////////
Лог = Логирование.ПолучитьЛог("MDcompare");
Лог.УстановитьУровень(УровниЛога.Информация);
Инициализация();
Выполнение();
