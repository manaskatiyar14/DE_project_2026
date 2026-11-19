-- @R19
-- Optimized: Calculate chat statistics once, then join them to listings

WITH message_latest AS (
    SELECT thread_id, MAX(sent_at) AS last_chat_at
    FROM olx.chat_messages
    GROUP BY thread_id
),
chat_stats AS (
    SELECT
        t.listing_id,
        COUNT(*) AS chats,
        MAX(ml.last_chat_at) AS last_chat_at
    FROM olx.chat_threads t
    LEFT JOIN message_latest ml
        ON ml.thread_id = t.thread_id
    GROUP BY t.listing_id
)
SELECT
    l.listing_id,
    l.title,
    COALESCE(cs.chats, 0) AS chats,
    cs.last_chat_at
FROM olx.listings l
LEFT JOIN chat_stats cs
    ON cs.listing_id = l.listing_id
WHERE l.category_id = 2
  AND l.city_id = 1
  AND l.status = 'ACTIVE'
ORDER BY chats DESC;

-- @R13
-- Optimized: Find boost packages that have never been purchased

SELECT b.package_id, b.package_name, b.price
FROM olx.boost_packages b
WHERE NOT EXISTS (
    SELECT 1
    FROM olx.listings l
    WHERE l.boost_package_id = b.package_id
);

-- @R06
-- Optimized: Retrieve the latest message from each chat thread efficiently

SELECT t.thread_id, l.title, last_msg.body, last_msg.sent_at
FROM olx.chat_threads t
JOIN olx.listings l ON l.listing_id = t.listing_id
CROSS JOIN LATERAL (
    SELECT m.body, m.sent_at
    FROM olx.chat_messages m
    WHERE m.thread_id = t.thread_id
    ORDER BY m.sent_at DESC
    LIMIT 1
) last_msg
WHERE t.buyer_id = 1042 OR l.seller_id = 1042
ORDER BY last_msg.sent_at DESC;