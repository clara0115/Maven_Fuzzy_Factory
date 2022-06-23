USE mavenfuzzyfactory;

#CHANNEL PORTFOLIO ANALYSIS
SELECT
	utm_content,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY 2 DESC;

#ANALYZING CHANNEL PORTFOLIOS
SELECT
	MIN(DATE(created_at)) as week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-11-29'
	AND utm_campaign='nonbrand'
GROUP BY WEEK(created_at);

#CROSS CHANNEL BID OPTIMIZATION
SELECT
	device_type,
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) as conv_rate
FROM website_sessions
	LEFT JOIN orders USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-19'
	AND utm_campaign='nonbrand'
GROUP BY 1,2;

#ANALYZING DIRECT TRAFFIC(NON-PAID TRAFFIC)
SELECT
	CASE 
		WHEN http_referer IS NULL AND is_repeat_session = 0 THEN 'new_direct'
		WHEN http_referer IS NULL AND is_repeat_session = 1 THEN 'repeat_direct'
		WHEN http_referer IN('https://www.gsearch.com','https://www.bsearch.com') AND is_repeat_session = 0 THEN 'new_organic'
		WHEN http_referer IN('https://www.gsearch.com','https://www.bsearch.com') AND is_repeat_session = 1 THEN 'repeat_organic'
	ELSE NULL END AS segment,
    COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE website_session_id BETWEEN '100000' AND '115000'
	AND utm_source IS NULL
GROUP BY 1;

#ANALYZING FREE CHANNELS vs. PAID CHANNEL
SELECT
	YEAR(created_at) as yr,
    MONTH(created_at) as mth,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' then website_session_id ELSE NULL END) as nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' then website_session_id ELSE NULL END) as brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct' then website_session_id ELSE NULL END) as direct,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic' then website_session_id ELSE NULL END) as organic
FROM
(SELECT
	website_session_id,
    created_at,
	CASE 
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct'
        WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic'
	ELSE NULL END AS channel_group
FROM website_sessions
WHERE website_sessions.created_at <'2012-12-23') AS t1
GROUP BY 1,2;
    
        