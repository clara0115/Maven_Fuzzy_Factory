USE mavenfuzzyfactory;

#BUILDING CONVERSION FUNNELS
SELECT
	COUNT(DISTINCT website_session_id) as sessions,
    COUNT(DISTINCT CASE WHEN pageview_url='/products' THEN website_session_id ELSE NULL END) AS to_product,
    COUNT(DISTINCT CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pageview_url='/cart' THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN pageview_url='/shipping' THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN pageview_url='/billing' THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN pageview_url='/thank-you-for-your-order' THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
(SELECT
	website_session_id,
    pageview_url,
    website_pageview_id
FROM website_sessions
	LEFT JOIN website_pageviews USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
    AND utm_source='gsearch'
    AND utm_campaign='nonbrand') AS t1;

#ANALYZING CONVERSION FUNNEL TESTS
SELECT
	billing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
FROM
(SELECT
	website_session_id,
    order_id,
    pageview_url as billing_page
FROM website_sessions
	LEFT JOIN orders USING(website_session_id)
    LEFT JOIN website_pageviews USING(website_session_id)
WHERE website_pageview_id>'53550'
	AND website_sessions.created_at < '2012-11-10' 
    AND pageview_url IN ('/billing','/billing-2')) AS t2
GROUP BY 1;



