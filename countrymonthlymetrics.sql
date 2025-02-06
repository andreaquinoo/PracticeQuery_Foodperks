/*
Add PR for query to get monthly metrics for PH and for each lg_zone
Valid Orders-
Completed Deliveries-
Fail Rate-
Average Food Value (AFV)-
Count of Vendors (with or without orders)
Avg Delivery Time
Restaurant Orders
Shops Orders
Dmart Orders
Pandago B2C Orders
Pandago C2C Orders


Tables to use:
`fulfillment-dwh-production.pandata_datamart.pandora__agg_orders`
`fulfillment-dwh-production.pandata_report.regional_apac_pd_vendors_agg_business_types`

*/

SELECT
  FORMAT_DATE('%B-%Y',DATE_TRUNC(orders.created_date_local, MONTH)) AS month_local,
  DATE_TRUNC(orders.created_date_local, MONTH) AS no_format_month,
  orders.city_name,
  COUNT(DISTINCT IF(orders.is_successful, orders.order_uid,null)) AS valid_orders,
  COUNT(DISTINCT IF(orders.delivery_status = "completed", orders.order_uid, NULL)) AS completed_deliveries,
  ROUND(SAFE_DIVIDE(COUNT(DISTINCT IF(orders.is_failed_order, orders.order_uid, NULL)), 
                    COUNT(DISTINCT IF(orders.is_gross_order, orders.order_uid, NULL)
                    )),2 ) AS fail_rate,
  ROUND(SAFE_DIVIDE(SUM(IF(orders.is_successful, orders.gfv_local, 0)),
                    COUNT(DISTINCT IF(orders.is_successful, orders.order_uid, NULL)
                    )),2) AS afv,
  COUNT(DISTINCT IF(business_type.is_kitchen_concept_vendor_active, orders.vendor_code, null)) AS count_of_vendors,
  ROUND(AVG(COALESCE(orders.actual_delivery_time_in_minutes)),2) AS avg_delivery_time_in_minutes,
  COUNT(DISTINCT IF(business_type.business_type_apac IN ("restaurants"), orders.order_uid, NULL)) AS restaurant_orders,
  COUNT(DISTINCT IF(business_type.business_type_apac IN ("shops"), orders.order_uid, NULL)) AS shops_orders,
  COUNT(DISTINCT IF(business_type.business_type_apac IN ("dmart"), orders.order_uid, NULL)) AS dmart_orders,
  COUNT(DISTINCT IF(business_type.business_type_apac IN ("pandago"), orders.order_uid, NULL)) AS pandago_orders
  FROM `fulfillment-dwh-production.pandata_datamart.pandora__agg_orders` AS orders
  LEFT JOIN `fulfillment-dwh-production.pandata_report.regional_apac_pd_vendors_agg_business_types` AS business_type
  ON orders.global_entity_id = business_type.global_entity_id
    AND orders.vendor_code = business_type.vendor_code
  WHERE orders.global_entity_id = "FP_PH"
    AND DATE(orders.created_date_local) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
  GROUP BY ALL
  ORDER BY month_local DESC