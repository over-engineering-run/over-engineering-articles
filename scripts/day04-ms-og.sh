# !/bin/bash

OG_ARTICLES_ROOT="$(dirname $(cd $(dirname $0) >/dev/null 2>&1; pwd -P;))"
OG_ARTICLES_BIN="$OG_ARTICLES_ROOT/bin"
OG_ARTICLES_DATASETS="$OG_ARTICLES_ROOT/datasets"

MEILISEARCH_HOST="127.0.0.1"
MEILISEARCH_PORT="7700"
MEILISEARCH_DOCUMENTS_INDEX="movies"

MEILI_HTTP_ADDR="$MEILISEARCH_HOST:$MEILISEARCH_PORT"

# change working dir
cd $OG_ARTICLES_BIN

# download meilisearch binary
curl -L https://install.meilisearch.com | sh

# run meilisearch server in background
"$OG_ARTICLES_BIN/meilisearch" &

# wait for server up
status_code=$(
    curl --write-out %{http_code} \
         --silent \
         --output /dev/null \
         "$MEILI_HTTP_ADDR/indexes/$MEILISEARCH_DOCUMENTS_INDEX"
)
attempts=5
until [[ $attempts == 0 ]]; do
    [[ $status_code == 404 ]] && break;
    [[ $status_code == 200 ]] && break;
    [[ $attempts -gt 0 ]] && ((--attempts));
    [[ $attempts -gt 0 ]] && sleep 1;
done

# download test data
curl https://docs.meilisearch.com/movies.json \
     --output $OG_ARTICLES_DATASETS/movies.json

# build index
curl -X POST "http://$MEILI_HTTP_ADDR/indexes/movies/documents" \
     -H 'Content-Type: application/json' \
     --data-binary @"$OG_ARTICLES_DATASETS/movies.json"
