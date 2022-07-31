#standardSQL - Revenue
SELECT
    FORMAT("%'d", totrevenue) AS revenue
FROM `project.dataset.table`
ORDER BY revenue DESC 
LIMIT 10 # make sure you limit your query, because otherwise it just waste of many byte amounts of processing

#standardSQL - Income
SELECT
    (totrevenue - totfuncexpns) AS income
FROM `project.dataset.table` # `bigquery-public-data.irs_990.irs_990_2015`
WHERE income > 0
ORDER BY income DESC
LIMIT 10

#standardSQL - Add new fields in SELECT clause to return more data.
SELECT
    totrevenue AS revenue,
    ein, # employer identification number
    operationschools170cd AS is_school,
FROM `bigquery-public-data.irs_990.irs_990_2015`
ORDER BY totrevenue DESC
LIMIT 10


# Pitfall : Using SELECT * to return all columns
# AVOID using * (star) to return all columns
# -> Selecting only the columns you need greatly increases query speed and helps with readibility


#standardSQL - Filter Rows using the WHERE clause
SELECT
    totrevenue AS revenue,
    ein, # employer identification number
    operationschools170cd AS is_school,
FROM `bigquery-public-data.irs_990.irs_990_2015`
WHERE operationschools170cd = 'Y'
ORDER BY totrevenue DESC
LIMIT 10
# why didn't we write this as is_school = 'Y'?
# -> because the AS (Alias) is_school is not known by the filter, because SQL programming read the FROM and then the FILTER Section (WHERE, GROUP BY, ORDER BY, LIMIT), but WHERE is the exception, he cannot be placed by ALIAS or AS
