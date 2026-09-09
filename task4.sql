-- =========================================================
-- task 4: joins

set search_path to supply_chain;

-- =========================================================
--  inner join

select
    s.shipment_id,
    s.supplier_id,
    sup.country,
    sup.supplier_reliability,
    s.shipment_volume_tons,
    s.freight_cost_usd
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
order by s.shipment_id;


-- =========================================================
--  left join

select
    s.shipment_id,
    s.supplier_id,
    sup.country,
    sup.supplier_reliability
from shipments s
left join suppliers sup
    on s.supplier_id = sup.supplier_id
order by s.shipment_id;


-- =========================================================
--  right join

select
    s.shipment_id,
    sup.supplier_id,
    sup.country,
    sup.supplier_reliability
from shipments s
right join suppliers sup
    on s.supplier_id = sup.supplier_id
order by sup.supplier_id;


-- =========================================================
-- full outer join

select
    s.shipment_id,
    s.supplier_id as shipment_supplier_id,
    sup.supplier_id as supplier_table_id,
    sup.country
from shipments s
full outer join suppliers sup
    on s.supplier_id = sup.supplier_id
order by coalesce(s.supplier_id, sup.supplier_id);


-- =========================================================
--  cross join

select
    p.product_id,
    p.product_type,
    sup.supplier_id,
    sup.country
from products p
cross join suppliers sup
order by
    p.product_id,
    sup.supplier_id;


-- =========================================================
--  supplier shipment report

select
    sup.supplier_id,
    sup.country,
    sup.supplier_reliability,
    s.shipment_id,
    s.shipment_volume_tons,
    s.freight_cost_usd,
    s.revenue_impact_usd
from suppliers sup
inner join shipments s
    on sup.supplier_id = s.supplier_id
order by
    sup.supplier_id,
    s.shipment_id;


-- =========================================================
--  product performance report

select
    p.product_id,
    p.product_type,
    count(s.shipment_id) as total_shipments,
    sum(s.shipment_volume_tons) as total_volume_tons,
    sum(s.freight_cost_usd) as total_freight_cost,
    sum(s.revenue_impact_usd) as total_revenue_impact
from products p
left join shipments s
    on p.product_id = s.product_id
group by
    p.product_id,
    p.product_type
order by
    total_volume_tons desc;


-- =========================================================
--  critical shipment report

select
    s.shipment_id,
    sup.supplier_id,
    sup.country,
    p.product_type,
    r.route_risk_score,
    r.delay_probability,
    r.current_delay_days,
    s.shipment_volume_tons,
    s.freight_cost_usd,
    s.revenue_impact_usd
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
inner join products p
    on s.product_id = p.product_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
where
    r.route_risk_score >= 7
    or r.delay_probability >= 0.7
    or r.current_delay_days >= 10
order by
    r.route_risk_score desc,
    r.delay_probability desc,
    r.current_delay_days desc;


-- =========================================================
--  multi-table join

select
    s.shipment_id,
    sup.supplier_id,
    sup.country,
    p.product_type,
    s.shipment_volume_tons,
    r.route_risk_score,
    r.delay_probability,
    r.current_delay_days,
    i.inventory_days,
    s.freight_cost_usd,
    s.revenue_impact_usd
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
inner join products p
    on s.product_id = p.product_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
inner join inventory i
    on s.shipment_id = i.shipment_id
order by
    s.shipment_id;


-- =========================================================
--  high-risk shipments with supplier information

select
    s.shipment_id,
    sup.supplier_id,
    sup.country,
    sup.supplier_reliability,
    r.route_risk_score,
    r.delay_probability,
    r.current_delay_days
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
where
    r.route_risk_score >= 7
    and r.delay_probability >= 0.5
order by
    r.route_risk_score desc;


-- =========================================================
--  shipments with inventory and risk

select
    s.shipment_id,
    p.product_type,
    i.inventory_days,
    r.route_risk_score,
    r.delay_probability,
    r.current_delay_days
from shipments s
inner join products p
    on s.product_id = p.product_id
inner join inventory i
    on s.shipment_id = i.shipment_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
order by
    r.route_risk_score desc,
    i.inventory_days asc;