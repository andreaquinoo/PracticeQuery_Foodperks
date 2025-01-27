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
    EXTRACT(WEEK FROM vendor_accepted_at_local) AS week,
    COUNT(global_entity_id) AS gross_orders,
    SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) AS valid_orders,
    CASE WHEN delivery_type = 'pickup' THEN 'Pickup Order' END AS pickup_orders,
    ROUND((1 - (SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) * 1.0 / COUNT(global_entity_id))) * 100, 2) AS vendor_fail_rate,
    SUM(gfv_local) AS gfv,
    SUM(CASE WHEN is_successful THEN gfv_local ELSE 0 END) AS gmv,
    ROUND(SUM(gfv_local) * 1.0 / COUNT(global_entity_id), 2) AS afv,
    ROUND(AVG(vendor_late_in_minutes), 2) AS avg_vendor_delay,
    ROUND((SUM(CASE WHEN vendor_late_in_minutes > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(global_entity_id)) * 100, 2) AS vendor_delay_percentage 
  FROM `fulfillment-dwh-production.pandata_datamart.pandora__agg_orders`
  WHERE global_entity_id = "FP_PH"
    AND DATE(created_date_local) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY vendor_name, Week, delivery_type
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
ORDER BY vendor_name