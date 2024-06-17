select 
    {{ dbt_utils.star(from=ref('orders'), except=["orderdate"]) }},
    to_timestamp(orderdate, 'YYYY-MM-DD HH24:MI:SS.FF3') as orderdate
from {{ ref('orders') }}
