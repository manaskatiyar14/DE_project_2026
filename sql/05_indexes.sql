-- R03: Accelerate case-insensitive substring searches on listing titles
CREATE EXTENSION IF NOT EXISTS pg_trgm;
 
CREATE INDEX IF NOT EXISTS idx_listings_title_trgm
ON olx.listings
USING GIN (title gin_trgm_ops);

-- R13: Speed up checks for boost packages that have never been purchased
CREATE INDEX IF NOT EXISTS idx_listings_boost_package
ON olx.listings (boost_package_id)
WHERE boost_package_id IS NOT NULL;

-- R22: Speed up newest-first listing pagination
CREATE INDEX IF NOT EXISTS idx_listings_posted_at_desc
ON olx.listings (posted_at DESC);

-- R06: Speed up retrieving the latest message in each chat thread
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_sent
ON olx.chat_messages (thread_id, sent_at DESC);