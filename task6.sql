-- =========================================================
-- task 6 : subqueries and casting

set search_path to supply_chain;


-- =========================================================
-- above-average freight cost

select
    shipment_id,
    freight_cost_usd
from shipments
where freight_cost_usd > (
    select avg(freight_cost_usd)
    from shipments
)
order by freight_cost_usd desc;


-- =========================================================
--  above-average delay

select
    shipment_id,
    current_delay_days
from shipment_risk
where current_delay_days > (
    select avg(current_delay_days)
    from shipment_risk
)
order by current_delay_days desc;


-- =========================================================
--  below-average supplier reliability

select
    supplier_id,
    country,
    supplier_reliability
from suppliers
where supplier_reliability < (
    select avg(supplier_reliability)
    from suppliers
)
order by supplier_reliability;


-- =========================================================
--  shipments from country having high-risk shipments

select
    sup.country,
    s.shipment_id,
    r.route_risk_score
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
where r.route_risk_score > (
    select avg(route_risk_score)
    from shipment_risk
)
order by
    r.route_risk_score desc;


-- =========================================================
--  product with above-average shipment volume

select
    s.shipment_id,
    p.product_type,
    s.shipment_volume_tons
from shipments s
inner join products p
    on s.product_id = p.product_id
where s.shipment_volume_tons > (
    select avg(shipment_volume_tons)
    from shipments
)
order by s.shipment_volume_tons desc;


-- =========================================================
--  shipment with maximum revenue impact

select
    shipment_id,
    revenue_impact_usd
from shipments
where revenue_impact_usd = (
    select max(revenue_impact_usd)
    from shipments
);


-- =========================================================
--  second-highest freight cost

select
    shipment_id,
    freight_cost_usd
from shipments
where freight_cost_usd = (
    select max(freight_cost_usd)
    from shipments
    where freight_cost_usd < (
        select max(freight_cost_usd)
        from shipments
    )
);


-- =========================================================
--  correlated subquery

select
    s.shipment_id,
    sup.country,
    r.route_risk_score
from shipments s
inner join suppliers sup
    on s.supplier_id = sup.supplier_id
inner join shipment_risk r
    on s.shipment_id = r.shipment_id
where r.route_risk_score = (
    select max(r2.route_risk_score)
    from shipments s2
    inner join suppliers sup2
        on s2.supplier_id = sup2.supplier_id
    inner join shipment_risk r2
        on s2.shipment_id = r2.shipment_id
    where sup2.country = sup.country
)
order by
    sup.country,
    r.route_risk_score desc;


-- =========================================================
--  cast() - percentage calculation

select
    count(*) as total_shipments,

    count(*) filter (
        where r.route_risk_score >= 7
           or r.delay_probability >= 0.7
           or r.current_delay_days >= 10
    ) as critical_shipments,

    cast(
        count(*) filter (
            where r.route_risk_score >= 7
               or r.delay_probability >= 0.7
               or r.current_delay_days >= 10
        ) as decimal
    )
    /
    count(*) * 100 as critical_percentage

from shipments s
inner join shipment_risk r
    on s.shipment_id = r.shipment_id;


-- =========================================================
--  postgresql :  casting

SELECT
    shipment_id,
    freight_cost_usd,
    CAST(freight_cost_usd AS INTEGER) AS freight_cost_integer,
    CAST(delay_probability AS DECIMAL(5,2)) AS delay_probability_decimal
FROM shipments s
INNER JOIN shipment_risk r
    ON s.shipment_id = r.shipment_id
ORDER BY shipment_id;