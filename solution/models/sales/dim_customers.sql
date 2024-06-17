with cte_customer_agg as (
    select
        customer_id,
        count(distinct order_id) as num_orders,
        max(unit_price) as max_order_value,
        sum(unit_price) as total_revenue
    from {{ ref('fct_sales') }}
    group by customer_id
)

select
    c.country,
    customer_id,
    num_orders,
    max_order_value,
    -- there could be more then 10 top customers in case of ties.
    case
        when rank() over (order by total_revenue desc) <= 10 then true 
        else false
    end as top_10_customer
from cte_customer_agg cte_ca
join {{ ref('customers') }} c
    on cte_ca.customer_id = c.customerid