------------------------------------------------Procedures/functuions/packages--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE melopack as
	procedure performer_proc (performer varchar2);
	current_performer varchar2(50);
	PROCEDURE insert_album (current_performer VARCHAR2,new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
	,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
	,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2);
    PROCEDURE delete_track(new_pair CHAR, new_seq NUMBER);
end melopack;



CREATE OR REPLACE PACKAGE BODY melopack as
PROCEDURE performer_proc(performer varchar2) is
begin 
	current_performer := performer;
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
end performer_proc;

PROCEDURE insert_album (current_performer VARCHAR2,new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2) is
flag NUMBER;
begin 
	select count('x') into flag from (select album_pair from fsdb.recordings where album_pair = new_pair);
	if flag = 0
		then insert into Albums(pair,performer,format,title,rel_date,publisher,manager)
		values(new_pair,current_performer,new_FORMAT,new_album_title,new_release_date,new_publisher,new_manager);
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
end melopack;


exec melopack.performer_proc('Metallica')
---                             perf            pair    format  album     title           release     pub           man   seq      writer      dur     rec        studio              engineer
exec melopack.insert_album('Begga Ruiz','Z1290OHZ7079WKA','S','72 Seasons','Holiday of blues','28/11/22','Archer',555399004,2,'SE>>0222003242',275,'17/08/95','Stretchers Studios','Ulrich')
exec melopack.delete_track('Z1290OHZ7079WKA',2)

insert into Albums (pair,performer,format,title,rel_date,publisher,manager)
values ('Z1290OHZ7079WKA','Begga Ruiz','S','72 Seasons','28/11/22','Archer',555399004);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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



CREATE OR REPLACE PROCEDURE insert_album (current_performer VARCHAR2,new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2) is
flag NUMBER;
begin 
	select count('x') into flag from (select album_pair from fsdb.recordings where album_pair = new_pair);
	if flag = 0
		then insert into Albums(pair,performer,format,title,rel_date,publisher,manager)
		values(new_pair,current_performer,new_FORMAT,new_album_title,new_release_date,new_publisher,new_manager);
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