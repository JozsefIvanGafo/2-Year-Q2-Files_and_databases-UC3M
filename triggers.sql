--Triggers
--1
--Temporary table to avoid mutation errors
Create global temporary TABLE tmp_update_concert
(new_dur NUMBER(4), new_performer VARCHAR2(50),new_when DATE,new_sequ Number(3));

--Trigger to insert on the temporary table
Create or replace Trigger update_concert_1
BEFORE  insert on performances
for each row
DECLARE
bad_dur Exception;
begin
    If :NEW.duration>0 then 
    insert into tmp_update_concert 
		values(:NEW.duration/60,:NEW.performer,:NEW.when,:NEW.sequ);
    else raise bad_dur;
    end if;
exception
    when bad_dur then raise_application_error(-20001,'WRONG song duration it must be bigger than 0!');
end update_concert_1;

--Trigger insert row by row on the destination table
Create or replace Trigger update_concert_2
AFTER insert on performances
DECLARE
aux Number;
begin
    for row in (select * from tmp_update_concert) loop
		select duration into aux from concerts where performer=row.new_performer and when=row.new_when;
        update concerts set duration=(aux+row.new_dur)
        	where performer=row.new_performer and when=row.new_when;
        delete from tmp_update_concert where new_dur=row.new_dur and new_performer=row.new_performer and new_when=row.new_when and new_sequ=row.new_sequ;
    end loop;
end update_concert_2;

---Test trigger1
--Rici                                               10/06/88    duration:86+(60*5)/60=86+5=91    122+2=124
--Rici                                               31/07/09
--Absurdity she                                      SE>>0671070312

---Bulk positive nbumbers test
--duration:86+(60*5)/60=86+5=91    122+2=124
--create new table
CREATE TABLE bulk_insert(
performer  VARCHAR2(35) not null, 
when  DATE not null, 
sequ number(3), 
songtitle varchar2(100),
songwriter  varchar2(14),
duration number(4),
CONSTRAINT PK_MANAGERS33 PRIMARY KEY(performer,when,sequ)
);
--insert the data
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',100,'Acabar bandera','SE>>0866705629',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',101,'Absurdity thunder','SE>>0414837052',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',102,'Absurdity or valley','FR>>0512630289',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',103,'Absurdity thunder','SE>>0414837052',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',104,'Acabar','ES>>0971759229',60);
--repopulate to performances
insert into PERFORMANCES (performer,when,sequ,songtitle,songwriter,duration) (select performer,when,sequ,songtitle,songwriter,duration from bulk_insert);

drop CASCADE table bulk_insert;

---individual positive numbers test
---duration:86+(60*5)/60=86+5=91   
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',100,'Acabar bandera','SE>>0866705629',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',101,'Absurdity thunder','SE>>0414837052',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',102,'Absurdity or valley','FR>>0512630289',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',103,'Absurdity thunder','SE>>0414837052',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',104,'Acabar','ES>>0971759229',60);
--individual negative numbers and NULL test
---duration:86+(60*3)/60=86+3=89
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',100,'Acabar bandera','SE>>0866705629',-60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',101,'Absurdity thunder','SE>>0414837052',NULL);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',102,'Absurdity or valley','FR>>0512630289',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',103,'Absurdity thunder','SE>>0414837052',60);
insert into performances (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',104,'Acabar','ES>>0971759229',60);

--restore prev values
delete from performances where performer='Rici' and when='10/06/88' and sequ>=100;
update concerts set duration=86 where performer='Rici' and when='10/06/88';
--update performances set duration=86 where performer='Rici' and when='10/06/88';
--2
CREATE OR REPLACE TRIGGER less_age
BEFORE INSERT ON attendances
FOR EACH ROW
DECLARE
badage EXCEPTION;
aux number;
BEGIN
	select to_number(to_char(birthdate,'YY')) into aux from clients where e_mail = :new.client;
	if (to_number(to_char(:new.purchase,'YY')) - aux) < 18
		then raise badage;
	end if;
exception
	when badage then raise_application_error(-20001,'BAD AGE!');
end less_age;	


--3:
CREATE OR REPLACE TRIGGER reverse_trigger
BEFORE INSERT ON songs
FOR EACH ROW
DECLARE
badsong EXCEPTION;
flag number :=0;
BEGIN
	select count('x') into flag 
	from (select * from songs where title = :new.title and writer = :new.cowriter and cowriter = :new.writer);
	if flag > 0
		then raise badsong;
	end if;
exception
	when badsong then raise_application_error(-20001,'WRONG SONG!');
end reverse_trigger;





---------comments
--Acabar de carnaval                                 ES>>0009127087 ES>>0173202814
----------------Save prev version
----trigger 1
--Triggers
--1
--Temporary table to avoid mutation errors
Create global temporary TABLE tmp_update_concert
(sum_dur NUMBER(4), new_performer VARCHAR2(50),new_when DATE);

--Trigger to insert on the temporary table
Create or replace Trigger update_concert_1
BEFORE  insert on performances
for each row
DECLARE
error Exception;
con_dur number;
sum_dur number;
begin
    select duration into con_dur from concerts where performer =:new.performer and when = :NEW.when;
	sum_dur := con_dur + to_number(:NEW.duration / 60);
    insert into tmp_update_concert 
		values(sum_dur,:NEW.performer,:NEW.when);
end update_concert_1;

--Trigger insert row by row on the destination table
Create or replace Trigger update_concert_2
AFTER  insert on performances
begin
    for row in (select * from tmp_update_concert) loop
        update concerts set duration=duration + row.sum_dur
        	where performer=row.new_performer and when=row.new_when;
    end loop;
end update_concert_2;



----save
---

Create or replace Trigger update_concert_2
AFTER update of duration on 
begin
    for row in (select * from tmp_update_concert) loop
        update concerts set duration=row.sum_dur
        	where performer=row.new_performer and when=row.new_when;
    end loop;
end update_concert_2;





-----------Compound trigger1
create or replace trigger UC_update_concert
for update of duration on 


-------------------------------------
Create or replace Trigger update_concert_2
DECLARE
dur Number;
AFTER insert on performances
begin
    for row in (select * from tmp_update_concert) loop
        select duration into dur from concerts where performer=row.performer and when= row.when
        dbms_output.put_line('Before sum');
        dbms_output.put_line('old concert duration: '||dur);
        dbms_output.put_line('What we sum');
        dbms_output.put_line('old_duration: '||row.new_dur);
        dbms_output.put_line('--');
        update concerts set duration=(duration+row.new_dur)
        	where performer=row.new_performer and when=row.new_when;
            select duration into dur from concerts where performer=row.performer and when= row.when
        dbms_output.put_line('After sum');
        dbms_output.put_line('new concert duration: '||dur);
        dbms_output.put_line('--------------------------------------------------------------------------------------------------------');
    end loop;
end update_concert_2;

----
--create new table
CREATE TABLE bulk_insert(
performer  VARCHAR2(35) not null,
when  DATE not null,
sequ number(3),
songtitle varchar2(100),
songwriter  varchar2(14),
duration number(4),
CONSTRAINT PK_MANAGERS33 PRIMARY KEY(performer,when,sequ)
);
--insert the data
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',100,'Acabar bandera','SE>>0866705629',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',101,'Absurdity thunder','SE>>0414837052',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',102,'Absurdity or valley','FR>>0512630289',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',103,'Absurdity thunder','SE>>0414837052',60);
insert into bulk_insert (performer,when,sequ,songtitle,songwriter,duration) values ('Rici','10/06/88',104,'Acabar','ES>>0971759229',60);
--repopulate to performances
insert into PERFORMANCES (performer,when,sequ,songtitle,songwriter,duration) (select performer,when,sequ,songtitle,songwriter,duration from bulk_insert);


drop CASCADE table bulk_insert;

--------------------
--create new table
CREATE TABLE bulk_insert(
performer  VARCHAR2(35) not null,
when  DATE not null,
sequ number(3),
songtitle varchar2(100),
songwriter  varchar2(14),
duration number(4),
CONSTRAINT PK_MANAGERS33 PRIMARY KEY(performer,when,sequ)
);















-------------

CREATE OR REPLACE TRIGGER reverse_trigger
BEFORE INSERT ON songs
FOR EACH ROW
DECLARE
badsong EXCEPTION;
flag number :=0;
BEGIN
    select count('x') into flag
    from (select * from songs where title = :new.title and writer = :new.cowriter and cowriter = :new.writer);
    if flag > 0
        then raise badsong;
    end if;
exception
    when badsong then raise_application_error(-20001,'WRONG SONG!');
end reverse_trigger;