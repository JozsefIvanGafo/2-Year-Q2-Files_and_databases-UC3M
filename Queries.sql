--Done

--Recorded
--Query number of recorded own tracks per band:
select band,count('x') "#original songs" from (select musician passport,band from involvement) A 
NATURAL JOIN (select writer passport, title from tracks) B 
group by band fetch next 50 rows only;

--Query total number of recorded tracks per band:
select performer,count('x') "#total band songs" from (select pair, performer from albums) C
NATURAL JOIN (select pair, title from tracks) D
group by performer fetch next 50 rows only;

--Query owned song performances
select band,count('x') "#own band performances" from (select songwriter, songtitle from performances) E
NATURAL JOIN (select musician songwriter, band from involvement) F where band = 'Hildi'
group by band fetch next 50 rows only;
--------------------------------------
--Query total number of performances
select performer,count('x') "total band performings" from performances where performer = 'Hildi' group by performer fetch next 50 rows only;

--Distinct performances songs
--##############################################################################################
select band,count('x') "#total band performances" from (select distinct songwriter, songtitle from performances) E
NATURAL JOIN (select musician songwriter, band from involvement) F where band = 'Rici'
group by band fetch next 50 rows only;

select performer,count('x') "total band performings" from (select distinct performer,songtitle from performances) where performer = 'Rici' group by performer fetch next 50 rows only;
-----------------------------------------------------------------------QUERIES-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------Query 1: Self_suficient (we have to include the !=cases for the percentages)------------------------------------------------------------------------------------------------------------------------------------------------------------------

select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select band,count('x') total_band_owned_performances from (select songwriter, songtitle from performances) NATURAL JOIN (select musician songwriter, band from involvement) group by band)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer));

----------------------------------------Query 2: Revival (we have to include the !=cases for the percentages)------------------------------------------------------------------------------------------------------------------------------------------------------------------

select performer_name, per_of_concert_perf_owned from 
(select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select band,count('x') total_band_owned_performances from (select songwriter, songtitle from performances) NATURAL JOIN (select musician songwriter, band from involvement) group by band)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer)))
order by per_of_concert_perf_owned desc fetch next 50 rows only;



------------------------------- Possible solutions
select performer_name, per_of_concert_perf_owned from (
select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select band,count('x') total_band_owned_performances from (select songwriter, songtitle from performances) NATURAL JOIN (select musician songwriter, band from involvement) group by band)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer))
where total_sum_songs >= original_songs and total_band_performances>=total_band_owned_performances and total_band_performances!=0 and total_sum_songs!=0 )
order by per_of_concert_perf_owned desc fetch next 10 rows only;


-----------------------------------------------------------------------VIEWS-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------view1: my_albums------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW my_albums AS (select performer,pair,sumation from (select pair, sum(duration) sumation from tracks group by pair) 
NATURAL JOIN (select pair, performer from albums)) WITH READ ONLY;
----------------------------------------view2: events------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------view2: fans------------------------------------------------------------------------------------------------------------------------------------------------------------------




