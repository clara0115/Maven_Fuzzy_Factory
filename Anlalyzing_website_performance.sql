USE mavenfuzzyfactory;

#IDENTIFYING TOP WEBSITE PAGES
SELECT
    pageview_url,
    COUNT(website_session_id) as sessions
FROM website_pageviews
WHERE created_at<'2012-06-09'
GROUP BY 1;

#IDENTIFYING TOP ENTRY PAGES
CREATE TEMPORARY TABLE first_pv
(SELECT
    website_session_id,
    MIN(website_pageview_id) as min_pv_id
FROM website_sessions
	LEFT JOIN website_pageviews using(website_session_id)
WHERE website_sessions.created_at<'2012-06-12'
GROUP BY 1);

SELECT
	pageview_url,
    COUNT(min_pv_id) as sessions_hitting_landing_page
FROM first_pv
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_pageview_id = first_pv.min_pv_id
GROUP BY 1
ORDER BY 2 DESC;

#CALCULATING BOUNCE RATES
CREATE TEMPORARY TABLE t1
(SELECT
	website_sessions.website_session_id,
	MIN(website_pageview_id) as first_pv_id,
	COUNT(website_pageview_id) as num_of_vw #count number of views for each session 
FROM website_sessions
	LEFT JOIN website_pageviews USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND' 2014-02-01' 
GROUP BY 1);

## Find the pageview url for each pv id
CREATE TEMPORARY TABLE t2
(SELECT
	t1.website_session_id,
    first_pv_id,
    num_of_vw,
    pageview_url as landing_page
FROM t1
	LEFT JOIN website_pageviews 
		 ON t1.first_pv_id = website_pageviews.website_pageview_id);

SELECT
	landing_page,
    COUNT(website_session_id) as sessions,
    COUNT(CASE WHEN num_of_vw = 1 THEN website_session_id ELSE NULL END) as bounced_sessions,
    COUNT(CASE WHEN num_of_vw = 1 THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS bounced_rate
FROM t2 
GROUP BY 1;

#ANALYZING LANDING PAGE TESTS
CREATE TEMPORARY TABLE t3
(SELECT
	website_sessions.website_session_id,
	MIN(website_pageview_id) as first_pv_id,
	COUNT(website_pageview_id) as num_of_vw 
FROM website_sessions
	LEFT JOIN website_pageviews USING(website_session_id)
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND' 2012-07-28' 
GROUP BY 1);

CREATE TEMPORARY TABLE t4
(SELECT
    t3.website_session_id,
    first_pv_id,
    num_of_vw,
    pageview_url as landing_page
FROM t3
	LEFT JOIN website_pageviews 
		 ON t3.first_pv_id = website_pageviews.website_pageview_id);

SELECT
    landing_page,
    COUNT(website_session_id) as total_sessions,
    COUNT(CASE WHEN num_of_vw = 1 THEN website_session_id ELSE NULL END) as bounced_sessions,
    COUNT(CASE WHEN num_of_vw = 1 THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS bounced_rate
FROM t2 
GROUP BY 1;
