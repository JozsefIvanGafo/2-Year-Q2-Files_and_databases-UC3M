------------------------------------------------Procedures/functuions/packages--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE melopack as
	procedure performer_proc (performer varchar2);
	current_performer varchar2(50);
	PROCEDURE insert_album (current_performer VARCHAR2,new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
	,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
	,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2);
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
end melopack;


exec melopack.performer_proc('Metallica')
exec melopack.insert_album('Metallica','Z1290OHZ7079WKA','S','72 Seasons','Lux Aeterna','28/11/22','Iberodisco',555371058,1,'James Hetfield',205,'08/08/03','San Francisco studios','Ulrich')


-----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_album (current_performer VARCHAR2,new_pair CHAR,new_FORMAT CHAR,new_album_title VARCHAR2
,new_title CHAR,new_release_date DATE, new_publisher VARCHAR2, new_manager NUMBER,new_seq NUMBER
,new_writer VARCHAR2,new_duration NUMBER, new_rec_date DATE, new_studio VARCHAR2, new_engineer varchar2) is
flag NUMBER;
begin 
    
	select count('x') into flag from (select album_pair from fsdb.recordings where album_pair = new_pair);
    case 
    
    when condition then  current_performer not in performers then dbms_output.put_line('the performer does not exist');
    when new_title not in songs and new_writer not in songs  then dbms_output.put_line('the writer or title does not exist');
    when new_studio not in studio    then dbms_output.put_line('the studio does not exist');
    when new_publisher not in publisher   then dbms_output.put_line('the studio does not exist');
    end case 
      when condition then 
      else 
    end;;
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