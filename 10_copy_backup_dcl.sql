-- =========================================================
-- task 10 : copy, export, import, backup, restore & dcl

set search_path to supply_chain;


-- =========================================================
-- a. export using copy
-- a1. export critical shipments

copy (
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
    from vw_critical_shipments
    order by route_risk_score desc
)
to 'C:\SupplyChainBackup\critical_shipments.csv'
with (
    format csv,
    header true,
    delimiter ','
);

-- a2. export supplier summary

copy (
    select
        supplier_id,
        country,
        shipment_count,
        total_shipment_volume,
        average_delay,
        average_reliability,
        total_freight_cost,
        total_revenue_impact
    from vw_supplier_performance
    order by total_shipment_volume desc
)
to 'C:\SupplyChainBackup\supplier_summary.csv'
with (
    format csv,
    header true,
    delimiter ','
);


-- =========================================================
-- b. import using copy
-- b1. critical shipments staging table

create table critical_shipments_staging (
    shipment_id varchar(20),
    supplier_id varchar(20),
    country varchar(50),
    product_type varchar(50),
    route_risk_score decimal,
    political_risk_index decimal,
    port_congestion_index decimal,
    delay_probability decimal,
    current_delay_days integer,
    inventory_days integer
);

-- b2. import critical shipments csv

copy critical_shipments_staging
from 'C:\SupplyChainBackup\critical_shipments.csv'
with (
    format csv,
    header true,
    delimiter ','
);

-- b3. verify critical shipment row count

select
    count(*) as imported_rows
from critical_shipments_staging;

-- b4. verify critical shipment column count

select
    count(*) as total_columns
from information_schema.columns
where table_schema = 'supply_chain'
  and table_name = 'critical_shipments_staging';

-- b5. critical shipment data consistency

select
    (select count(*)
     from vw_critical_shipments) as original_rows,

    (select count(*)
     from critical_shipments_staging) as imported_rows;


-- b6. supplier summary staging table

create table supplier_summary_staging (
    supplier_id varchar(20),
    country varchar(50),
    shipment_count bigint,
    total_shipment_volume bigint,
    average_delay decimal,
    average_reliability decimal,
    total_freight_cost decimal,
    total_revenue_impact decimal
);

-- b7. import supplier summary csv

copy supplier_summary_staging
from 'C:\SupplyChainBackup\supplier_summary.csv'
with (
    format csv,
    header true,
    delimiter ','
);

-- b8. verify supplier summary row count

select
    count(*) as imported_rows
from supplier_summary_staging;

-- b9. verify supplier summary column count

select
    count(*) as total_columns
from information_schema.columns
where table_schema = 'supply_chain'
  and table_name = 'supplier_summary_staging';

-- b10. supplier summary data consistency
select
    (select count(*)
     from vw_supplier_performance) as original_rows,

    (select count(*)
     from supplier_summary_staging) as imported_rows;



-- =========================================================
-- c. database backup
-- =========================================================

-- note:
-- pg_dump sql query tool mein execute nahi hota.
-- ye commands windows cmd / powershell mein run hongi.

-- ==============================
-- full backup:

-- pg_dump -u postgres -d SupplyChainRiskDB -F c
-- -f "C:\SupplyChainBackup\SupplyChainRiskDB_full.backup"

-- ===============================
-- schema-only backup:
-- pg_dump -u postgres -d SupplyChainRiskDB
-- --schema-only
-- -f "C:\SupplyChainBackup\SupplyChainRiskDB_schema.sql"

-- ===========================
-- data-only backup:
-- pg_dump -u postgres -d SupplyChainRiskDB
-- --data-only
-- -f "C:\SupplyChainBackup\SupplyChainRiskDB_data.sql"



-- =========================================================
-- d. restore

-- first create database:

-- SupplyChainRiskDB_Restore


-- then windows cmd / powershell:

-- pg_restore -u postgres
-- -d SupplyChainRiskDB_Restore
-- "C:\SupplyChainBackup\SupplyChainRiskDB_full.backup"



-- =========================================================
-- d1. verify tables after restore

select
    table_name
from information_schema.tables
where table_schema = 'supply_chain'
order by table_name;


-- =========================================================
-- d2. verify data after restore

select
    count(*) as total_shipments
from supply_chain.shipments;


select
    count(*) as total_suppliers
from supply_chain.suppliers;

-- d3. verify constraints

select
    constraint_name,
    table_name,
    constraint_type
from information_schema.table_constraints
where table_schema = 'supply_chain'
order by
    table_name,
    constraint_name;

-- d4. verify views

select
    table_name as view_name
from information_schema.views
where table_schema = 'supply_chain'
order by table_name;

-- d5. verify functions and procedures

select
    routine_name,
    routine_type
from information_schema.routines
where routine_schema = 'supply_chain'
order by
    routine_type,
    routine_name;

-- d6. verify triggers
select
    trigger_name,
    event_object_table
from information_schema.triggers
where trigger_schema = 'supply_chain'
order by trigger_name;

-- d7. verify indexes
select
    indexname,
    tablename
from pg_indexes
where schemaname = 'supply_chain'
order by
    tablename,
    indexname;



-- =========================================================
-- e. dcl & role management
-- =========================================================
-- e1. create admin role

create role supply_chain_admin
login
password 'Admin@123';

-- e2. create analyst role

create role supply_chain_analyst
login
password 'Analyst@123';

-- e3. create viewer role

create role supply_chain_viewer
login
password 'Viewer@123';

-- e4. admin permissions

grant all privileges
on schema supply_chain
to supply_chain_admin;


grant all privileges
on all tables in schema supply_chain
to supply_chain_admin;


grant all privileges
on all sequences in schema supply_chain
to supply_chain_admin;


grant all privileges
on all functions in schema supply_chain
to supply_chain_admin;

-- e5. analyst permissions

grant usage
on schema supply_chain
to supply_chain_analyst;


grant select,
      insert,
      update
on all tables in schema supply_chain
to supply_chain_analyst;


-- explicit select on views

grant select
on vw_supplier_performance,
   vw_shipment_risk,
   vw_critical_shipments
to supply_chain_analyst;


-- e6. viewer permissions

grant usage
on schema supply_chain
to supply_chain_viewer;


grant select
on all tables in schema supply_chain
to supply_chain_viewer;


-- explicit select on views

grant select
on vw_supplier_performance,
   vw_shipment_risk,
   vw_critical_shipments
to supply_chain_viewer;

-- e7. verify granted permissions

select
    grantee,
    table_name,
    privilege_type
from information_schema.role_table_grants
where grantee in (
    'supply_chain_admin',
    'supply_chain_analyst',
    'supply_chain_viewer'
)
order by
    grantee,
    table_name,
    privilege_type;

-- e8. revoke demonstration
-- analyst se update permission temporarily remove karna.

revoke update
on all tables in schema supply_chain
from supply_chain_analyst;


-- verify revoke

select
    grantee,
    table_name,
    privilege_type
from information_schema.role_table_grants
where grantee = 'supply_chain_analyst'
order by
    table_name,
    privilege_type;



-- e9. restore analyst update permission

grant update
on all tables in schema supply_chain
to supply_chain_analyst;

-- e10. final permission verification
select
    grantee,
    table_name,
    privilege_type
from information_schema.role_table_grants
where grantee in (
    'supply_chain_admin',
    'supply_chain_analyst',
    'supply_chain_viewer'
)
order by
    grantee,
    table_name,
    privilege_type;