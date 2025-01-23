/* Create a query to get your own successful orders in the past 12 months with the following details:
order date
delivery date
order code
vendor name
order status
payment method
food value (GFV)
discount value
discount title
voucher value
voucher code used */

SELECT
  created_date_local AS OrderDate,
  rider_dropped_off_at_local AS delivery_date,
  order_code AS order_code,
  vendor_name AS vendor_name,
  order_status AS order_status,
  payment_method AS payment_method,
  gfv_local AS food_value,
  discount_value_local AS discount_value,
  discount_title AS discount_title,
   voucher_value_local AS voucher_value,
  voucher_code AS voucher_code_used
FROM `fulfillment-dwh-production.pandata_datamart.pandora__agg_orders`
WHERE customer_code = 'pkt5e9pb'
  AND is_successful
  AND DATE(created_date_local) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
ORDER BY 
  created_date_local DESC;