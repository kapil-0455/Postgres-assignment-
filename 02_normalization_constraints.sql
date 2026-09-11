-- task 2: normalization & constraints
-- =========================================================

set search_path to supply_chain;


-- supplier information

create table suppliers (
    supplier_id varchar(20) primary key,
    country varchar(50) not null,
    supplier_reliability decimal
        check (supplier_reliability between 0 and 1),
    alternative_supplier_count integer
        check (alternative_supplier_count >= 0)
);


-- product information

create table products (
    product_id serial primary key,
    product_type varchar(50) not null unique
);


-- main shipment information

create table shipments (
    shipment_id varchar(20) primary key,
    supplier_id varchar(20) not null,
    product_id integer not null,

    monthly_demand_tons integer
        check (monthly_demand_tons >= 0),

    shipment_volume_tons integer
        check (shipment_volume_tons > 0),

    historical_delay_days integer
        check (historical_delay_days >= 0),

    transit_time_days integer
        check (transit_time_days >= 0),

    freight_cost_usd decimal
        check (freight_cost_usd >= 0),

    revenue_impact_usd decimal
        check (revenue_impact_usd >= 0),

    disruption_event integer,

    constraint fk_shipment_supplier
        foreign key (supplier_id)
        references suppliers(supplier_id),

    constraint fk_shipment_product
        foreign key (product_id)
        references products(product_id)
);


--shipment risk information

create table shipment_risk (
    shipment_id varchar(20) primary key,

    route_risk_score decimal
        check (route_risk_score >= 0),

    political_risk_index decimal
        check (political_risk_index >= 0),

    port_congestion_index decimal
        check (port_congestion_index >= 0),

    delay_probability decimal
        check (delay_probability between 0 and 1),

    current_delay_days integer
        check (current_delay_days >= 0),

    constraint fk_risk_shipment
        foreign key (shipment_id)
        references shipments(shipment_id)
);


-- inventory information

create table inventory (
    shipment_id varchar(20) primary key,

    inventory_days integer
        check (inventory_days >= 0),

    constraint fk_inventory_shipment
        foreign key (shipment_id)
        references shipments(shipment_id)
);


-- insert data
-- =========================================================


-- insert unique supplier records

insert into suppliers (
    supplier_id,
    country,
    supplier_reliability,
    alternative_supplier_count
)
select distinct on (supplier_id)
    supplier_id,
    country,
    supplier_reliability,
    alternative_supplier_count
from shipment_raw
where supplier_id is not null
  and country is not null
  and supplier_reliability between 0 and 1
  and alternative_supplier_count >= 0
order by supplier_id
on conflict (supplier_id) do nothing;


-- insert unique product records

insert into products (
    product_type
)
select distinct product_type
from shipment_raw
where product_type is not null
on conflict (product_type) do nothing;


-- insert shipment records

insert into shipments (
    shipment_id,
    supplier_id,
    product_id,
    monthly_demand_tons,
    shipment_volume_tons,
    historical_delay_days,
    transit_time_days,
    freight_cost_usd,
    revenue_impact_usd,
    disruption_event
)
select
    r.shipment_id,
    r.supplier_id,
    p.product_id,
    r.monthly_demand_tons,
    r.shipment_volume_tons,
    r.historical_delay_days,
    r.transit_time_days,
    r.freight_cost_usd,
    r.revenue_impact_usd,
    r.disruption_event
from shipment_raw r
join products p
    on r.product_type = p.product_type
join suppliers sp
    on r.supplier_id = sp.supplier_id
where r.shipment_id is not null
  and r.supplier_id is not null
  and r.monthly_demand_tons >= 0
  and r.shipment_volume_tons > 0
  and r.historical_delay_days >= 0
  and r.transit_time_days >= 0
  and r.freight_cost_usd >= 0
  and r.revenue_impact_usd >= 0
on conflict (shipment_id) do nothing;


-- insert shipment risk records

insert into shipment_risk (
    shipment_id,
    route_risk_score,
    political_risk_index,
    port_congestion_index,
    delay_probability,
    current_delay_days
)
select
    r.shipment_id,
    r.route_risk_score,
    r.political_risk_index,
    r.port_congestion_index,
    r.delay_probability,
    r.current_delay_days
from shipment_raw r
join shipments s
    on r.shipment_id = s.shipment_id
where r.route_risk_score >= 0
  and r.political_risk_index >= 0
  and r.port_congestion_index >= 0
  and r.delay_probability between 0 and 1
  and r.current_delay_days >= 0
on conflict (shipment_id) do nothing;


-- insert inventory records

insert into inventory (
    shipment_id,
    inventory_days
)
select
    r.shipment_id,
    r.inventory_days
from shipment_raw r
join shipments s
    on r.shipment_id = s.shipment_id
where r.inventory_days >= 0
on conflict (shipment_id) do nothing;


-- verify normalized tables
-- =========================================================


-- suppliers count

select count(*) as total_suppliers
from suppliers;


-- products count

select count(*) as total_products
from products;


-- shipments count

select count(*) as total_shipments
from shipments;


-- shipment risk count

select count(*) as total_risk_records
from shipment_risk;


-- inventory count

select count(*) as total_inventory_records
from inventory;