with stg_orders as 
(
    select
        OrderID,  
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey, 
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey, 
        replace(to_date(orderdate)::varchar,'-','')::int as orderdatekey
    from {{source('northwind','Orders')}}
),
stg_order_details as
(
    select 
        orderid,
         {{ dbt_utils.generate_surrogate_key(['productid']) }} as productkey, 
        sum(Quantity) as quantityonorder, 
        sum(Quantity*UnitPrice) as extendedpriceamount,
        sum(Quantity*UnitPrice*Discount) as discountamount,
        sum(Quantity*UnitPrice-Quantity*UnitPrice*Discount) as soldamount
    from {{source('northwind','Order_Details')}}
    group by orderid, productid
)

select *
from (
    select 
        o.*,
        od.productkey,
        od.quantityonorder,
        od.extendedpriceamount,
        od.discountamount,
        od.soldamount,
        row_number() over (partition by o.orderid order by o.orderid) as row_num
    from stg_orders o
    join stg_order_details od on o.orderid = od.orderid
) sub
where row_num = 1






