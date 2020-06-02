-- Materialized view for internet data consumption by customers

CREATE MATERIALIZED VIEW public.internet_consumption
TABLESPACE pg_default
AS SELECT sbc.sk_id,
    sbc.mon AS month,
    sf.internet_type_id AS internet_type,
    sum(sbc.sum_data_mb) AS data_consumption
   FROM subs_bs_consumption sbc
     JOIN subs_features sf ON sbc.sk_id = sf.sk_id AND sbc.mon = sf.snap_date
  GROUP BY sbc.sk_id, sbc.mon, sf.internet_type_id
WITH DATA;
