set search_path to supply_chain;

select
    v.shipment_id as shipment_id,
    v.supplier_id as supplier,
    v.country,
    v.product_type as product,
    s.shipment_volume_tons as shipment_volume,
    v.route_risk_score as route_risk,
    v.political_risk_index as political_risk,
    v.port_congestion_index as port_congestion,
    sup.supplier_reliability,
    v.inventory_days,
    s.transit_time_days as transit_time,
    v.delay_probability,
    v.current_delay_days as current_delay,
    s.freight_cost_usd as freight_cost,
    s.revenue_impact_usd as revenue_impact,

    fn_risk_classification(
        v.route_risk_score,
        v.delay_probability,
        v.current_delay_days,
        v.inventory_days
    ) as risk_classification,

    cast(
        (
            v.route_risk_score
            + v.political_risk_index
            + v.port_congestion_index
            + (v.delay_probability * 10)
            + v.current_delay_days
            + (30 - v.inventory_days)
            + ((1 - sup.supplier_reliability) * 10)
        )
        as decimal(10,2)
    ) as supply_chain_risk_score,

    (
        select avg(freight_cost_usd)
        from shipments
    ) as average_freight_cost,

    (
        select max(revenue_impact_usd)
        from shipments
    ) as maximum_revenue_impact,
	
    case
        when v.route_risk_score >= 8
             and v.delay_probability >= 0.70
             and v.current_delay_days >= 10
        then 'critical'

        when v.route_risk_score >= 6
             and v.delay_probability >= 0.60
        then 'high'

        else 'medium'
    end as final_risk_level
from vw_shipment_risk v
inner join shipments s
    on v.shipment_id = s.shipment_id
inner join suppliers sup
    on v.supplier_id = sup.supplier_id
where v.route_risk_score >= 7
  and v.delay_probability >= 0.70
  and v.current_delay_days >= 10
  and v.inventory_days <= 30
order by supply_chain_risk_score desc
limit 20;