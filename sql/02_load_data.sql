SET search_path TO olx;

BEGIN;

\copy cities FROM 'seed_data/cities.csv' WITH (FORMAT csv, HEADER true);

\copy categories FROM 'seed_data/categories.csv' WITH (FORMAT csv, HEADER true);

\copy boost_packages FROM 'seed_data/boost_packages.csv' WITH (FORMAT csv, HEADER true);

\copy users FROM 'seed_data/users.csv' WITH (FORMAT csv, HEADER true);

\copy listings FROM 'seed_data/listings.csv' WITH (FORMAT csv, HEADER true);

\copy chat_threads FROM 'seed_data/chat_threads.csv' WITH (FORMAT csv, HEADER true);

\copy chat_messages FROM 'seed_data/chat_messages.csv' WITH (FORMAT csv, HEADER true);

\copy offers FROM 'seed_data/offers.csv' WITH (FORMAT csv, HEADER true);

\copy favourites FROM 'seed_data/favourites.csv' WITH (FORMAT csv, HEADER true);

\copy reports FROM 'seed_data/reports.csv' WITH (FORMAT csv, HEADER true);

\copy seller_ratings FROM 'seed_data/seller_ratings.csv' WITH (FORMAT csv, HEADER true);

ANALYZE;

COMMIT;