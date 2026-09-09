-- task 1: database setup & data loading
-- =========================================================

-- create database

create database "SupplyChainRiskDB";

-- create schema
create schema supply_chain;
set search_path to supply_chain;


--create raw table

create table shipment_raw (
    shipment_id varchar(20),
    supplier_id varchar(20),
    country varchar(50),
    product_type varchar(50),

    monthly_demand_tons integer,
    shipment_volume_tons integer,

    route_risk_score decimal,
    historical_delay_days integer,

    fuel_price_usd decimal,
    political_risk_index decimal,
    port_congestion_index decimal,

    inventory_days integer,

    supplier_reliability decimal,
    alternative_supplier_count integer,

    transit_time_days integer,
    delay_probability decimal,

    current_delay_days integer,

    freight_cost_usd decimal,
    revenue_impact_usd decimal,

    disruption_event integer
);


--import csv

copy shipment_raw
from 'C:/YOUR_PATH/supply_chain_hormuz_crisis_700.csv'
with (
    format csv,
    header true,
    delimiter ','
);


--total records
select count(*) as total_records
from shipment_raw;


-- column count
select count(*) as total_columns
from pg_attribute
where attrelid = 'supply_chain.shipment_raw'::regclass
  and attnum > 0
  and not attisdropped;


--check data

select *
from shipment_raw
limit 10;


-- null values check

select
    count(*) filter (where shipment_id is null) as shipment_id_nulls,
    count(*) filter (where supplier_id is null) as supplier_id_nulls,
    count(*) filter (where country is null) as country_nulls,
    count(*) filter (where product_type is null) as product_type_nulls,
    count(*) filter (where monthly_demand_tons is null) as monthly_demand_nulls,
    count(*) filter (where shipment_volume_tons is null) as shipment_volume_nulls,
    count(*) filter (where route_risk_score is null) as route_risk_nulls,
    count(*) filter (where historical_delay_days is null) as historical_delay_nulls,
    count(*) filter (where fuel_price_usd is null) as fuel_price_nulls,
    count(*) filter (where political_risk_index is null) as political_risk_nulls,
    count(*) filter (where port_congestion_index is null) as port_congestion_nulls,
    count(*) filter (where inventory_days is null) as inventory_nulls,
    count(*) filter (where supplier_reliability is null) as reliability_nulls,
    count(*) filter (where alternative_supplier_count is null) as alternative_supplier_nulls,
    count(*) filter (where transit_time_days is null) as transit_time_nulls,
    count(*) filter (where delay_probability is null) as delay_probability_nulls,
    count(*) filter (where current_delay_days is null) as current_delay_nulls,
    count(*) filter (where freight_cost_usd is null) as freight_cost_nulls,
    count(*) filter (where revenue_impact_usd is null) as revenue_impact_nulls,
    count(*) filter (where disruption_event is null) as disruption_event_nulls
from shipment_raw;


-- duplicate shipment ids

select
    shipment_id,
    count(*) as count
from shipment_raw
group by shipment_id
having count(*) > 1;


-- duplicate supplier ids

select
    supplier_id,
    count(*) as count
from shipment_raw
group by supplier_id
having count(*) > 1;


--negative values check

select *
from shipment_raw
where monthly_demand_tons < 0
   or shipment_volume_tons < 0
   or historical_delay_days < 0
   or fuel_price_usd < 0
   or inventory_days < 0
   or alternative_supplier_count < 0
   or transit_time_days < 0
   or current_delay_days < 0
   or freight_cost_usd < 0
   or revenue_impact_usd < 0;


--delay probability & supplier reliability check

select *
from shipment_raw
where delay_probability not between 0 and 1
   or supplier_reliability not between 0 and 1;


-- risk index check

select *
from shipment_raw
where route_risk_score < 0
   or political_risk_index < 0
   or port_congestion_index < 0;


