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

    Варианты планов:

    |1|2|
    |:-:|:-:|
    |![](./p11.svg)|![](./p12.svg)|

    Второй план эффективнее: мы уменьшаем размер таблиц до соединения, поэтому само соединение выполняется
    значительно быстрее.
    На практике:
    | Запрос | Результат |
    |---|---|
    |`select count(*) from Н_ОЦЕНКИ;`|9|
    |`select count(*) from Н_ВЕДОМОСТИ;`|222440|
    |`select count(*) from Н_ОЦЕНКИ where КОД = 'зачет';`|1|
    |`select count(*) from Н_ОЦЕНКИ where ИД < 39921;`|0|
    |`select count(*) from Н_ОЦЕНКИ right join Н_ВЕДОМОСТИ on Н_ОЦЕНКИ.КОД = Н_ВЕДОМОСТИ.ОЦЕНКА;`|22240|
    Таким образом, если применять выборки до соединения,
    то мы сразу не получим ни одной ведомости, и соединение будет проходить по 0 строк.
    В первом же варианте сначала производится соединение, и только потом строки фильтруются до,
    как оказывается, ни одной.

    Создание индексов:
    ```sql
    create index lab3i11 on Н_ОЦЕНКИ using hash (КОД);
    create index lab3i12 on Н_ВЕДОМОСТИ using btree (ИД, ОЦЕНКА);
    ```
    При создании индексов второй план останется оптимальным, при этом ускорится,
    потому что при выборке база данных сможет находить крайние из совпадающих
    элементов и сразу брать весь диапазон значений.

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

    Варианты планов:

    |1|2|
    |:-:|:-:|
    |![](./p21.svg)|![](./p22.svg)|

    Второй план эффективнее: мы уменьшаем размер таблиц до соединения, поэтому само соединение выполняется
    значительно быстрее.
    На практике:
    | Запрос | Результат |
    |---|---|
    |`select count(*) from Н_ЛЮДИ;`|5118|
    |`select count(*) from Н_ОБУЧЕНИЯ;`|5021|
    |`select count(*) from Н_УЧЕНИКИ;`|23311|
    |`select count(*) from Н_ЛЮДИ where ИМЯ > 'Александр';`|4547|
    |`select count(*) from Н_ОБУЧЕНИЯ where ЧЛВК_ИД = 163276;`|1|
    |`select count(*) from Н_УЧЕНИКИ where ГРУППА = '1100';`|1468|
    |`select count(*) from Н_ЛЮДИ`<br>`inner join Н_ОБУЧЕНИЯ on Н_ЛЮДИ.ИД = Н_ОБУЧЕНИЯ.ЧЛВК_ИД`<br>`inner join Н_УЧЕНИКИ on Н_ЛЮДИ.ИД = Н_УЧЕНИКИ.ЧЛВК_ИД;`|23636|
    |`select count(*) from Н_ЛЮДИ`<br>`inner join Н_ОБУЧЕНИЯ on Н_ЛЮДИ.ИД = Н_ОБУЧЕНИЯ.ЧЛВК_ИД`<br>`where Н_ЛЮДИ.ИМЯ > 'Александр' and Н_ОБУЧЕНИЯ.ЧЛВК_ИД = 163276;`|1|

    Таким образом, если применять выборки до соединения,
    то мы получим только одну строку из Н_ОБУЧЕНИЯ, и только одну строку в соединении таблиц Н_ЛЮДИ и Н_ОБУЧЕНИЯ.
    Затем соединение с Н_УЧЕНИКИ уже не выдает ни одной строки.
    В первом же варианте сначала производится соединение, и только потом строки фильтруются до,
    как оказывается, ни одной.

    Создание индексов:
    ```sql
    create index lab3i21 on Н_ЛЮДИ using btree (ИМЯ, ИД);
    create index lab3i22 on Н_ОБУЧЕНИЯ using hash (ЧЛВК_ИД);
    create index lab3i23 on Н_УЧЕНИКИ using hash (ЧЛВК_ИД, ГРУППА);
    ```
    При создании индексов второй план останется оптимальным, при этом ускорится,
    потому что при выборке база данных сможет находить крайние из совпадающих
    элементов и сразу брать весь диапазон значений.

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

## Вывод
в данной лабораторной работе я анализировал производительность запросов к базе данных.
Для этого я составлял реляционные планы запросов, с помощью которых можно оценить
последовательность выборки и обработки данных и объем обработки на каждой итерации.
С помощью планов запросов я оценил, какие индексы таблиц будут полезны, чтобы оптимизировать запросы.
