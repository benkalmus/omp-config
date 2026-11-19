# Hindsight memory for omp

omp talks to a Hindsight server on `http://localhost:8888`.

## Start

```sh
cp .env.example .env       # fill in HINDSIGHT_API_LLM_API_KEY
docker compose --env-file .env up -d
curl -fsS http://localhost:8888/health
```

The first pull is about 9 GB (embeddings and reranker run in the image). The
container uses embedded PostgreSQL (`pg0`) in the named volume, so memory
survives restarts without a separate database.

## Wire into omp

Only after the health check returns 200:

```sh
omp config set memory.backend hindsight
omp config set hindsight.apiUrl http://localhost:8888
```

omp then recalls on the first model turn and retains every three user turns.
`/memory stats` and `/memory view` inspect it. Bank and project scoping is
per-repository by default.
