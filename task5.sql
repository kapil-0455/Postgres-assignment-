-- =========================================================
-- task 5 : aggregations

set search_path to supply_chain;


-- =========================================================
--  total number of shipments

select count(*) as total_shipments from shipments;


-- =========================================================
-- total shipment volume

select sum(shipment_volume_tons) as total_shipment_volume from shipments;


-- =========================================================
--  average shipment volume

select avg(shipment_volume_tons) as average_shipment_volume from shipments;


-- =========================================================
--  minimum and maximum shipment volume

select
    min(shipment_volume_tons) as minimum_shipment_volume,
    max(shipment_volume_tons) as maximum_shipment_volume
from shipments;


-- =========================================================
--  total freight cost and revenue impact

select
    sum(freight_cost_usd) as total_freight_cost,
    sum(revenue_impact_usd) as total_revenue_impact
from shipments;


-- =========================================================
--  average freight cost

select avg(freight_cost_usd) as average_freight_cost from shipments;


-- =========================================================
--  shipment count by supplier

select
    supplier_id,
    count(*) as total_shipments
from shipments
group by supplier_id
order by total_shipments desc;


-- =========================================================
--  total shipment volume by supplier

select
    supplier_id,
    sum(shipment_volume_tons) as total_volume
from shipments
group by supplier_id
order by total_volume desc;


-- =========================================================
--  average freight cost by supplier

select
    supplier_id,
    avg(freight_cost_usd) as average_freight_cost
from shipments
group by supplier_id
order by average_freight_cost desc;


-- =========================================================
--  supplier performance

select
    sup.supplier_id,
    sup.country,
    count(s.shipment_id) as total_shipments,
    sum(s.shipment_volume_tons) as total_volume_tons,
    avg(s.freight_cost_usd) as average_freight_cost,
    avg(s.revenue_impact_usd) as average_revenue_impact
from suppliers sup
left join shipments s
    on sup.supplier_id = s.supplier_id
group by
    sup.supplier_id,
    sup.country
order by
    total_volume_tons desc;


-- =========================================================
--  shipment count by country

select
    sup.country,
    count(s.shipment_id) as total_shipments
from suppliers sup
inner join shipments s
    on sup.supplier_id = s.supplier_id
group by sup.country
order by total_shipments desc;


-- =========================================================
--  total volume by country


select
    sup.country,
    sum(s.shipment_volume_tons) as total_volume_tons
from suppliers sup
inner join shipments s
    on sup.supplier_id = s.supplier_id
group by sup.country
order by total_volume_tons desc;


-- =========================================================
--  average supplier reliability by country

select
    country,
    avg(supplier_reliability) as average_supplier_reliability
from suppliers
group by country
order by average_supplier_reliability desc;


-- =========================================================
--  product-wise shipment analysis

select
    p.product_type,
    count(s.shipment_id) as total_shipments,
    sum(s.shipment_volume_tons) as total_volume_tons,
    avg(s.shipment_volume_tons) as average_volume_tons,
    sum(s.freight_cost_usd) as total_freight_cost,
    sum(s.revenue_impact_usd) as total_revenue_impact
from products p
left join shipments s
    on p.product_id = s.product_id
group by
    p.product_type
order by total_volume_tons desc;


-- =========================================================
--  product-wise average freight cost

select
    p.product_type,
    avg(s.freight_cost_usd) as average_freight_cost
from products p
inner join shipments s
    on p.product_id = s.product_id
group by p.product_type
order by average_freight_cost desc;


-- =========================================================
--  suppliers having more than 10 shipments

select
    supplier_id,
    count(*) as total_shipments
from shipments
group by supplier_id
having count(*) > 10
order by total_shipments desc;


-- =========================================================
-- countries with total shipment volume
-- greater than 1,000,000 tons


select
    sup.country,
    sum(s.shipment_volume_tons) as total_volume_tons
from suppliers sup
inner join shipments s
    on sup.supplier_id = s.supplier_id
group by sup.country
having sum(s.shipment_volume_tons) > 1000000
order by total_volume_tons desc;


-- =========================================================
--  suppliers with above-average freight cost

select
    supplier_id,
    avg(freight_cost_usd) as average_freight_cost
from shipments
group by supplier_id
having avg(freight_cost_usd) >
       (select avg(freight_cost_usd) from shipments)
order by average_freight_cost desc;


-- =========================================================
--  risk classification using case

select
    s.shipment_id,
    r.route_risk_score,
    r.delay_probability,
    r.current_delay_days,

    case
        when r.route_risk_score >= 8
             and r.delay_probability >= 0.7
            then 'critical'

        when r.route_risk_score >= 6
             or r.delay_probability >= 0.5
            then 'high'

        when r.route_risk_score >= 4
             or r.delay_probability >= 0.3
            then 'medium'

        else 'low'
    end as risk_category

from shipments s
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
order by
    r.route_risk_score desc;


-- =========================================================
--  count shipments by risk category

select
    case
        when r.route_risk_score >= 8
             and r.delay_probability >= 0.7
            then 'critical'

        when r.route_risk_score >= 6
             or r.delay_probability >= 0.5
            then 'high'

        when r.route_risk_score >= 4
             or r.delay_probability >= 0.3
            then 'medium'

        else 'low'
    end as risk_category,

    count(*) as total_shipments

from shipments s
inner join shipment_risk r
    on s.shipment_id = r.shipment_id

group by
    case
        when r.route_risk_score >= 8
             and r.delay_probability >= 0.7
            then 'critical'

        when r.route_risk_score >= 6
             or r.delay_probability >= 0.5
            then 'high'

        when r.route_risk_score >= 4
             or r.delay_probability >= 0.3
            then 'medium'

        else 'low'
    end

order by total_shipments desc;


-- =========================================================
--  disruption event analysis

select
    disruption_event,
    count(*) as total_shipments,
    sum(shipment_volume_tons) as total_volume_tons,
    avg(freight_cost_usd) as average_freight_cost,
    sum(revenue_impact_usd) as total_revenue_impact
from shipments
group by disruption_event
order by disruption_event;


-- =========================================================
-- average delay by country


select
    sup.country,
    avg(r.current_delay_days) as average_current_delay_days,
    max(r.current_delay_days) as maximum_current_delay_days
from suppliers sup
inner join shipments s
    on sup.supplier_id = s.supplier_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
group by sup.country
order by average_current_delay_days desc;


-- =========================================================
--  high delay suppliers

select
    s.supplier_id,
    avg(r.current_delay_days) as average_delay_days,
    max(r.current_delay_days) as maximum_delay_days
from shipments s
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
group by s.supplier_id
having avg(r.current_delay_days) > 5
order by average_delay_days desc;


-- =========================================================
--  overall business summary

select
    count(*) as total_shipments,
    sum(shipment_volume_tons) as total_volume_tons,
    avg(shipment_volume_tons) as average_volume_tons,
    min(shipment_volume_tons) as minimum_volume_tons,
    max(shipment_volume_tons) as maximum_volume_tons,
    sum(freight_cost_usd) as total_freight_cost,
    avg(freight_cost_usd) as average_freight_cost,
    sum(revenue_impact_usd) as total_revenue_impact,
    avg(revenue_impact_usd) as average_revenue_impact
from shipments;