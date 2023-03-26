--views:
--view 1:
exec melopack.performer_proc('Begga Ruiz')

CREATE OR REPLACE VIEW my_albums AS (select performer,pair,sumation from (select pair, sum(duration) sumation from tracks group by pair) 
NATURAL JOIN (select pair, performer from albums) where performer = melopack.get_current_performer) WITH READ ONLY;


--queries1:

select pair, sum(duration) sumation from tracks group by pair;
select performer,pair,sumation from (select pair, sum(duration) sumation from tracks group by pair) 
NATURAL JOIN (select pair, performer from albums) fetch next 50 rows only;

--view2:
CREATE OR REPLACE VIEW events AS (select to_char(when,'MM-YY') date_event,count('x') nconcerts,avg(nperformances) avgperformances,sum(attendance) sumatt, avg(duration) avgdur
from (select performer,when,attendance,duration from concerts)
NATURAL JOIN (select count('x') nperformances,performer, when from performances group by(performer,when)) 
group by to_char(when,'MM-YY')) WITH READ ONLY;
--queries2:

select to_char(when,'MM-YY'),count('x') nconcerts,sum(attendance), avg(duration) from concerts group by to_char(when,'MM-YY') fetch next 50 rows only;



select to_char(when,'MM-YY'),count('x') nconcerts,avg(nperformances),sum(attendance), avg(duration) 
from (select performer,when,attendance,duration from concerts)
NATURAL JOIN (select count('x') nperformances,performer, when from performances group by(performer,when)) 
group by to_char(when,'MM-YY') fetch next 50 rows only;






--view 3
CREATE OR REPLACE VIEW fans AS (select distinct e_mail,name,surn1,surn2,(abs(MONTHS_BETWEEN(birthdate,sysdate))/12) age from(
(select e_mail, name, surn1,surn2, birthdate from clients)
NATURAL JOIN
(select client e_mail from attendances where performer = melopack.get_current_performer group by client having count('x')>1)));

--table for banned fans
Create table banned_fans(
	e_mail varchar2(100) NOT NULL,
	performer varchar2(50) NOT NULL,
	CONSTRAINT PK_banned_fans PRIMARY KEY(e_mail),
    CONSTRAINT FK_Clients20 FOREIGN KEY (e_mail) REFERENCES CLIENTS,
    CONSTRAINT FK_Performer20 FOREIGN KEY (performer) REFERENCES performers
);

--Trigger for del
Create or replace Trigger del_fan
instead of delete on fans 
for each row
begin
    insert into banned_fans(e_mail,performer) values(:OLD.e_mail,melopack.get_current_performer);
    
end del_fan;



--tests
--test case1: Removing a specific case
-- e_mail                      name   surn1 surn2      age
--valeria@clients.vinylinc.com Valeria Higa Cubas 27,8454968




--queryies fopr view3:

select distinct e_mail,name,surn1,surn2,(abs(MONTHS_BETWEEN(birthdate,sysdate))/12) from(
(select e_mail, name, surn1,surn2, birthdate from clients)
NATURAL JOIN
(select client e_mail from attendances where performer = melopack.get_current_performer group by client having count('x')>1));