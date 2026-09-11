-- =========================================================
-- task 9 : indexing & query optimisation

set search_path to supply_chain;


-- =========================================================
-- query 1 : supplier filtering

select *
from shipments
where supplier_id = 'SUP001';


-- explain before index

explain
select *
from shipments
where supplier_id = 'SUP001';


-- explain analyze before index

explain analyze
select *
from shipments
where supplier_id = 'SUP001';



-- =========================================================
-- query 2 : country filtering

select *
from vw_shipment_risk
where country = 'Oman';


-- explain before index

explain
select *
from vw_shipment_risk
where country = 'Oman';


-- explain analyze before index

explain analyze
select *
from vw_shipment_risk
where country = 'Oman';



-- =========================================================
-- query 3 : product filtering

select *
from vw_shipment_risk
where product_type = 'Electronics';


-- explain before index

explain
select *
from vw_shipment_risk
where product_type = 'Electronics';


-- explain analyze before index

explain analyze
select *
from vw_shipment_risk
where product_type = 'Electronics';



-- =========================================================
-- query 4 : route risk filtering and sorting

select *
from shipment_risk
where route_risk_score >= 7
order by route_risk_score desc;


-- explain before index

explain
select *
from shipment_risk
where route_risk_score >= 7
order by route_risk_score desc;


-- explain analyze before index

explain analyze
select *
from shipment_risk
where route_risk_score >= 7
order by route_risk_score desc;



-- =========================================================
-- query 5 : delay probability filtering and sorting

select *
from shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;


-- explain before index

explain
select *
from shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;


-- explain analyze before index

explain analyze
select *
from shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;



-- =========================================================
-- create indexes


-- index for supplier filtering and joins

create index if not exists idx_shipments_supplier_id
on shipments(supplier_id);


-- index for country filtering

create index if not exists idx_suppliers_country
on suppliers(country);


-- index for product searching/filtering

create index if not exists idx_products_product_type
on products(product_type);


-- index for route risk filtering and sorting

create index if not exists idx_shipment_risk_route_risk
on shipment_risk(route_risk_score);


-- index for delay probability filtering and sorting

create index if not exists idx_shipment_risk_delay_probability
on shipment_risk(delay_probability);



-- =========================================================
-- explain after indexing

-- query 1

explain
select *
from shipments
where supplier_id = 'SUP001';


-- query 2

explain
select *
from vw_shipment_risk
where country = 'Oman';


-- query 3

explain
select *
from vw_shipment_risk
where product_type = 'Electronics';


-- query 4

explain
select *
from shipment_risk
where route_risk_score >= 7
order by route_risk_score desc;


-- query 5

explain
select *
from shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;



-- =========================================================
-- explain analyze after indexing


-- query 1

explain analyze
select *
from shipments
where supplier_id = 'SUP001';


-- query 2

explain analyze
select *
from vw_shipment_risk
where country = 'Oman';


-- query 3

explain analyze
select *
from vw_shipment_risk
where product_type = 'Electronics';


-- query 4

explain analyze
select *
from shipment_risk
where route_risk_score >= 7
order by route_risk_score desc;


-- query 5

explain analyze
select *
from shipment_risk
where delay_probability >= 0.70
order by delay_probability desc;