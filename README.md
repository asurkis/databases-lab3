# Лабораторная работа № 3

Выполнил студент группы P33113 Суркис Антон Игоревич<br>
Преподаватель: Николаев Владимир Вячеславович

<u>Задание.</u>

По варианту, выданному преподавателем, составить и выполнить запросы к базе данных "Учебный процесс".

Команда для подключения к базе данных ucheb:

    psql -h pg -d ucheb

<u>Отчёт по лабораторной работе должен содержать:</u>
1. Текст задания.
1. Реализацию запросов на SQL.
1. Планы выполнения запросов.
1. Ответы на вопросы, представленные в задании.
1. Выводы по работе.

<u>Темы для подготовки к защите лабораторной работы:</u>
1. Индексы
1. Оптимизация запросов
1. Выбор плана выполнения запросов

## Вариант № 532685

Составить запросы на языке SQL (пункты 1-2).

Для каждого запроса предложить индексы, добавление которых уменьшит время выполнения запроса (указать таблицы/атрибуты, для которых нужно добавить индексы, написать тип индекса; объяснить, почему добавление индекса будет полезным для данного запроса).

Для запросов 1-2 необходимо составить возможные планы выполнения запросов. Планы составляются на основании предположения, что в таблицах отсутствуют индексы. Из составленных планов необходимо выбрать оптимальный и объяснить свой выбор.
Изменятся ли планы при добавлении индекса и как?

Для запросов 1-2 необходимо добавить в отчет вывод команды `EXPLAIN ANALYZE [запрос]`

Подробные ответы на все вышеперечисленные вопросы должны присутствовать в отчете (планы выполнения запросов должны быть нарисованы, ответы на вопросы - представлены в текстовом виде).

1. Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:<br>
    Таблицы: `Н_ОЦЕНКИ`, `Н_ВЕДОМОСТИ`.<br>
    Вывести атрибуты: `Н_ОЦЕНКИ.КОД`, `Н_ВЕДОМОСТИ.ДАТА`.<br>
    Фильтры (`AND`):
    1. `Н_ОЦЕНКИ.КОД = 'зачет'`.
    1. `Н_ВЕДОМОСТИ.ИД < 39921`.

    Вид соединения: `RIGHT JOIN`.

    ### Решение

    Запрос:
    ```sql
    select Н_ОЦЕНКИ.КОД, Н_ВЕДОМОСТИ.ДАТА
        from Н_ОЦЕНКИ
            right join Н_ВЕДОМОСТИ
                on Н_ВЕДОМОСТИ.ОЦЕНКА = Н_ОЦЕНКИ.КОД
        where Н_ОЦЕНКИ.КОД = 'зачет'
            and Н_ВЕДОМОСТИ.ИД < 39921;
    ```
    Вывод:

         КОД | ДАТА
        -----+------
        (0 rows)

    Запрос `EXPLAIN ANALYZE`:
    ```sql
    explain analyze verbose select Н_ОЦЕНКИ.КОД, Н_ВЕДОМОСТИ.ДАТА
    from Н_ОЦЕНКИ
        right join Н_ВЕДОМОСТИ
            on Н_ВЕДОМОСТИ.ОЦЕНКА = Н_ОЦЕНКИ.КОД
    where Н_ОЦЕНКИ.КОД = 'зачет'
        and Н_ВЕДОМОСТИ.ИД < 39921;
    ```
    Вывод:

         Nested Loop  (cost=0.42..8.36 rows=1 width=42) (actual time=0.020..0.020 rows=0 loops=1)
           Output: "Н_ОЦЕНКИ"."КОД", "Н_ВЕДОМОСТИ"."ДАТА"
           ->  Seq Scan on public."Н_ОЦЕНКИ"  (cost=0.00..1.11 rows=1 width=34) (actual time=0.013..0.014 rows=1 loops=1)
                 Output: "Н_ОЦЕНКИ"."КОД", "Н_ОЦЕНКИ"."ПРИМЕЧАНИЕ", "Н_ОЦЕНКИ"."СОРТ"
                 Filter: (("Н_ОЦЕНКИ"."КОД")::text = 'зачет'::text)
                 Rows Removed by Filter: 8
           ->  Index Scan using "ВЕД_PK" on public."Н_ВЕДОМОСТИ"  (cost=0.42..7.24 rowsactual time=0.003..0.003 rows=0 loops=1)
                 Output: "Н_ВЕДОМОСТИ"."ИД", "Н_ВЕДОМОСТИ"."ЧЛВК_ИД", "Н_ВЕДОМОСТИ"."НОМЕР_ДОКУМЕНТА", "Н_ВЕДОМОСТИ"."ОЦЕНКА", "Н_ВЕДОМОСТИ"."СРОК_СДАЧИ", "Н_ВЕДОМОСТ."ТВ_ИД", "Н_ВЕДОМОСТИ"."КТО_СОЗДАЛ", "Н_ВЕДОМОСТИ"."КОГДА_СОЗДАЛ", "Н_ВЕДОМОСТИ"."КТО_ИЗМЕНИЛ", "Н_ВЕДОМОСТИ"."КОГДА_ИЗМЕНИЛ", "Н_ВЕДОМОСТИ"."ВЕД_ИД", "Н_ВЕДОМОСТИ"."СОСТОЯНИЕ", "Н_ВЕДОМОСТИ"."ОТД_ИД", "Н_ВЕДОМОСТИ"."БУКВА", "Н_ВЕДОМОСТ"ПРИМЕЧАНИЕ", "Н_ВЕДОМОСТИ"."БАЛЛЫ"
                 Index Cond: ("Н_ВЕДОМОСТИ"."ИД" < 39921)
                 Filter: (("Н_ВЕДОМОСТИ"."ОЦЕНКА")::text = 'зачет'::text)
         Planning time: 0.398 ms
         Execution time: 0.102 ms

1. Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:

    Таблицы: `Н_ЛЮДИ`, `Н_ОБУЧЕНИЯ`, `Н_УЧЕНИКИ`.

    Вывести атрибуты: `Н_ЛЮДИ.ИМЯ`, `Н_ОБУЧЕНИЯ.ЧЛВК_ИД`, `Н_УЧЕНИКИ.НАЧАЛО`.

    Фильтры: (`AND`)
    1. `Н_ЛЮДИ.ИМЯ > 'Александр'`.
    1. `Н_ОБУЧЕНИЯ.ЧЛВК_ИД = 163276`.
    1. `Н_УЧЕНИКИ.ГРУППА = '1100'`.

    Вид соединения: `INNER JOIN`.

    ### Решение

    Запрос:
    ```sql
    select Н_ЛЮДИ.ИМЯ, Н_ОБУЧЕНИЯ.ЧЛВК_ИД, Н_УЧЕНИКИ.НАЧАЛО
        from Н_ЛЮДИ
            inner join Н_ОБУЧЕНИЯ
                on Н_ЛЮДИ.ИД = Н_ОБУЧЕНИЯ.ЧЛВК_ИД
            inner join Н_УЧЕНИКИ
                on Н_ЛЮДИ.ИД = Н_УЧЕНИКИ.ЧЛВК_ИД
        where Н_ЛЮДИ.ИМЯ > 'Александр'
            and Н_ОБУЧЕНИЯ.ЧЛВК_ИД = 163276
            and Н_УЧЕНИКИ.ГРУППА = '1100';
    ```
    Вывод:

         ИМЯ | ЧЛВК_ИД | НАЧАЛО
        -----+---------+--------
        (0 rows)

    Запрос `EXPLAIN ANALYZE`:
    ```sql
    select Н_ЛЮДИ.ИМЯ, Н_ОБУЧЕНИЯ.ЧЛВК_ИД, Н_УЧЕНИКИ.НАЧАЛО
    from Н_ЛЮДИ
        inner join Н_ОБУЧЕНИЯ
            on Н_ЛЮДИ.ИД = Н_ОБУЧЕНИЯ.ЧЛВК_ИД
        inner join Н_УЧЕНИКИ
            on Н_ЛЮДИ.ИД = Н_УЧЕНИКИ.ЧЛВК_ИД
    where Н_ЛЮДИ.ИМЯ > 'Александр'
        and Н_ОБУЧЕНИЯ.ЧЛВК_ИД = 163276
        and Н_УЧЕНИКИ.ГРУППА = '1100';
    ```
    Вывод:

         Nested Loop  (cost=0.42..8.36 rows=1 width=42) (actual time=0.020..0.020 rows=0 loops=1)
           Output: "Н_ОЦЕНКИ"."КОД", "Н_ВЕДОМОСТИ"."ДАТА"
           ->  Seq Scan on public."Н_ОЦЕНКИ"  (cost=0.00..1.11 rows=1 width=34) (actual time=0.013..0.014 rows=1 loops=1)
                 Output: "Н_ОЦЕНКИ"."КОД", "Н_ОЦЕНКИ"."ПРИМЕЧАНИЕ", "Н_ОЦЕНКИ"."СОРТ"
                 Filter: (("Н_ОЦЕНКИ"."КОД")::text = 'зачет'::text)
                 Rows Removed by Filter: 8
           ->  Index Scan using "ВЕД_PK" on public."Н_ВЕДОМОСТИ"  (cost=0.42..7.24 rowsactual time=0.003..0.003 rows=0 loops=1)
                 Output: "Н_ВЕДОМОСТИ"."ИД", "Н_ВЕДОМОСТИ"."ЧЛВК_ИД", "Н_ВЕДОМОСТИ"."НОМЕР_ДОКУМЕНТА", "Н_ВЕДОМОСТИ"."ОЦЕНКА", "Н_ВЕДОМОСТИ"."СРОК_СДАЧИ", "Н_ВЕДОМОСТ."ТВ_ИД", "Н_ВЕДОМОСТИ"."КТО_СОЗДАЛ", "Н_ВЕДОМОСТИ"."КОГДА_СОЗДАЛ", "Н_ВЕДОМОСТИ"."КТО_ИЗМЕНИЛ", "Н_ВЕДОМОСТИ"."КОГДА_ИЗМЕНИЛ", "Н_ВЕДОМОСТИ"."ВЕД_ИД", "Н_ВЕДОМОСТИ"."СОСТОЯНИЕ", "Н_ВЕДОМОСТИ"."ОТД_ИД", "Н_ВЕДОМОСТИ"."БУКВА", "Н_ВЕДОМОСТ"ПРИМЕЧАНИЕ", "Н_ВЕДОМОСТИ"."БАЛЛЫ"
                 Index Cond: ("Н_ВЕДОМОСТИ"."ИД" < 39921)
                 Filter: (("Н_ВЕДОМОСТИ"."ОЦЕНКА")::text = 'зачет'::text)
         Planning time: 0.398 ms
         Execution time: 0.102 ms
