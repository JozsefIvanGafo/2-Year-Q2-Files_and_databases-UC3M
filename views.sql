--views:
--view 1:
exec melopack.performer_proc('Amapola')

CREATE OR REPLACE VIEW my_albums AS (select performer,pair,sumation from (select pair, sum(duration) sumation from tracks group by pair) 
NATURAL JOIN (select pair, performer from albums) where performer = melopack.get_current_performer) WITH READ ONLY;


--queries1:

select pair, sum(duration) sumation from tracks group by pair;
select performer,pair,sumation from (select pair, sum(duration) sumation from tracks group by pair) 
NATURAL JOIN (select pair, performer from albums) fetch next 50 rows only;

--view2:
CREATE OR REPLACE VIEW events AS (select to_char(when,'MM-YY') date_event,count('x') nconcerts,avg(nperformances) avgperformances,sum(attendance) sumatt, avg(duration) avgdur
from (select performer,when,attendance,duration from concerts 
where performer = melopack.get_current_performer)
NATURAL JOIN (select count('x') nperformances,performer, when from performances
where performer = melopack.get_current_performer group by(performer,when)) 
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
(select client e_mail from attendances where performer = melopack.get_current_performer group by client having count('x')>1))
where e_mail not in (select banned_e_mail from banned_fans));



--table for banned fans
Create table banned_fans(
	banned_e_mail varchar2(100) NOT NULL,
	banned_performer varchar2(50) NOT NULL,
	CONSTRAINT PK_banned_fans PRIMARY KEY(banned_e_mail),
    CONSTRAINT FK_Clients20 FOREIGN KEY (banned_e_mail) REFERENCES CLIENTS,
    CONSTRAINT FK_Performer20 FOREIGN KEY (banned_performer) REFERENCES performers
);


Create or replace Trigger del_fan
instead of delete on fans
for each row
begin
    insert into banned_fans(banned_e_mail,banned_performer) values(:OLD.e_mail,melopack.get_current_performer);
end del_fan1;


Create or replace Trigger ins_fan
instead of insert on fans
for each row
DECLARE
flag number :=0;
begin
    select count('x') into flag from (select banned_e_mail from banned_fans where banned_e_mail = :NEW.e_mail);
    if flag >0 
        then delete from banned_fans where banned_e_mail = :NEW.e_mail;
    end if;
end ins_fan;



---
if :NEW.e_mail not in (select e_mail from clients)
        then insert into clients(e_mail,name,surn1,surn2) values(:NEW.e_mail,:NEW.name,:NEW.surn1,:NEW.surn2);
    end if;
---






---table
CREATE TABLE bulk_delete(
e_mail  VARCHAR2(200) not null, 
CONSTRAINT PK_bulk_delete33 PRIMARY KEY(e_mail)
);

delete from fans where e_mail='matumaycollantes@clients.vinylinc.com';
delete from fans where e_mail='estevez@clients.vinylinc.com';
delete from fans where e_mail='benjaminelescano@clients.vinylinc.com';
delete from fans where e_mail='augi@clients.vinylinc.com';
delete from fans where e_mail=(select e_mail from bulk_delete);
drop table bulk_delete;






--MUTATING TABLE HANDLER
--temporary table 
create global temporary table tmp_banned_fans 
(old_e_mail varchar2(100), performer varchar2(50));

--Trigger for del_fan1 avoiding mutating table
Create or replace Trigger del_fan1
instead of delete on fans
for each row
begin
    insert into tmp_banned_fans(old_e_mail,performer) values(:OLD.e_mail,melopack.get_current_performer);
end del_fan1;

--Trigger for del_fan2
Create or replace Trigger del_fan2
instead of delete on fans 
begin
    for row in (select old_e_mail, performer from tmp_banned_fans) loop
        insert into banned_fans(banned_e_mail,banned_performer) values(row.old_e_mail,row.performer);
        delete from tmp_banned_fans where old_e_mail=row.old_e_email and performer=row.performer;
    end loop;
end del_fan2;


--
for row in (select * from tmp_update_concert) loop
		select duration into aux from concerts where performer=row.new_performer and when=row.new_when;
        update concerts set duration=(aux+row.new_dur)
        	where performer=row.new_performer and when=row.new_when;
        delete from tmp_update_concert where new_dur=row.new_dur and new_performer=row.new_performer and new_when=row.new_when and new_sequ=row.new_sequ;
    end loop;






-----------------------------
--tests
--test case1: Removing a specific case
-- e_mail                      name   surn1 surn2      age
--valeria@clients.vinylinc.com Valeria Higa Cubas 27,8454968




--queryies fopr view3:

select distinct e_mail,name,surn1,surn2,(abs(MONTHS_BETWEEN(birthdate,sysdate))/12) from(
(select e_mail, name, surn1,surn2, birthdate from clients)
NATURAL JOIN
(select client e_mail from attendances where performer = melopack.get_current_performer group by client having count('x')>1))
where e_mail not in (select e_mail from banned_fans);