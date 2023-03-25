-----------------------------------------------------------------------VIEWS-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
CREATE OR REPLACE VIEW events AS (select to_char(when,'MM-YY'),count('x') nconcerts,avg(nperformances),sum(attendance), avg(duration) 
from (select performer,when,attendance,duration from concerts)
NATURAL JOIN (select count('x') nperformances,performer, when from performances group by(performer,when)) 
group by to_char(when,'MM-YY') fetch next 50 rows only) WITH READ ONLY;
--queries2:

select to_char(when,'MM-YY'),count('x') nconcerts,sum(attendance), avg(duration) from concerts group by to_char(when,'MM-YY') fetch next 50 rows only;



select to_char(when,'MM-YY'),count('x') nconcerts,avg(nperformances),sum(attendance), avg(duration) 
from (select performer,when,attendance,duration from concerts)
NATURAL JOIN (select count('x') nperformances,performer, when from performances group by(performer,when)) 
group by to_char(when,'MM-YY') fetch next 50 rows only;

--view 3
CREATE OR REPLACE VIEW fans AS (

    
);
