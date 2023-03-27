--Done
--EN SEMÁNTICA PONER EL ERROR DE QUE NOS QUEDABA MÁS DE 100% DE CANCIONES PERFORMEADAS...
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
select performer,count('x') from performances where songwriter in (select musician from involvement where band = performer) 
group by performer;
--------------------------------------
--Query total number of performances
select performer,count('x') "total band performings" from performances where performer = 'Rici' group by performer fetch next 50 rows only;

--Distinct performances songs
--##############################################################################################
select band,count('x') "#total band performances" from (select distinct songwriter, songtitle from performances) E
NATURAL JOIN (select musician songwriter, band from involvement) F where band = 'Rici'
group by band fetch next 50 rows only;

select performer,count('x') "total band performings" from (select distinct performer,songtitle from performances) where performer = 'Rici' group by performer fetch next 50 rows only;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--a)


select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select performer band,count('x') total_band_owned_performances from performances where songwriter in (select musician from involvement where band = performer) 
group by performer)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer))
where total_sum_songs >= original_songs and total_band_performances>=total_band_owned_performances 
and total_band_performances!=0 and total_sum_songs!=0;

--b)

select performer, count('x') from (
(select performer, songwriter, songtitle,max(rec_date) rec_date from(
(select performer, pair from albums)
NATURAL JOIN
(select pair,title songtitle, writer songwriter, rec_date from tracks)) group by (performer,songwriter,songtitle))
NATURAL JOIN
(select performer,songtitle, songwriter, when from performances)
)where rec_date < when group by performer fetch next 50 rows only;




-- lo de antes pero los 10 con más porcentaje
select performer_name, per_of_concert_perf_owned from (
select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select performer band,count('x') total_band_owned_performances from performances where songwriter in (select musician from involvement where band = performer) 
group by performer)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer))
where total_sum_songs >= original_songs and total_band_performances>=total_band_owned_performances and total_band_performances!=0 and total_sum_songs!=0)
order by per_of_concert_perf_owned desc fetch next 10 rows only;
--There were performers with more own song performances than total performances, no sense

--b.old)

select performer_name, per_of_concert_perf_owned, avg(abs(MONTHS_BETWEEN(rec_date,when))/12) year_average
,avg(abs(MONTHS_BETWEEN(rec_date,when))) month_average,
avg(abs(MONTHS_BETWEEN(rec_date,when))*30) day_average from
(select performer performer_name, when, songtitle title, songwriter writer from performances) 
NATURAL JOIN 
(select title,writer, rec_date from tracks) 
NATURAL JOIN 
(select performer_name, per_of_concert_perf_owned from (
select band as performer_name, 
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned , 
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select performer band,count('x') total_band_owned_performances from performances where songwriter in (select musician from involvement where band = performer) 
group by performer)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer))
where total_sum_songs >= original_songs and total_band_performances>=total_band_owned_performances and total_band_performances!=0 and total_sum_songs!=0)
order by per_of_concert_perf_owned desc fetch next 10 rows only)
where when >= rec_date group by performer_name,per_of_concert_perf_owned;
















select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) where band='Nici'group by band;
select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) where performer='Nici' group by performer;
select performer band,count('x') total_band_owned_performances from performances where songwriter in (select musician from involvement where band = performer) and performer='Nici' group by performer;
select performer as band,count('x') total_band_performances from performances where performer='Nici' group by performer;


------------------------
select band as performer_name,
(original_songs/total_sum_songs)*100 as per_of_recorded_tracks_owned ,
(total_band_owned_performances/total_band_performances)*100 as  per_of_concert_perf_owned from
((select band,count('x') original_songs from (select musician passport,band from involvement) NATURAL JOIN (select writer passport, title from tracks) group by band )
natural join
(select performer as band,count('x') total_sum_songs from (select pair, performer from albums) NATURAL JOIN (select pair, title from tracks) group by performer)
natural join
(select performer band,count('x') total_band_owned_performances from performances where songwriter in (select musician from involvement where band = performer)
group by performer)
natural join
(select performer as band,count('x') total_band_performances from performances group by performer))
where total_sum_songs >= original_songs and total_band_performances>=total_band_owned_performances
and total_band_performances!=0 and total_sum_songs!=0;