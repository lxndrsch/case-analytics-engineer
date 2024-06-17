with cte_customer_orders_agg as (
    select
        customer_id,
        order_id,
        sum(unit_price * quantity) as total_revenue_per_order
    from {{ ref('fct_sales') }}
    group by customer_id, order_id
),
cte_customer_agg as (
    select
        customer_id,
        count(distinct order_id) as num_orders,
        max(total_revenue_per_order) as max_order_value,
        sum(total_revenue_per_order) as total_revenue
    from cte_customer_orders_agg
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