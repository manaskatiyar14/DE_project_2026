# 04 — Query Optimization Report

## 1. Introduction

This report describes the query optimization techniques applied to the OLX Used Goods Marketplace database. The objective was to improve query execution performance using appropriate indexes and query rewriting.

The original query workload was benchmarked before optimization. Selected queries were then optimized and benchmarked again using `EXPLAIN (ANALYZE, BUFFERS)` with three execution runs.

## 2. Indexes Created

The following indexes were created:

| Query | Index Name | Optimization |
|---|---|---|
| R03 | `idx_listings_title_trgm` | GIN trigram index for case-insensitive substring searches on listing titles |
| R06 | `idx_chat_messages_thread_sent` | Composite index for retrieving the latest message in a chat thread |
| R13 | `idx_listings_boost_package` | Partial index for non-NULL boost package references |
| R22 | `idx_listings_posted_at_desc` | Index for newest-first listing pagination |

The `pg_trgm` extension was enabled to support the trigram index used by R03.

## 3. Query Rewriting

### R13 — Unused Boost Packages

The original query used `NOT IN` to find boost packages that had never been purchased. Since `listings.boost_package_id` contains NULL values, the original query returned zero rows.

The query was rewritten using `NOT EXISTS`, which correctly identifies packages without matching listings.

### R19 — City Chat Report

The original query used correlated subqueries to calculate the chat count and latest chat time separately for every listing.

It was rewritten using Common Table Expressions (CTEs). The latest message per thread is calculated first, followed by chat statistics grouped by listing. These results are then joined with the active listings.

This avoids repeatedly scanning the chat tables for individual listings.

## 4. Benchmark Results

All benchmark averages are based on three execution runs.

| Query | Baseline Average (ms) | Optimized Average (ms) | Improvement |
|---|---:|---:|---:|
| R03 | 27.944 | 10.485 | 62.5% |
| R06 | 62.226 | 32.945 | 47.1% |
| R13 | 13.950 | 0.055 | 99.6%* |
| R19 | 1117.115 | 46.298 | 95.9% |
| R22 | 30.076 | 21.112 | 29.8% |

*R13's comparison is not strictly equivalent because the original `NOT IN` query returned zero rows due to NULL values, while the corrected `NOT EXISTS` query returns two unused packages. The percentage represents the timing difference, not a like-for-like comparison.

## 5. Execution Plan Observations

- **R03:** PostgreSQL used the trigram GIN index through a Bitmap Index Scan instead of scanning the entire listings table.
- **R06:** PostgreSQL used `idx_chat_messages_thread_sent` through an Index Scan to retrieve the latest message for each matching thread.
- **R13:** PostgreSQL used `idx_listings_boost_package` through an Index Only Scan.
- **R19:** The rewritten query used hash joins and hash aggregation to calculate chat statistics in grouped operations.
- **R22:** PostgreSQL used the descending `posted_at` index, eliminating the expensive sorting operation required by the baseline plan.

## 6. Conclusion

The optimization process improved the execution time of all five selected queries. Indexing reduced unnecessary table scans and sorting operations, while query rewriting reduced repeated calculations.

R19 showed a substantial reduction in execution time through CTE-based aggregation. R06 benefited from the composite index on chat messages, and R03 benefited from trigram indexing. R13 was corrected to handle NULL values properly, while R22 benefited from an index supporting descending date order.

The optimized query plans and benchmark results are stored in the project repository for verification.