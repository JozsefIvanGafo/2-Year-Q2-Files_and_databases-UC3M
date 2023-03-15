--Done

--Recorded
--Query number of recorded own tracks per band:
select band,count('x') "#original songs" from (select musician passport,band from involvement) A 
NATURAL JOIN (select writer passport, title from songs) B 
group by band fetch next 50 rows only;

--Query total number of recorded tracks per band:
select performer,count('x') "#total band songs" from (select pair, performer from albums) C
NATURAL JOIN (select pair, title from tracks) D
group by performer fetch next 50 rows only;

--Query owned song performances
select band,count('x') "#total band performances" from (select distinct songwriter, songtitle from performances) E
NATURAL JOIN (select musician songwriter, band from involvement) F where band = 'Rici'
group by band fetch next 50 rows only;
--Query total number of performances
select performer,count('x') "total band performings" from (select distinct performer,songtitle from performances) where performer = 'Rici' group by performer fetch next 50 rows only;



---prev(without distinct)

--Query owned song performances
select band,count('x') "#total band performances" from (select songwriter, songtitle from performances) E
NATURAL JOIN (select musician songwriter, band from involvement) F where band = 'Rici'
group by band fetch next 50 rows only;
--------------------------------------

select performer,count('x') "total band performings" from performances where performer = 'Rici' group by performer fetch next 50 rows only;


--##############################################################################################
--definitive 

--##############################################################################################


--Performances:
+--doubts/temporary:



-- example
SELECT sum(case when `Gender` = 'MALE' then 1 else 0 end)/count(*)*100 as male_ratio,
       sum(case when `Gender` = 'FEMALE' then 1 else 0 end)/count(*)*100 as female_ratio
FROM table1



--test
select band, "% of of recorded tracks" ((
    (select original_songs from (select band,count('x') original_songs from (select musician passport,band from involvement) A NATURAL JOIN (select writer passport, title from songs) B  group by band))
    /
    (select total_band_songs from (select performer band,count('x') total_band_songs from (select pair, performer from albums) C NATURAL JOIN (select pair, title from tracks) D group by performer))
    )*100)
from 
(select band from (select performer band,count('x') total_band_songs from (select pair, performer from albums) C
NATURAL JOIN (select pair, title from tracks) D
group by performer)) 
fetch next 50 rows only;
  ------------------------another test  
select 
(select "#original songs" from (select band,count('x') "#original songs" from (select musician passport,band from involvement) A NATURAL JOIN (select writer passport, title from songs) B  group by band))
as Query1,
(select "#total band songs" from (select performer band,count('x') "#total band songs" from (select pair, performer from albums) C NATURAL JOIN (select pair, title from tracks) D group by performer))
as Query2,(
    (select "#original songs" from (select band,count('x') "#original songs" from (select musician passport,band from involvement) A NATURAL JOIN (select writer passport, title from songs) B  group by band))
    / 
    (select "#total band songs" from (select performer band,count('x') "#total band songs" from (select pair, performer from albums) C NATURAL JOIN (select pair, title from tracks) D group by performer))
) as  per_rec_songs,
from  






select name performer,
(select band ,count('x') "#original songs" from (select musician passport,band from involvement) A 
NATURAL JOIN (select writer passport, title from songs) B 
group by band)
/
(select performer,count('x') "#total band songs" from (select pair, performer from albums) C
NATURAL JOIN (select pair, title from tracks) D
group by performer)*100 "% of band performances" from performers;















--
--Query different songs played live
select distinct songtitle,performer,count('x') "total band performings" from performances 
where performer = 'Rici' group by performer,songtitle fetch next 300 rows only;


--possible to remove:

----Query number of performed own tracks per band:
select performer,count('x') "#original songs performed" from (select songwriter writer, performer from performances) E
NATURAL JOIN (select writer, title from songs) F
group by performer fetch next 50 rows only;
----

