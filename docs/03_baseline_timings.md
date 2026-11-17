# Phase 3: Baseline Query Performance Analysis

## 1. Objective

The objective of Phase 3 is to measure the execution performance of the 30 SQL queries defined in `queries/workload_30.sql`.

Each query was executed three times using `EXPLAIN (ANALYZE, BUFFERS)`. The average execution time was calculated from the three runs.

The original workload file was not modified. All benchmark queries were executed safely inside a transaction using `BEGIN` and `ROLLBACK`.

## 2. Baseline Timing Results

All execution times are recorded in milliseconds (ms).

| SQL Query | Type | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) |
|---|---|---:|---:|---:|---:|
| R01 – Browse active cars in Bengaluru | READ | 11.004 | 9.222 | 8.124 | 9.450 |
| R02 – Filter diesel cars in Pune | READ | 7.118 | 6.627 | 6.353 | 6.699 |
| R03 – Search active iPhone 13 ads | READ | 30.941 | 26.122 | 26.769 | 27.944 |
| R04 – Listing page with seller and rating | READ | 0.394 | 0.352 | 0.351 | 0.366 |
| R05 – User's ads grouped by status | READ | 1.189 | 1.183 | 1.179 | 1.184 |
| R06 – Chat inbox with latest message | READ | 61.743 | 63.079 | 61.856 | 62.226 |
| R07 – Count unread messages | READ | 5.415 | 5.418 | 5.154 | 5.329 |
| R08 – Median iPhone 13 price by condition | READ | 5.567 | 5.484 | 5.376 | 5.476 |
| R09 – Nearby active furniture search | READ | 6.037 | 6.360 | 5.960 | 6.119 |
| R10 – Ads expiring in the first three days of July | READ | 5.208 | 5.190 | 5.147 | 5.182 |
| R11 – Moderation queue with open reports | READ | 2.000 | 1.915 | 1.885 | 1.933 |
| R12 – Detect users posting multiple ads per day | READ | 33.178 | 33.118 | 33.390 | 33.229 |
| R13 – Unused boost packages | READ | 14.250 | 13.870 | 13.730 | 13.950 |
| R14 – Average days to sell by category | READ | 8.725 | 8.688 | 8.818 | 8.744 |
| R15 – Accepted offers by category | READ | 10.921 | 11.006 | 10.849 | 10.925 |
| R16 – Trending ads based on favourites | READ | 11.801 | 11.390 | 11.311 | 11.501 |
| R17 – Average views of boosted vs normal ads | READ | 11.238 | 11.038 | 11.046 | 11.107 |
| R18 – Duplicate ads by seller, title and price | READ | 35.014 | 35.047 | 34.109 | 34.723 |
| R19 – Chats and latest chat time per active car ad | READ | 1136.810 | 1110.628 | 1103.906 | 1117.115 |
| R20 – Daily new ads and running total | READ | 7.075 | 6.773 | 6.604 | 6.817 |
| R21 – Best-rated sellers | READ | 8.446 | 7.933 | 7.751 | 8.043 |
| R22 – Moderation console, page 2001 | READ | 29.748 | 30.173 | 30.306 | 30.076 |
| R23 – Login using mobile number | READ | 0.031 | 0.033 | 0.028 | 0.031 |
| R24 – Active ads per top-level category | READ | 11.713 | 11.169 | 10.790 | 11.224 |
| R25 – Seller response time by category | READ | 56.376 | 56.380 | 59.306 | 57.354 |
| W01 – Post a new advertisement | WRITE | 2.472 | 0.599 | 0.612 | 1.228 |
| W02 – Mark oldest active ad as sold | WRITE | 2.058 | 1.460 | 1.419 | 1.646 |
| W03 – Insert a chat message | WRITE | 2.054 | 0.533 | 0.524 | 1.037 |
| W04 – Expire all ads past expiry date | WRITE | 325.157 | 18.538 | 18.763 | 120.819 |
| W05 – Accept highest offer and reject others | WRITE | 2.718 | 1.374 | 1.378 | 1.823 |

## 3. Scan Types and Performance Analysis

### Read Queries (R01–R25)

| Query | Scan Type | Performance Analysis |
|---|---|---|
| R01 | Sequential Scan on listings | Scans listings to filter by category, city, status and price, then sorts matching rows by posting date. |
| R02 | Sequential Scan on listings | Checks multiple filters, including JSON attributes, which require examining listing records. |
| R03 | Sequential Scan on listings | The leading-wildcard `ILIKE` search makes ordinary B-tree indexing unsuitable for this title search. |
| R04 | Index Scan on listings and users; Sequential Scan on seller_ratings | Primary-key lookups quickly locate the listing and seller; the ratings scan adds some work. |
| R05 | Index Scan on listings | The seller lookup uses an index, making retrieval efficient. |
| R06 | Sequential Scans on listings, chat_threads and chat_messages | Multiple table scans and the lateral latest-message lookup increase execution time. |
| R07 | Sequential Scan on chat_messages; Index Scan on chat_threads; Index Only Scan on listings | Message filtering and joins require scanning messages, while indexed lookups help with related records. |
| R08 | Sequential Scan on listings | Filters records using category, JSON attributes and posting date before calculating the median. |
| R09 | Sequential Scan on listings | Applies geographic range filters and calculates distances for matching furniture listings. |
| R10 | Sequential Scan on listings | Checks active status and expiry dates across listing records. |
| R11 | Sequential Scan on reports; Index Scan on listings | Groups open reports and joins the matching listings. |
| R12 | Sequential Scan on listings | Groups all listings by seller and posting date to detect repeated posting activity. |
| R13 | Sequential Scans on boost_packages and listings | Checks package usage through a subquery, requiring scans of both tables. |
| R14 | Sequential Scans on listings and categories | Filters sold listings, joins categories and calculates average selling time. |
| R15 | Sequential Scans on listings, offers and categories | Joins three tables and calculates accepted-offer percentages by category. |
| R16 | Sequential Scans on listings and favourites | Filters recent favourites, joins active listings and groups the results. |
| R17 | Sequential Scans on listings and categories | Groups listings by category and boost status and calculates average views. |
| R18 | Sequential Scan on listings | Groups listing records by seller, title and price to identify duplicates. |
| R19 | Sequential Scans on listings and chat_messages; Index Only Scan and Index Scan on chat_threads | Repeated correlated subqueries calculate chat counts and latest message times for listings, resulting in high execution time. |
| R20 | Sequential Scan on listings | Filters listings by posting date, groups them by day and calculates a running total. |
| R21 | Sequential Scans on seller_ratings and users | Aggregates seller ratings and joins user information before sorting the results. |
| R22 | Sequential Scan on listings | The large OFFSET of 50,000 requires processing and skipping many rows before returning the requested page. |
| R23 | Index Scan on users | The unique phone-number index allows very fast lookup of a user. |
| R24 | Sequential Scans on listings and categories | Joins category records and groups active listings into top-level categories. |
| R25 | Sequential Scans on chat_messages, chat_threads, listings and categories | Joins multiple tables and aggregates message timestamps to calculate seller response times. |

### Write Queries (W01–W05)

| Query | Scan Type | Performance Analysis |
|---|---|---|
| W01 | No scan | Inserts a new listing row. The first run includes additional overhead compared with subsequent runs. |
| W02 | Index Scan on listings | Uses an indexed lookup to identify the listing to update. |
| W03 | Index Scan on chat_threads | Uses the primary-key index to locate the relevant conversation for the message insertion. |
| W04 | Sequential Scan on listings | Checks active listings against their expiry dates and updates every matching record. |
| W05 | Sequential Scan on offers | Finds pending offers for the listing and updates their statuses. |

## 4. Performance Observations

1. R23 is the fastest query, with an average execution time of 0.031 ms, because it uses the unique index on the phone column.

2. R04 is also very fast, with an average execution time of 0.366 ms, because indexed lookups retrieve the listing and seller efficiently.

3. R19 is the slowest read query, with an average execution time of 1117.115 ms. Its correlated subqueries repeatedly retrieve chat counts and latest message timestamps.

4. R06 has an average execution time of 62.226 ms because it combines chat threads, listings and latest-message retrieval.

5. R25 takes an average of 57.354 ms because it joins multiple tables and performs grouping and timestamp aggregation.

6. W04 is the slowest write query, with an average execution time of 120.819 ms, because it updates all active listings whose expiry dates have passed.

7. Most read queries use sequential scans, indicating opportunities to improve performance through suitable indexing and query optimization.

## 5. Conclusion

Phase 3 successfully measured all 30 SQL queries, including 25 read queries and 5 write queries. Each query was executed three times, and the average execution time was recorded.

The benchmark results identify queries with high execution times and show where sequential scans, joins, grouping operations and correlated subqueries affect performance.

These baseline results will be used in Phase 4 to optimize the queries and compare their performance against the original measurements.

## 6. Benchmark Files

The following files contain the benchmark results:

- `benchmarks/results/baseline/summary.csv` – Average, median, minimum, maximum execution times and scan types.
- `benchmarks/results/baseline/R01.txt` to `R25.txt` – Raw execution plans for read queries.
- `benchmarks/results/baseline/W01.txt` to `W05.txt` – Raw execution plans for write queries.
- `benchmarks/run_benchmark.sh` – Script used to execute the benchmark workload.
