### Сравнение двух версий объекта метаданных

Попеременно выргужает указанный объект метаданных в файлы и запускает средство сравнения для полученных данных
В качестве параметра нужно указать имя метаданного для выгрузки. Например: `Документ.уатПутевойЛист`  

В скрипте захардкожены следующие имена:

- __currentSet.json__ - файл с постоянными настройками запуска
- __ibs__ - каталог json-файлов с настройками каждой информационной базы
- __left__, __right__ - названия сравниваемых сторон

#### currentSet.json

```
{
    "path1C": { путь к запускаемому файлу платформы 1С },
    "leftIB" : { имя json файла с настройками ИБ из каталога ibs без расширения для левой стороны },
    "rightIB": { имя json файла с настройками ИБ из каталога ibs без расширения для правой стороны },
    "diffTool": { Командная строка запуска средства сравнения (WinMergeU) строки {LEFT} и {RIGHT} будут заменены описанием информационной базы}
}
```

#### файл описания информационной базы

```
{
    "description": { наименование информационной базы },
    "connString": { строка соединения с информационной базой },
    "suuser": { имя пользователя ИБ },
    "passwd": { пароль пользователя ИБ }
}
```
#### пример протокола запуска скрипта:

```
E:\1S\proj\mdComparation>oscript compare.bsl Документ.уатПутевойЛист
ИНФОРМАЦИЯ - Сравнение двух версий метаданных: "compare.bsl" Имя метаданного: Документ.уатПутевойЛист
ИНФОРМАЦИЯ - Выгружается МД из левой ИБ
ИНФОРМАЦИЯ - Выполняется выгрузка в файлы из left ИБSrvr=obr-app-11;Ref=mc_uat;
ИНФОРМАЦИЯ - Выгружается МД из правой ИБ
ИНФОРМАЦИЯ - Выполняется выгрузка в файлы из right ИБSrvr=obr-app-13;Ref=mc_uat_tst;
ИНФОРМАЦИЯ - Запускается средство сравнения - WinMergeU
```
