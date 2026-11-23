SET search_path TO olx;

BEGIN;

\copy cities FROM 'large_data/cities.csv' WITH (FORMAT csv, HEADER true);

\copy categories FROM 'large_data/categories.csv' WITH (FORMAT csv, HEADER true);

\copy boost_packages FROM 'large_data/boost_packages.csv' WITH (FORMAT csv, HEADER true);

\copy users FROM 'large_data/users.csv' WITH (FORMAT csv, HEADER true);

\copy listings FROM 'large_data/listings.csv' WITH (FORMAT csv, HEADER true);

\copy chat_threads FROM 'large_data/chat_threads.csv' WITH (FORMAT csv, HEADER true);

\copy chat_messages FROM 'large_data/chat_messages.csv' WITH (FORMAT csv, HEADER true);

\copy offers FROM 'large_data/offers.csv' WITH (FORMAT csv, HEADER true);

\copy favourites FROM 'large_data/favourites.csv' WITH (FORMAT csv, HEADER true);

\copy reports FROM 'large_data/reports.csv' WITH (FORMAT csv, HEADER true);

\copy seller_ratings FROM 'large_data/seller_ratings.csv' WITH (FORMAT csv, HEADER true);

ANALYZE;

COMMIT;