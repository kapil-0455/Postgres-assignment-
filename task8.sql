-- =========================================================
-- task 8 : functions, procedures and triggers

set search_path to supply_chain;


-- =========================================================
--  risk classification function


create or replace function fn_risk_classification(
    p_route_risk decimal,
    p_delay_probability decimal,
    p_current_delay integer,
    p_inventory_days integer
)
returns varchar(20)
language plpgsql
as $$
begin

    if p_route_risk >= 8
       or p_delay_probability >= 0.80
       or p_current_delay >= 15
       or p_inventory_days <= 10
    then
        return 'critical';

    elsif p_route_risk >= 6
          or p_delay_probability >= 0.60
          or p_current_delay >= 10
          or p_inventory_days <= 20
    then
        return 'high';

    elsif p_route_risk >= 4
          or p_delay_probability >= 0.40
          or p_current_delay >= 5
          or p_inventory_days <= 30
    then
        return 'medium';

    else
        return 'low';
    end if;

end;
$$;


-- =========================================================
-- test risk classification function

select fn_risk_classification(
    8.5,
    0.85,
    16,
    8
);


-- =========================================================
--  freight risk function

create or replace function fn_freight_risk(
    p_shipment_volume decimal,
    p_fuel_price decimal,
    p_route_risk decimal
)
returns decimal
language plpgsql
as $$
begin

    return
        (p_shipment_volume * p_fuel_price * p_route_risk)
        / 1000;

end;
$$;


-- =========================================================
-- test freight risk function
select fn_freight_risk(
    5000,
    80,
    7
);


-- =========================================================
--  add risk classification column

alter table shipments
add column if not exists risk_classification varchar(20);


-- =========================================================
--  procedure

create or replace procedure sp_update_risk_classification(
    p_shipment_id varchar(20)
)
language plpgsql
as $$
declare
    v_risk_classification varchar(20);
begin

    select fn_risk_classification(
        r.route_risk_score,
        r.delay_probability,
        r.current_delay_days,
        i.inventory_days
    )
    into v_risk_classification
    from shipment_risk r
    inner join inventory i
        on r.shipment_id = i.shipment_id
    where r.shipment_id = p_shipment_id;


    if v_risk_classification is null then

        raise exception
            'shipment id % not found',
            p_shipment_id;

    end if;


    update shipments
    set risk_classification = v_risk_classification
    where shipment_id = p_shipment_id;

end;
$$;


-- =========================================================
-- test procedure

select shipment_id
from shipments
limit 5;


-- =========================================================
--  audit table

create table if not exists risk_classification_audit (
    audit_id serial primary key,
    shipment_id varchar(20),
    old_value varchar(20),
    new_value varchar(20),
    operation varchar(20),
    changed_at timestamp default current_timestamp
);


-- =========================================================
--  audit trigger function

create or replace function fn_audit_risk_classification()
returns trigger
language plpgsql
as $$
begin

    insert into risk_classification_audit (
        shipment_id,
        old_value,
        new_value,
        operation,
        changed_at
    )
    values (
        new.shipment_id,
        old.risk_classification,
        new.risk_classification,
        tg_op,
        current_timestamp
    );

    return new;

end;
$$;


-- =========================================================
--  audit trigger

drop trigger if exists trg_audit_risk_classification
on shipments;


create trigger trg_audit_risk_classification
after update of risk_classification
on shipments
for each row
when (
    old.risk_classification is distinct from
    new.risk_classification
)
execute function fn_audit_risk_classification();


-- =========================================================
-- test audit trigger

select *
from risk_classification_audit
order by changed_at desc;


-- =========================================================
--  shipment validation function

create or replace function fn_validate_shipment()
returns trigger
language plpgsql
as $$
begin

    if new.shipment_volume_tons <= 0 then

        raise exception
            'shipment volume must be greater than 0';

    end if;


    if new.freight_cost_usd < 0 then

        raise exception
            'freight cost cannot be negative';

    end if;


    return new;

end;
$$;


-- =========================================================
--  shipment validation trigger

drop trigger if exists trg_validate_shipment
on shipments;


create trigger trg_validate_shipment
before insert or update
on shipments
for each row
execute function fn_validate_shipment();


-- =========================================================
--  shipment risk validation function

create or replace function fn_validate_shipment_risk()
returns trigger
language plpgsql
as $$
begin

    if new.delay_probability < 0
       or new.delay_probability > 1
    then

        raise exception
            'delay probability must be between 0 and 1';

    end if;


    return new;

end;
$$;


-- =========================================================
--  shipment risk validation trigger

drop trigger if exists trg_validate_shipment_risk
on shipment_risk;


create trigger trg_validate_shipment_risk
before insert or update
on shipment_risk
for each row
execute function fn_validate_shipment_risk();



-- =========================================================
--  final checks

-- functions

select
    routine_name
from information_schema.routines
where routine_schema = 'supply_chain'
and routine_type = 'function'
order by routine_name;


-- procedures

select
    routine_name
from information_schema.routines
where routine_schema = 'supply_chain'
and routine_type = 'procedure'
order by routine_name;


-- triggers

select
    trigger_name,
    event_object_table
from information_schema.triggers
where trigger_schema = 'supply_chain'
order by trigger_name;


-- audit records

select *
from risk_classification_audit
order by changed_at desc;