USE mavenfuzzyfactory;

#PRODUCT SALES ANALYSIS
SELECT
	primary_product_id,
    COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) as margin,
    AVG(price_usd) AS average_order_value
FROM orders
GROUP BY 1
ORDER BY 4 DESC;

#PRODUCT LAUNCH SALES ANALYSIS
SELECT
	YEAR(website_sessioNs.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mon,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS rev_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;

#CROSS SELL ANALYSIS
SELECT
	primary_product_id,
    product_id AS cross_sold_product_id,
    COUNT(DISTINCT orders.order_id) AS orders
FROM orders
	LEFT JOIN order_items 
		ON orders.order_id = order_items.order_id
		AND is_primary_item = 0
GROUP BY 1,2
ORDER BY 3 DESC;

#CONVERSION FUNNEL FOR DIFFERENT PRODUCTS
CREATE TEMPORARY TABLE tbl2 
SELECT
	website_session_id, 
    MAX(fuzzy_page) as fuzzy_made_it, 
    MAX(bear_page) as bear_made_it, 
    MAX(cart_page) AS cart_made_it, 
    MAX(shipping_page) AS shipping_made_it, 
    MAX(billing_page) AS billing_made_it, 
    MAX(thankyou_page) AS thankyou_made_it 
FROM (
SELECT website_sessions.website_session_id,
	CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page, 
	CASE WHEN pageview_url='/the-forever-love-bear' THEN 1 ELSE 0 END AS bear_page, 
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page, 
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page, 
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page 
FROM website_sessions 
	LEFT JOIN website_pageviews USING (website_session_id) 
WHERE website_sessions.created_at BETWEEN '2013-01-06' and '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear','/cart','/shipping','/billing-2','/thank-you-for-your-order')) as table1 GROUP BY 1;
    
SELECT 
	CASE 
    WHEN fuzzy_made_it=1 THEN 'mrfuzzy' 
	WHEN bear_made_it=1 THEN 'lovebear' 
    ELSE NULL END AS product_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping, 
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou 
FROM tbl2
GROUP BY 1;

