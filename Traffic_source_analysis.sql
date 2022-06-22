USE mavenfuzzyfactory;

#FINDING TOP TRAFFIC SOURCES
SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) as sessions
FROM website_sessions
WHERE created_at<'2012-04-12'
GROUP BY 1,2,3
ORDER BY 4 DESC;

#TRAFFIC CONVERSION RATES
SELECT
	sessions,
    orders,
    orders/sessions as conversion_rate
FROM
(SELECT
	COUNT(website_session_id) as sessions,
    COUNT(order_id) as orders
FROM website_sessions 
	LEFT JOIN orders USING(website_session_id)
WHERE utm_source='gsearch' 
	AND utm_campaign='nonbrand' 
    AND website_sessions.created_at<'2012-04-14') as t1;
    
#TRAFFIC SOURCE TRENDING
SELECT
	MIN(DATE(created_at)) as week_start_date,
    COUNT(website_session_id) as sessions
FROM website_sessions
WHERE utm_source='gsearch' 
	AND utm_campaign='nonbrand' 
    AND created_at<'2012-05-10'
GROUP BY 
	WEEK(created_at);
    
#CONVERSION RATES BY DEVICE TYPES
SELECT
	device_type,
    COUNT(website_session_id) as sessions,
    COUNT(order_id) as orders,
    COUNT(order_id)/COUNT(website_session_id) as conversion_rate
FROM website_sessions 
	LEFT JOIN orders USING(website_session_id)
WHERE utm_source='gsearch' 
	AND utm_campaign='nonbrand' 
    AND website_sessions.created_at<'2012-05-11'
GROUP BY 1;