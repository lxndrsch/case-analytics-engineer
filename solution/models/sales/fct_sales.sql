with cte_sales_data as (
    select
        od.orderid as order_id,
        od.productid as product_id,
        o.customerid as customer_id,
        o.orderdate as order_date,
        od.unitPrice as unit_price,
        od.quantity as quantity,
        dense_rank() over (partition by o.customerid order by o.orderdate, o.orderid) as order_seq,
        datediff('day',
            min(o.orderdate) over (partition by o.customerid),
            max(o.orderdate) over (partition by o.customerid)
        ) as days_between_first_last_purchase
    from {{ ref("stg_orders") }} o
    join {{ ref("order_details") }} od on od.orderid = o.orderid
    join {{ ref("products") }} p on od.productid = p.productid
)

select
    *,
    case
        when max(order_seq) over (partition by customer_id) > 1 then 'returning'
        else 'new'
    end as customer_type
from cte_sales_data