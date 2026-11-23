
-- Phase 5: Partitioning demonstration
-- Separate table: original olx.listings remains unchanged.

CREATE TABLE olx.listings_partitioned (
    listing_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (listing_id, posted_at)
) PARTITION BY RANGE (posted_at);

-- Monthly partitions for the dataset date range.

CREATE TABLE olx.listings_2025_01
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE olx.listings_2025_02
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE olx.listings_2025_03
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE olx.listings_2025_04
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

CREATE TABLE olx.listings_2025_05
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE olx.listings_2025_06
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE olx.listings_2025_07
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE olx.listings_2025_08
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE olx.listings_2025_09
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE olx.listings_2025_10
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE olx.listings_2025_11
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE olx.listings_2025_12
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

CREATE TABLE olx.listings_2026_01
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE olx.listings_2026_02
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE olx.listings_2026_03
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE olx.listings_2026_04
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

CREATE TABLE olx.listings_2026_05
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE TABLE olx.listings_2026_06
PARTITION OF olx.listings_partitioned
FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

-- Demonstrate partition pruning.
EXPLAIN
SELECT listing_id, title, price, posted_at
FROM olx.listings_partitioned
WHERE posted_at >= '2026-03-01'
  AND posted_at < '2026-04-01';
