create index lab3i21 on Н_ЛЮДИ using btree (ИМЯ, ИД);
create index lab3i22 on Н_ОБУЧЕНИЯ using hash (ЧЛВК_ИД);
create index lab3i23 on Н_УЧЕНИКИ using hash (ЧЛВК_ИД, ГРУППА);
