------------------------------------------------Procedures/functuions/packages--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE melopack as
	FUNCTION get_current_performer return VARCHAR2;
	procedure performer_proc (performer varchar2);
	current_performer varchar2(50);
	PROCEDURE insert_album (new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
	,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
	,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2);
    PROCEDURE delete_track(new_pair CHAR, new_seq NUMBER);
	PROCEDURE report;
end melopack;


-----------------------------------------------BODY-----------------------------------------------
CREATE OR REPLACE PACKAGE BODY melopack as
FUNCTION get_current_performer return VARCHAR2 is
aux varchar2(50);
begin
	aux := melopack.current_performer;
	return aux;
end;

PROCEDURE performer_proc(performer varchar2) is
begin 
	current_performer := performer;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end performer_proc;

PROCEDURE insert_album (new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2) is
flag NUMBER;
begin 
	select count('x') into flag from (select album_pair from fsdb.recordings where album_pair = new_pair);
	if flag = 0
		then insert into Albums(pair,performer,format,title,rel_date,publisher,manager)
		values(new_pair,melopack.current_performer,new_FORMAT,new_album_title,new_release_date,new_publisher,new_manager);
		insert into Tracks(pair,sequ,title,writer,rec_date,studio,engineer,duration)
		values(new_pair,new_seq,new_title,new_writer,new_rec_date,new_studio,new_engineer,new_duration);
	else insert into Tracks(pair,sequ,title,writer,rec_date,studio,engineer,duration)
		values(new_pair,new_seq,new_title,new_writer,new_rec_date,new_studio,new_engineer,new_duration);
	end if;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end;

PROCEDURE delete_track(new_pair CHAR, new_seq NUMBER) is
flag NUMBER; 
begin 
    select count('x') into flag from (select sequ from tracks where pair = new_pair);
    if flag = 0 
    then delete from albums where pair = new_pair;
    elsif flag = 1
    then delete from Tracks where pair = new_pair and sequ = new_seq;
    delete from albums where pair = new_pair;
    else
    delete from Tracks where pair = new_pair and sequ = new_seq;
    end if;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end;

PROCEDURE report is
begin 
	dbms_output.put_line('Performer`s Statistics');
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Number of albums per format');
	for myrow in (select format,count('x') num from albums where performer = melopack.current_performer group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.num);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Average number of songs per format of album');
	for myrow in (select format,count('x'),avg(ntracks) average from (select pair,format from albums where performer = melopack.current_performer)
		NATURAL JOIN
		(select count('x') ntracks, pair from tracks group by pair) group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.average);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Average duration per format of album');
	for myrow in (select format,count('x'),avg(sumation) sumation from (select pair,format from albums where performer = melopack.current_performer)
		NATURAL JOIN
		(select sum(duration) sumation, pair from tracks group by pair) group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.sumation);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Periodicity');
	for myrow in (select datenum/num_alb months_between_albums from
		(select months_between(max(rel_date),min(rel_date)) datenum,count('x') num_alb 
		from albums where performer = melopack.current_performer
		group by performer))
		loop
		dbms_output.put_line(myrow.months_between_albums);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for publisher');
	for myrow in (select publisher,npublisher,round((npublisher/ntotal)*100,2) pub_per from
    (select publisher, count('x') npublisher from (select distinct publisher,pair from albums where performer = melopack.current_performer)group by publisher)
    NATURAL JOIN
    (select count('x') ntotal from(select distinct performer ,publisher,pair from albums where performer = melopack.current_performer)group by performer))
		loop
		dbms_output.put_line('PUBLISHER: '||myrow.publisher||'| Number of works: '||myrow.npublisher||' -> percentage: '||myrow.pub_per);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for studio');
	for myrow in (select studio,nstudio, round((nstudio/ntotal)*100,2) stu_per from (
    (select studio , count('x') nstudio from((select pair from albums where performer = melopack.current_performer) NATURAL JOIN (select pair, studio, engineer from tracks)) group by studio)
    NATURAL JOIN
    (select count('x') ntotal from ((select performer,pair from albums where performer = melopack.current_performer) NATURAL JOIN (select pair, studio from tracks)) group by performer)))
		loop
		dbms_output.put_line('STUDIO: '||myrow.studio||'| Number of works: '||myrow.nstudio||' -> percentage '||myrow.stu_per);
	end loop;

    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for Engineer');
	for myrow in (select engineer,nengineer, round((nengineer/ntotal)*100,2) as eng_per from (
    (select engineer , count('x') nengineer from((select pair from albums where performer = melopack.current_performer) NATURAL JOIN (select pair, engineer from tracks)) group by engineer)
    NATURAL JOIN
    (select count('x') ntotal from ((select performer,pair from albums where performer = melopack.current_performer) NATURAL JOIN (select pair,engineer from tracks)) group by performer)))
		loop
		dbms_output.put_line('ENGINEER: '||myrow.engineer||'| Number of works: '||myrow.nengineer||' -> percentage '||myrow.eng_per);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for album manager');
	for myrow in (select manager,nmanager, round((nmanager/ntotal)*100,2) mana_per from (
    (select manager , count('x') nmanager from((select pair, manager from albums where performer = melopack.current_performer)) group by manager)
    NATURAL JOIN
    (select count('x') ntotal from (select performer,pair,manager from albums where performer = melopack.current_performer) group by performer)))
		loop
		dbms_output.put_line('ALBUM MANAGER: '||myrow.manager||'| Number of works: '||myrow.nmanager||' -> percentage '||myrow.mana_per);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for concerts manager');
	for myrow in (select manager,nmanager, round((nmanager/ntotal)*100,2) as con_man_per from (
    (select manager , count('x') nmanager from((select manager from concerts where performer = melopack.current_performer)) group by manager)
    NATURAL JOIN
    (select count('x') ntotal from (select performer,manager from concerts where performer = melopack.current_performer) group by performer)))
		loop
		dbms_output.put_line('CONCERT MANAGER: '||myrow.manager||'| Number of works: '||myrow.nmanager||' -> percentage '||myrow.con_man_per);
	end loop;
	dbms_output.put_line('----------------------------------');
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end report;

end melopack;

------------------------------------------END OF BODY----------------------------------------
exec melopack.performer_proc('Begga Ruiz')
---                             perf            pair    format  album     title           release     pub           man   seq      writer      dur     rec        studio              engineer
exec melopack.insert_album('Z1290OHZ7079WKA','S','72 Seasons','Holiday of blues','28/11/22','Archer',555399004,3,'SE>>0222003242',275,'17/08/95','Stretchers Studios','Ulrich')
exec melopack.delete_track('Z1290OHZ7079WKA',3)

insert into Albums (pair,performer,format,title,rel_date,publisher,manager)
values ('Z1290OHZ7079WKA','Begga Ruiz','S','72 Seasons','28/11/22','Archer',555399004);

exec melopack.report()

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------TEMPORAL TRASH----------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE report is
begin 
	dbms_output.put_line('Performer`s Statistics');
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Number of albums per format');
	for myrow in (select format,count('x') num from albums where performer = melopack.get_current_performer group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.num);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Average number of songs per format of album');
	for myrow in (select format,count('x'),avg(ntracks) average from (select pair,format from albums where performer = melopack.get_current_performer)
		NATURAL JOIN
		(select count('x') ntracks, pair from tracks group by pair) group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.average);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Average duration per format of album');
	for myrow in (select format,count('x'),avg(sumation) sumation from (select pair,format from albums where performer = melopack.get_current_performer)
		NATURAL JOIN
		(select sum(duration) sumation, pair from tracks group by pair) group by format)
		loop
		dbms_output.put_line(myrow.format||'-'||myrow.sumation);
	end loop;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Periodicity');
	for myrow in (select datenum/num_alb months_between_albums from
		(select months_between(max(rel_date),min(rel_date)) datenum,count('x') num_alb 
		from albums where performer = melopack.get_current_performer
		group by performer))
		loop
		dbms_output.put_line(myrow.months_between_albums);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for publisher');
	for myrow in (select publisher,round((npublisher/ntotal)*100,2) pub_per from
    (select publisher, count('x') npublisher from (select distinct publisher,pair from albums where performer = melopack.get_current_performer)group by publisher)
    NATURAL JOIN
    (select count('x') ntotal from(select distinct performer ,publisher,pair from albums where performer = melopack.get_current_performer)group by performer))
		loop
		dbms_output.put_line('PUBLISHER: '||myrow.publisher||' -> '||myrow.pub_per);
	end loop;
    
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for studio');
	for myrow in (select studio, round((nstudio/ntotal)*100,2) stu_per from (
    (select studio , count('x') nstudio from((select pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, studio, engineer from tracks)) group by studio)
    NATURAL JOIN
    (select count('x') ntotal from ((select performer,pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, studio from tracks)) group by performer)))
		loop
		dbms_output.put_line('STUDIO: '||myrow.studio||' -> '||myrow.stu_per);
	end loop;

    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for Engineer');
	for myrow in (select engineer, round((nengineer/ntotal)*100,2) as eng_per from (
    (select engineer , count('x') nengineer from((select pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, engineer from tracks)) group by engineer)
    NATURAL JOIN
    (select count('x') ntotal from ((select performer,pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair,engineer from tracks)) group by performer)))
		loop
		dbms_output.put_line('ENGINEER: '||myrow.engineer||' -> '||myrow.eng_per);
	end loop;

    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for studio');
	for myrow in (select manager, round((nmanager/ntotal)*100,2) mana_per from (
    (select manager , count('x') nmanager from((select pair, manager from albums where performer = melopack.get_current_performer)) group by manager)
    NATURAL JOIN
    (select count('x') ntotal from (select performer,pair,manager from albums where performer = melopack.get_current_performer) group by performer)))
		loop
		dbms_output.put_line('ALBUM MANAGER: '||myrow.manager||' -> '||myrow.mana_per);
	end loop;
    dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Information for concerts manager');
	for myrow in (select manager, round((nmanager/ntotal)*100,2) as con_man_per from (
    (select manager , count('x') nmanager from((select manager from concerts where performer = melopack.get_current_performer)) group by manager)
    NATURAL JOIN
    (select count('x') ntotal from (select performer,manager from concerts where performer = melopack.get_current_performer) group by performer)))
		loop
		dbms_output.put_line('CONCERT MANAGER: '||myrow.manager||' -> '||myrow.con_man_per);
	end loop;
	dbms_output.put_line('----------------------------------');
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end report;


---------------------------------------------------------Trash--------------------------------------------------------
select publisher,(npublisher/ntotal)*100 from
(select publisher, count('x') npublisher from (select distinct publisher,pair from albums where performer = melopack.get_current_performer)group by publisher)
NATURAL JOIN
(select count('x') ntotal from(select distinct performer ,publisher,pair from albums where performer = melopack.get_current_performer)group by performer)



select studio, (nstudio/ntotal)*100 from (
(select studio , count('x') nstudio from((select pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, studio, engineer from tracks)) group by studio)
NATURAL JOIN
(select count('x') ntotal from ((select performer,pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, studio from tracks)) group by performer))



select engineer, (nengineer/ntotal)*100 from (
(select engineer , count('x') nengineer from((select pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair, engineer from tracks)) group by engineer)
NATURAL JOIN
(select count('x') ntotal from ((select performer,pair from albums where performer = melopack.get_current_performer) NATURAL JOIN (select pair,engineer from tracks)) group by performer))


select manager, (nmanager/ntotal)*100 from (
(select manager , count('x') nmanager from((select pair, manager from albums where performer = melopack.get_current_performer)) group by manager)
NATURAL JOIN
(select count('x') ntotal from (select performer,pair,manager from albums where performer = melopack.get_current_performer) group by performer));


select manager, (nmanager/ntotal)*100 from (
(select manager , count('x') nmanager from((select manager from concerts where performer = melopack.get_current_performer)) group by manager)
NATURAL JOIN
(select count('x') ntotal from (select performer,manager from concerts where performer = melopack.get_current_performer) group by performer))

--------------------------------------------------------------------------------------------------------------------------------------------------






select publisher, count('x') from (
select distinct publisher,studio,engineer,manager from 
(select performer,manager from concerts where performer = melopack.get_current_performer)
NATURAL JOIN
(select publisher,manager,pair from albums where performer = melopack.get_current_performer)
NATURAL JOIN
(select pair, studio, engineer from tracks))group by publisher;


select distinct publisher,studio,engineer,manager from 
(select performer,manager from concerts where performer = melopack.get_current_performer)
NATURAL JOIN
(select publisher,manager,pair from albums where performer = melopack.get_current_performer)
NATURAL JOIN
(select pair, studio, engineer from tracks);














select count('x') from albums where performer = melopack.get_current_performer group by format;

select format,count('x'),avg(ntracks) from (select pair,format from albums where performer = melopack.get_current_performer)
NATURAL JOIN
(select count('x') ntracks, pair from tracks group by pair) group by format;

select format,count('x'),avg(sumation) sumation from (select pair,format from albums where performer = melopack.get_current_performer)
NATURAL JOIN
(select sum(duration) sumation, pair from tracks group by pair) group by format;













CREATE OR REPLACE FUNCTION get_current_performer return VARCHAR2 is
aux varchar2(50);
begin
	aux := melopack.current_performer;
	return aux;
end;


CREATE OR REPLACE PROCEDURE delete_track(new_pair CHAR, new_seq NUMBER) is
flag NUMBER; 
begin 
    select count('x') into flag from (select sequ from tracks where pair = new_pair);
    if flag = 0 
    then delete from albums where pair = new_pair;
    elsif flag = 1
    then delete from Tracks where pair = new_pair and sequ = new_seq;
    delete from albums where pair = new_pair;
    else
    delete from Tracks where pair = new_pair and sequ = new_seq;
    end if;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end;


--Delete a row
DELETE FROM table_name
WHERE condition of which row(s) to delete;



CREATE OR REPLACE PROCEDURE insert_album (new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2) is
flag NUMBER;
begin 
	select count('x') into flag from (select album_pair from fsdb.recordings where album_pair = new_pair);
	if flag = 0
		then insert into Albums(pair,performer,format,title,rel_date,publisher,manager)
		values(new_pair,melopack.current_performer,new_FORMAT,new_album_title,new_release_date,new_publisher,new_manager);
		insert into Tracks(pair,sequ,title,writer,rec_date,studio,engineer,duration)
		values(new_pair,new_seq,new_title,new_writer,new_rec_date,new_studio,new_engineer,new_duration);
	else insert into Tracks(pair,sequ,title,writer,rec_date,studio,engineer,duration)
		values(new_pair,new_seq,new_title,new_writer,new_rec_date,new_studio,new_engineer,new_duration);
	end if;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
    when invalid_number then dbms_output.put_line('Invalid number error ORA-01722 ');
    when value_error then dbms_output.put_line('Invalid value error ORA-06502 ');
    when storage_error then dbms_output.put_line('storage error  ORA-06500 ');
    when program_error then dbms_output.put_line('program error  ORA-06501 ');
    when access_into_null then dbms_output.put_line('acces into null  ORA-06530 ');
    when dup_val_on_index then dbms_output.put_line('dup value on index ORA-00001');
    when rowtype_mismatch then dbms_output.put_line('row type mismatch ORA-06504');
    when subscript_beyond_count then dbms_output.put_line('subscript beyond count ORA-06533');
    when sys_invalid_rowid then dbms_output.put_line('sys invalid rowid ORA-01410');
    when collection_is_null then dbms_output.put_line('collection error  ORA-06531');
	when others then dbms_output.put_line('other error occurred');
end;







CREATE OR REPLACE PROCEDURE performer_proc(performer varchar2) is
begin 
	current_performer := performer;
exception
	when no_data_found then dbms_output.put_line('No row returned');
	when too_many_rows then dbms_output.put_line('too many rows returned');
	when others then dbms_output.put_line('other error occurred');
end;
