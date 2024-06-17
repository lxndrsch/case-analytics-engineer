with calendar as (
    {{ dbt_date.get_base_dates(start_date="1996-01-01", end_date="1998-12-01", datepart = "month") }}
),
customer_first_purchase as (
    select
        customer_id,
        min(order_date) as first_order_date,
        sum(unit_price * quantity) as cohort_total_order_value
    from {{ ref('fct_sales') }}
    group by customer_id
)

select * 
from calendar cal
left join customer_first_purchase cfp
    on cal.date_month = date_trunc("month", cfp.first_order_date)