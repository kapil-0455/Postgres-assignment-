-- =========================================================
-- task 7 : views & reusable reporting

set search_path to supply_chain;


-- =========================================================
-- view 1 : supplier performance

create or replace view vw_supplier_performance as
select
    sup.supplier_id,
    sup.country,
    count(s.shipment_id) as shipment_count,
    coalesce(sum(s.shipment_volume_tons), 0) as total_shipment_volume,
    coalesce(avg(s.historical_delay_days), 0) as average_delay,
    coalesce(avg(sup.supplier_reliability), 0) as average_reliability,
    coalesce(sum(s.freight_cost_usd), 0) as total_freight_cost,
    coalesce(sum(s.revenue_impact_usd), 0) as total_revenue_impact
from suppliers sup
left join shipments s
    on sup.supplier_id = s.supplier_id
group by
    sup.supplier_id,
    sup.country;


-- check view 1

select * from vw_supplier_performance
order by total_shipment_volume desc;



-- =========================================================
-- view 2 : shipment risk

create or replace view vw_shipment_risk as
select
    s.shipment_id,
    s.supplier_id,
    sup.country,
    p.product_type,
    r.route_risk_score,
    r.political_risk_index,
    r.port_congestion_index,
    r.delay_probability,
    r.current_delay_days,
    i.inventory_days
from shipments s
inner join suppliers sup on s.supplier_id = sup.supplier_id
inner join products p on s.product_id = p.product_id
inner join shipment_risk r on s.shipment_id = r.shipment_id
inner join inventory i on s.shipment_id = i.shipment_id;


-- check view 2

select * from vw_shipment_risk
order by route_risk_score desc;



-- =========================================================
-- view 3 : critical shipments

create or replace view vw_critical_shipments as
select
    shipment_id,
    supplier_id,
    country,
    product_type,
    route_risk_score,
    political_risk_index,
    port_congestion_index,
    delay_probability,
    current_delay_days,
    inventory_days
from vw_shipment_risk
where
    route_risk_score >= 7
    and delay_probability >= 0.70
    and current_delay_days >= 10
    and inventory_days <= 30;


-- check view 3

select * from vw_critical_shipments
order by
    route_risk_score desc,
    delay_probability desc,
    current_delay_days desc;



-- =========================================================
-- query 1 : supplier performance

select
    supplier_id,
    country,
    shipment_count,
    total_shipment_volume,
    average_delay,
    average_reliability
from vw_supplier_performance
order by total_shipment_volume desc
limit 10;



-- =========================================================
-- query 2 : low reliability suppliers

select
    supplier_id,
    country,
    shipment_count,
    average_reliability,
    average_delay
from vw_supplier_performance
where average_reliability < 0.70
order by average_reliability asc;



-- =========================================================
-- query 3 : high-risk shipments

select
    shipment_id,
    supplier_id,
    country,
    product_type,
    route_risk_score,
    delay_probability,
    current_delay_days,
    inventory_days
from vw_shipment_risk
where
    route_risk_score >= 7
order by route_risk_score desc;



-- =========================================================
-- query 4 : shipments with high delay probability

select
    shipment_id,
    supplier_id,
    country,
    product_type,
    delay_probability,
from vw_shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;


-- =========================================================
-- query 5 : country-wise critical shipments

select
    country,
    count(*) as critical_shipment_count
from vw_critical_shipments
group by country
order by critical_shipment_count desc;



