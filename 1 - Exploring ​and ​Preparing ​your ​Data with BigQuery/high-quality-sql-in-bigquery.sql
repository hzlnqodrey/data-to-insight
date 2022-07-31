# standardSQL - Revenue
SELECT
    FORMAT("%'d", totrevenue) AS revenue
FROM `project.dataset.table`
ORDER BY revenue DESC 
LIMIT 10 # make sure you limit your query, because otherwise it just waste of many byte amounts of processing

# standardSQL - Income
SELECT
    (totrevenue - totfuncexpns) AS income
FROM `project.dataset.table` # `bigquery-public-data.irs_990.irs_990_2015`
WHERE income > 0
ORDER BY income DESC
LIMIT 10

# standardSQL - Add new fields in SELECT clause to return more data.
SELECT
    totrevenue AS revenue
    ein, # employer identification number
    operationschools170cd AS is_school,
FROM `bigquery-public-data.irs_990.irs_990_2015`
ORDER BY totrevenue DESC
LIMIT 10