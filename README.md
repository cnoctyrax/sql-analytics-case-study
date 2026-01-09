# SQL Analytics Case Study (SQLite)

A small SQL portfolio project demonstrating practical analytics queries on a simple commerce dataset.

This project focuses on:
- data modeling (tables + keys)
- SQL joins and aggregations
- window functions
- reproducible setup (one command creates the DB)

## Dataset
CSV files stored in `data/raw/`:
- customers
- products
- orders (line items)

## What you can find here
- `sql/schema/01_create_tables.sql` — schema + indexes
- `sql/queries/queries.sql` — 15 analytics queries
- `src/run.py` — builds SQLite DB and loads CSV data

## How to run
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python src/run.py

## Outputs
- SQLite database is created at: `data/db/analytics.db`
- The database file is not committed (ignored) because it is generated at runtime

## Example questions answered
(see `sql/queries/queries.sql`)

- Total revenue and revenue by month
- Top customers and most sold products
- Revenue by category and country
- New vs returning customers by month
- Ranking and running totals using window functions

## Why this project
This project focuses on practical SQL analytics using realistic relational data and reproducible setup rather than dashboards or visualizations.