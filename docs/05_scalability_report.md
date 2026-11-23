
# Phase 5: Scalability Report

## 1. Overview

The purpose of Phase 5 was to evaluate the OLX marketplace database with approximately 20 times the original seed data.

Two PostgreSQL databases were used:

- `olx_marketplace`: Original seed dataset.
- `olx_large`: Approximately 20x dataset.

The large dataset was loaded, indexed, analyzed, and benchmarked using the optimized queries from `sql/06_optimized_queries.sql`.

## 2. Dataset Growth

The large dataset contains approximately:

| Table | Rows |
|---|---:|
| users | 1,000,000 |
| listings | 2,400,000 |
| chat_threads | 1,197,387 |
| chat_messages | 4,190,915 |
| favourites | 1,399,998 |
| offers | 399,105 |
| reports | 159,983 |
| seller_ratings | 226,984 |

The increase in rows significantly increases query execution time and storage requirements.

## 3. Benchmark Results

The optimized queries were executed three times on the large dataset. Average execution times were compared with the seed database results.

| Query | Seed Avg (ms) | Large Avg (ms) | Growth |
|---|---:|---:|---:|
| R06 | 32.945 | 289.102 | 8.8x |
| R13 | 0.055 | 0.745 | 13.5x |
| R19 | 46.298 | 1018.856 | 22.0x |

### Target Evaluation

| Query | Target | Large Avg | Result |
|---|---:|---:|---|
| R06 | < 5 ms | 289.102 ms | Not met |
| R13 | < 250 ms | 0.745 ms | Met |
| R19 | < 5000 ms | 1018.856 ms | Met |

Only the three queries present in `sql/06_optimized_queries.sql` were benchmarked on the large dataset. The remaining original workload queries were not executed on the large dataset, following the project instructions.

### Analysis

- R06 increased from 32.945 ms to 289.102 ms. Its plan includes sequential scans on listings and chat_threads.
- R13 remained very fast at 0.745 ms. The partial index-only scan on listings helped maintain performance.
- R19 increased from 46.298 ms to 1018.856 ms. Its execution plan uses an index-only scan on chat_messages, but processing the much larger dataset increases execution time.

R19's approximately 22x growth is broadly consistent with the increase in chat-message volume.

## 4. What Changed at Scale

The large dataset increased the amount of data PostgreSQL must process.

- Queries using selective indexes remained relatively fast.
- Queries involving large joins and aggregations became more expensive.
- Sequential scans on large tables became a performance concern.
- Indexes improved access to selected records, but they could not eliminate all scanning and aggregation costs.

The existing indexes were retained:

- `idx_listings_title_trgm`
- `idx_listings_boost_package`
- `idx_listings_posted_at_desc`
- `idx_chat_messages_thread_sent`

## 5. Storage Analysis

### Database Size

| Database | Size |
|---|---:|
| olx_marketplace | 107 MB |
| olx_large | 1934 MB |

The large database occupies approximately 18.1 times the storage of the seed database.

### Table and Index Storage

| Table | Seed Total | Large Total |
|---|---:|---:|
| listings | 48 MB | 908 MB |
| chat_messages | 28 MB | 544 MB |
| users | 8.7 MB | 179 MB |
| chat_threads | 6 MB | 121 MB |
| favourites | 4.5 MB | 89 MB |
| offers | 2 MB | 38 MB |
| seller_ratings | 1.4 MB | 27 MB |
| reports | 1.1 MB | 20 MB |

Listings and chat_messages are the largest tables and account for most of the database storage.

## 6. Partitioning Demonstration

A separate partitioned table named `olx.listings_partitioned` was created in `sql/08_partitioning.sql`.

The table uses RANGE partitioning on `posted_at`, with 18 monthly partitions covering January 2025 to June 2026.

### Partition Pruning

The following query was used:

```sql
EXPLAIN
SELECT listing_id, title, price, posted_at
FROM olx.listings_partitioned
WHERE posted_at >= '2026-03-01'
  AND posted_at < '2026-04-01';
```

The execution plan showed:

```text
Index Scan using listings_2026_03_pkey on listings_2026_03
```

PostgreSQL selected only the March 2026 partition, demonstrating partition pruning.

The partitioned table is a structural demonstration and was not populated with the original listings.

### Primary Key Consideration

PostgreSQL requires a primary key or unique constraint on a partitioned table to include all partition-key columns.

Since the partition key is `posted_at`, the demonstration uses:

```sql
PRIMARY KEY (listing_id, posted_at)
```

The original schema uses `listing_id` as its primary key. A production migration would therefore require changes to foreign keys referencing `listings(listing_id)`, as well as application logic that assumes listing_id is globally unique through the database constraint.

## 7. Architecture for 100x Scale

### Partitioning

- Partition listings by posting date to support date-based queries and archival.
- Consider partitioning chat_messages by sent_at for efficient historical data management.
- Monitor partition sizes and create new partitions before they are needed.

### Sharding

At 100x scale, horizontal sharding may be required.

- Listings can be distributed using a suitable listing or seller key.
- Chat data should be colocated by conversation or listing where possible.
- Cross-shard conversations and joins require additional application-level coordination.

### Read Replicas and Caching

- Use PostgreSQL read replicas for read-heavy workloads.
- Cache frequently accessed listings and category information.
- Use cache invalidation when listings are updated, sold, or removed.

### Maintenance

- Enable and monitor autovacuum.
- Run ANALYZE regularly to maintain query-planner statistics.
- Archive expired and old listings where appropriate.
- Use summary tables or materialized views for expensive analytical reports, with a suitable refresh strategy.

## 8. Conclusion

The large-data experiment showed that the database can handle approximately 20x the seed data, but query performance does not scale uniformly.

R13 remained very fast, while R06 and R19 experienced significant slowdowns. The storage analysis showed that listings and chat_messages dominate database size.

Indexes, partitioning, read replicas, caching, and regular database maintenance are important techniques for preparing the system for further growth.
