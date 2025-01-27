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


WITH vendor_weekly_metrics AS (
  SELECT  
    vendor_name,
    EXTRACT(week FROM created_at_utc) AS week,
    COUNT(DISTINCT(IF (is_gross_order,order_uid,null))) AS gross_orders,
    COUNT(DISTINCT(IF (is_successful, order_uid, null))) AS valid_orders,
    COUNT(DISTINCT CASE WHEN delivery_type = 'pickup' THEN order_uid ELSE NULL END) AS pickup_orders,
    ROUND((1 - (SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) * 1.0 / COUNT(order_uid))) * 100, 2) AS vendor_fail_rate,
    ROUND(SUM(IF (is_successful, gfv_local, 0)),2) AS gfv,
    ROUND(SUM(IF (is_successful, user_paid_gmv_local, 0)),2) AS gmv,
    ROUND(SAFE_DIVIDE(
                      SUM(IF(is_successful, gfv_local, 0)),
                      COUNT(DISTINCT(IF(is_successful,order_uid, NULL)))
                      ), 3) AS afv,
    ROUND(AVG(vendor_late_in_minutes), 2) AS avg_vendor_delay,
    ROUND((SUM(CASE WHEN vendor_late_in_minutes > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(order_uid)) * 100, 2) AS vendor_delay_percentage 
  FROM `fulfillment-dwh-production.pandata_datamart.pandora__agg_orders`
  WHERE global_entity_id = "FP_PH"
    AND DATE(created_date_local) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
  GROUP BY vendor_name, delivery_type, week
)
SELECT 
  vendor_name,
  week,
  gross_orders, 
  valid_orders, 
  pickup_orders, 
  vendor_fail_rate, 
  gfv, 
  gmv, 
  afv, 
  avg_vendor_delay, 
  vendor_delay_percentage
FROM vendor_weekly_metrics
ORDER BY vendor_name;