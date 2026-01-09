from __future__ import annotations

import sqlite3
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]

DB_PATH = ROOT / "data" / "db" / "analytics.db"
CUSTOMERS_CSV = ROOT / "data" / "raw" / "customers.csv"
PRODUCTS_CSV = ROOT / "data" / "raw" / "products.csv"
ORDERS_CSV = ROOT / "data" / "raw" / "orders.csv"

CREATE_SQL = ROOT / "sql" / "schema" / "01_create_tables.sql"
QUERIES_SQL = ROOT / "sql" / "queries" / "queries.sql"

def run_sql_file(conn: sqlite3.Connection, path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    conn.executescript(sql)

def load_csv_to_table(conn: sqlite3.Connection, csv_path: Path, table: str) -> int:
    df = pd.read_csv(csv_path)
    df.to_sql(table, conn, if_exists="append", index=False)
    return len(df)

def main(print_sample: bool = True) -> None:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("PRAGMA foreign_keys = ON;")

        # Create schema
        run_sql_file(conn, CREATE_SQL)

        # Load data
        n_c = load_csv_to_table(conn, CUSTOMERS_CSV, "customers")
        n_p = load_csv_to_table(conn, PRODUCTS_CSV, "products")
        n_o = load_csv_to_table(conn, ORDERS_CSV, "orders")

        print(f"✅ DB created: {DB_PATH}")
        print(f"✅ Loaded customers: {n_c}, products: {n_p}, orders: {n_o}")

        if print_sample:
            # Quick sanity checks
            df = pd.read_sql_query(
                """
                SELECT o.order_id, o.order_date, c.full_name, p.product_name, o.quantity,
                       ROUND(o.quantity * p.unit_price, 2) AS line_revenue
                FROM orders o
                JOIN customers c ON c.customer_id = o.customer_id
                JOIN products p ON p.product_id = o.product_id
                ORDER BY o.order_date, o.order_id
                LIMIT 10;
                """,
                conn,
            )
            print("\nSample joined output (first 10 rows):")
            print(df.to_string(index=False))

            # Optional: show a couple of query outputs from queries.sql (first 2 statements)
            all_queries = QUERIES_SQL.read_text(encoding="utf-8").split(";")
            runnable = [q.strip() for q in all_queries if q.strip().lower().startswith("select")]

            if runnable:
                print("\nExample query result (Q1):")
                q1 = runnable[0] + ";"
                print(pd.read_sql_query(q1, conn).to_string(index=False))

                if len(runnable) > 1:
                    print("\nExample query result (Q2):")
                    q2 = runnable[1] + ";"
                    print(pd.read_sql_query(q2, conn).to_string(index=False))

if __name__ == "__main__":
    main()
