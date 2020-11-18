select Н_ОЦЕНКИ.КОД, Н_ВЕДОМОСТИ.ДАТА
    from Н_ОЦЕНКИ
        right join Н_ВЕДОМОСТИ
            on Н_ВЕДОМОСТИ.ОЦЕНКА = Н_ОЦЕНКИ.КОД
    where Н_ОЦЕНКИ.КОД = 'зачет'
        and Н_ВЕДОМОСТИ.ИД < 39921;