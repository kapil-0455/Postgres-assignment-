-- task 3: ddl, dml & transactions
-- =========================================================

set search_path to supply_chain;

-- ddl commands
-- =========================================================


-- create table

create table test_ddl_commands (
    id integer,
    name varchar(50)
);


-- check table

select *
from test_ddl_commands;


-- alter table

alter table test_ddl_commands
add column status varchar(20);


-- check updated table

select *
from test_ddl_commands;


-- drop table

drop table test_ddl_commands;


-- 2. truncate
-- =========================================================

-- create test table

create table test_truncate (
    id integer,
    name varchar(50)
);


-- insert records

insert into test_truncate values
(1, 'a'),
(2, 'b'),
(3, 'c');


-- check records

select *
from test_truncate;


-- remove all rows

truncate table test_truncate;


-- check table

select *
from test_truncate;


-- drop table

drop table test_truncate;


-- 3. insert test supplier
-- =========================================================

insert into suppliers (
    supplier_id,
    country,
    supplier_reliability,
    alternative_supplier_count
)
values (
    'SUP_TEST',
    'India',
    0.90,
    5
);


-- check supplier

select *
from suppliers
where supplier_id = 'SUP_TEST';



-- 4. insert test shipment
-- =========================================================

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
values (
    'SHP_TEST',
    'SUP_TEST',
    1,
    10000,
    5000,
    5,
    10,
    5000.00,
    100000.00,
    0
);


-- check shipment

select *
from shipments
where shipment_id = 'SHP_TEST';


-- 5. update using another table
-- =========================================================

update shipments s
set freight_cost_usd = freight_cost_usd * 1.05
from shipment_risk r
where s.shipment_id = r.shipment_id
  and r.current_delay_days > 0;


-- check updated shipments

select
    s.shipment_id,
    s.freight_cost_usd,
    r.current_delay_days
from shipments s
join shipment_risk r
    on s.shipment_id = r.shipment_id
where r.current_delay_days > 0
limit 10;


-- 6. update specific shipment
-- =========================================================

update shipments
set freight_cost_usd = 60000.00
where shipment_id = 'SHP_TEST';


-- check update

select
    shipment_id,
    freight_cost_usd
from shipments
where shipment_id = 'SHP_TEST';


-- 7. delete test records
-- =========================================================

delete from shipments
where shipment_id = 'SHP_TEST';


delete from suppliers
where supplier_id = 'SUP_TEST';


-- verify deletion

select *
from shipments
where shipment_id = 'SHP_TEST';


select *
from suppliers
where supplier_id = 'SUP_TEST';


-- 8. upsert
-- =========================================================

-- first insert

insert into suppliers (
    supplier_id,
    country,
    supplier_reliability,
    alternative_supplier_count
)
values (
    'SUP_UPSERT',
    'India',
    0.80,
    3
);


-- insert same id and update on conflict

insert into suppliers (
    supplier_id,
    country,
    supplier_reliability,
    alternative_supplier_count
)
values (
    'SUP_UPSERT',
    'UAE',
    0.95,
    7
)
on conflict (supplier_id)
do update set
    country = excluded.country,
    supplier_reliability = excluded.supplier_reliability,
    alternative_supplier_count = excluded.alternative_supplier_count;


-- check upsert

select *
from suppliers
where supplier_id = 'SUP_UPSERT';


-- delete test record

delete from suppliers
where supplier_id = 'SUP_UPSERT';


-- 9. transaction - commit
-- =========================================================

begin;

update suppliers
set supplier_reliability = 0.85
where supplier_id = 'SUP001';


-- validation

select *
from suppliers
where supplier_id = 'SUP001';


-- save changes

commit;



-- 10. transaction - rollback
-- =========================================================

begin;

update suppliers
set supplier_reliability = 0.10
where supplier_id = 'SUP001';


-- check temporary change

select
    supplier_id,
    supplier_reliability
from suppliers
where supplier_id = 'SUP001';


-- cancel change

rollback;


-- check after rollback

select
    supplier_id,
    supplier_reliability
from suppliers
where supplier_id = 'SUP001';