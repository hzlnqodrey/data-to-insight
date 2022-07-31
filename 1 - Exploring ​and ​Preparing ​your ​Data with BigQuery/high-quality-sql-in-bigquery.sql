# standardSQL
SELECT
    FORMAT("%'d", total_revenue) AS total_revenue
FROM `project.dataset.table`
ORDER BY total_revenue DESC 
LIMIT 10 # make sure you limit your query, because otherwise it just waste of many byte amounts of processing