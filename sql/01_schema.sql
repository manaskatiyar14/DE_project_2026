CREATE SCHEMA IF NOT EXISTS olx;
SET search_path TO olx;
CREATE TABLE cities (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(category_id)
);
CREATE TABLE boost_packages (
    package_id INTEGER PRIMARY KEY,
    package_name VARCHAR(100) NOT NULL UNIQUE,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    city_id INTEGER REFERENCES cities(city_id),
    phone_verified BOOLEAN NOT NULL,
    is_banned BOOLEAN NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE listings (
    listing_id INTEGER PRIMARY KEY,
    seller_id INTEGER NOT NULL REFERENCES users(user_id),
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price > 0),
    is_negotiable BOOLEAN NOT NULL,
    item_condition VARCHAR(20) NOT NULL,
    attributes JSONB NOT NULL,
    city_id INTEGER NOT NULL REFERENCES cities(city_id),
    locality VARCHAR(150),
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    image_count INTEGER NOT NULL CHECK (image_count >= 0),
    view_count INTEGER NOT NULL CHECK (view_count >= 0),
    boost_package_id INTEGER REFERENCES boost_packages(package_id),
    status VARCHAR(20) NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    sold_at TIMESTAMPTZ,

    UNIQUE (listing_id, seller_id),

    CHECK (item_condition IN ('FAIR', 'GOOD', 'LIKE_NEW', 'NEW')),
    CHECK (status IN ('ACTIVE', 'EXPIRED', 'REMOVED', 'SOLD')),
    CHECK (jsonb_typeof(attributes) = 'object'),
    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    CHECK (expires_at > posted_at),
    CHECK (sold_at IS NULL OR sold_at >= posted_at),
    CHECK (
        (status = 'SOLD' AND sold_at IS NOT NULL)
        OR (status <> 'SOLD' AND sold_at IS NULL)
    )
);

CREATE TABLE chat_threads (
    thread_id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL REFERENCES listings(listing_id),
    buyer_id INTEGER NOT NULL REFERENCES users(user_id),
    created_at TIMESTAMPTZ NOT NULL,

    UNIQUE (listing_id, buyer_id)
);

CREATE TABLE chat_messages (
    message_id INTEGER PRIMARY KEY,
    thread_id INTEGER NOT NULL REFERENCES chat_threads(thread_id),
    sender_id INTEGER NOT NULL REFERENCES users(user_id),
    body TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL,
    is_read BOOLEAN NOT NULL
);

CREATE TABLE offers (
    offer_id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL REFERENCES listings(listing_id),
    buyer_id INTEGER NOT NULL REFERENCES users(user_id),
    offer_price NUMERIC(12,2) NOT NULL CHECK (offer_price > 0),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    responded_at TIMESTAMPTZ,

    CHECK (status IN ('ACCEPTED', 'COUNTERED', 'PENDING', 'REJECTED')),
    CHECK (
        (status = 'PENDING' AND responded_at IS NULL)
        OR (status <> 'PENDING' AND responded_at IS NOT NULL)
    )
);

CREATE TABLE favourites (
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    listing_id INTEGER NOT NULL REFERENCES listings(listing_id),
    saved_at TIMESTAMPTZ NOT NULL,

    PRIMARY KEY (user_id, listing_id)
);

CREATE TABLE reports (
    report_id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL REFERENCES listings(listing_id),
    reporter_id INTEGER NOT NULL REFERENCES users(user_id),
    reason VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL,

    UNIQUE (listing_id, reporter_id),
    CHECK (reason IN ('ALREADY_SOLD', 'FRAUD', 'OFFENSIVE', 'SPAM', 'WRONG_CATEGORY')),
    CHECK (status IN ('ACTIONED', 'DISMISSED', 'OPEN'))
);

CREATE TABLE seller_ratings (
    rating_id INTEGER PRIMARY KEY,
    seller_id INTEGER NOT NULL,
    rater_id INTEGER NOT NULL REFERENCES users(user_id),
    listing_id INTEGER NOT NULL,
    stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL,

    FOREIGN KEY (listing_id, seller_id)
        REFERENCES listings(listing_id, seller_id),

    UNIQUE (listing_id, rater_id),
    CHECK (seller_id <> rater_id)
);