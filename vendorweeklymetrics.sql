/* 
Add PR to get below weekly metrics of vendors:
Gross Orders
Valid Orders
Pickup Orders
% Vendor Fail Rate
GFV
GMV
AFV
Avg Vendor Delay
% Vendor Delay 
*/


SELECT  
    vendor_name,
    --EXTRACT(ISOWEEK FROM created_at_utc) AS week,
    COUNT(DISTINCT IF (is_gross_order,order_uid,null)) AS gross_orders,
    COUNT(DISTINCT IF (is_successful, order_uid, null)) AS valid_orders,
    COUNT(DISTINCT IF (delivery_type = "pickup",order_uid, NULL)) AS pickup_orders,
    ROUND(SAFE_DIVIDE(
                      COUNT(DISTINCT IF(NOT is_successful, order_uid, NULL)), 
                      COUNT(DISTINCT IF(is_gross_order, order_uid, NULL))
                      ) * 100, 3) AS failed_vendor_rate,
    ROUND(SUM(IF (is_successful, gfv_local, 0)),2) AS gfv,
    ROUND(SUM(IF (is_successful, user_paid_gmv_local, 0)),2) AS gmv,
    ROUND(SAFE_DIVIDE(
                      SUM(IF(is_successful, gfv_local, 0)),
                      COUNT(DISTINCT IF(is_successful,order_uid, NULL))
                      ), 3) AS afv,
    ROUND(AVG(vendor_late_in_minutes), 2) AS avg_vendor_delay,
    ROUND(SAFE_DIVIDE(
                      COUNT(DISTINCT IF(vendor_late_in_minutes > 1, order_uid, NULL)),
                      COUNT(DISTINCT(order_uid)) * 60
                     ) * 100, 3) AS vendor_delay_percentage
  FROM `fulfillment-dwh-production.pandata_datamart.pandora__agg_orders`
  WHERE global_entity_id = "FP_PH"
    AND DATE(created_date_local) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 Month)
  GROUP BY ALL
ORDER BY vendor_name;