--Satisfaction rates and customers' internet type and used device

select 
sf.internet_type_id,
sf.device_type_id   ,
sum(sc.csi) :: real / count(sc.sk_id ) as satisfy,
count(sc.sk_id )
from subs_csi sc 
join subs_features sf on (sc.sk_id = sf.sk_id) 
group by (sf.device_type_id, sf.internet_type_id) 
order by 1, 2

--Most popular devices among customers
select 
sf.device_type_id,
count(distinct sk_id ) :: real / (select count (distinct sk_id ) from subs_features sf2 ) * 100
from subs_features sf 
group by sf.device_type_id 
order by 2 desc


--Cumulative Sum and Rolling Average
WITH voice_agg AS 
(select 
to_date ('2002.' || start_time, 'YYYY.DD.MM') "date",
sum(voice_dur_min) "min"
from subs_bs_voice_session sbvs 
group by 1)
select 
*,
sum("min") over (order by "date"),
count("min") over w,
avg("min") over w
from voice_agg
window w as 
(order by 7 rows between 6 preceding and current row)
