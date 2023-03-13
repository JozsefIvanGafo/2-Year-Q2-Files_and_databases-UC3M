--Done

--Query number of recorded own tracks per band:
select band,count('x') "#original songs" from (select musician passport,band from involvement) A 
NATURAL JOIN (select writer passport, title from songs) B 
group by band fetch next 50 rows only;

--Query total number of recorded tracks per band:
select performer,count('x') "#total band songs" from (select pair, performer from albums) C
NATURAL JOIN (select pair, title from tracks) D
group by performer fetch next 50 rows only;

+--doubts:





--Query total number of performances
select performer,count('x') "total band performings" from performances where performer = 'Rici' group by performer fetch next 50 rows only;

--Query different songs played live
select distinct songtitle,performer,count('x') "total band performings" from performances 
where performer = 'Rici' group by performer,songtitle fetch next 300 rows only;







--Temporary

--Query number of performed own tracks per band:
select performer,count('x') "#original songs performed" from (select songwriter writer, performer from performances) E
NATURAL JOIN (select writer, title from songs) F
group by performer fetch next 50 rows only;
--

