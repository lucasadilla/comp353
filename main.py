import os
import getpass
import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector

# ---------- DATABASE SETUP ----------
DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "ixc353.encs.concordia.ca"),
    "port": int(os.getenv("MYSQL_PORT", "3306")),
    "user": os.getenv("MYSQL_USER", "ixc353_4"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "ixc353_4"),
}


def split_sql_statements(sql_script):
    statements = []
    current = []
    in_single_quote = False
    in_double_quote = False

    for ch in sql_script:
        if ch == "'" and not in_double_quote:
            in_single_quote = not in_single_quote
        elif ch == '"' and not in_single_quote:
            in_double_quote = not in_double_quote

        if ch == ";" and not in_single_quote and not in_double_quote:
            statement = "".join(current).strip()
            if statement:
                statements.append(statement)
            current = []
        else:
            current.append(ch)

    trailing = "".join(current).strip()
    if trailing:
        statements.append(trailing)

    return statements


def load_sql_file(cursor, filename):
    with open(filename, 'r') as f:
        sql_script = f.read()

    for statement in split_sql_statements(sql_script):
        upper_stmt = statement.strip().upper()
        # Ignore MySQL server-level DB statements; we use the assigned DB account directly.
        if upper_stmt.startswith("DROP DATABASE"):
            continue
        if upper_stmt.startswith("CREATE DATABASE"):
            continue
        if upper_stmt.startswith("USE "):
            continue
        cursor.execute(statement)


def setup_database():
    if not DB_CONFIG["password"]:
        DB_CONFIG["password"] = getpass.getpass("MySQL password: ")

    conn = mysql.connector.connect(
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        database=DB_CONFIG["database"],
    )
    cursor = conn.cursor()
    if os.getenv("MYSQL_INIT_DB", "1") == "1":
        load_sql_file(cursor, "schema.sql")
        load_sql_file(cursor, "data.sql")
    conn.commit()
    return conn


# ---------- GUI ----------
class DatabaseGUI:
    def __init__(self, root, conn):
        self.root = root
        self.conn = conn
        self.cursor = conn.cursor()

        self.root.title("Rentruck Database Viewer")
        self.root.geometry("900x600")

        # --- TABLE SELECTOR ---
        self.table_var = tk.StringVar()
        self.table_dropdown = ttk.Combobox(root, textvariable=self.table_var)
        self.table_dropdown.pack(pady=5)

        self.load_button = tk.Button(root, text="Load Table", command=self.load_table)
        self.load_button.pack(pady=5)

        # --- QUERY INPUT ---
        tk.Label(root, text="Enter SQL Query:").pack()

        self.query_text = tk.Text(root, height=4)
        self.query_text.pack(fill="x", padx=10)

        self.run_button = tk.Button(root, text="Run Query", command=self.run_query)
        self.run_button.pack(pady=5)

        # --- RESULT TABLE ---
        self.tree = ttk.Treeview(root)
        self.tree.pack(expand=True, fill="both")

        self.load_table_names()

    # Load table names into dropdown
    def load_table_names(self):
        self.cursor.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = DATABASE()
            ORDER BY table_name;
            """
        )
        tables = [t[0] for t in self.cursor.fetchall()]
        self.table_dropdown['values'] = tables

    # Display selected table
    def load_table(self):
        table_name = self.table_var.get()
        self.execute_and_display(f"SELECT * FROM {table_name}")

    # Run custom query
    def run_query(self):
        query = self.query_text.get("1.0", tk.END).strip()

        if not query:
            messagebox.showwarning("Warning", "Please enter a query.")
            return

        try:
            self.execute_and_display(query)
            self.conn.commit()
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # Core function to display results
    def execute_and_display(self, query):
        # Clear table
        self.tree.delete(*self.tree.get_children())

        self.cursor.execute(query)

        # If SELECT → show results
        if query.strip().lower().startswith("select"):
            rows = self.cursor.fetchall()
            col_names = [desc[0] for desc in self.cursor.description]

            self.tree["columns"] = col_names
            self.tree["show"] = "headings"

            for col in col_names:
                self.tree.heading(col, text=col)
                self.tree.column(col, width=120)

            for row in rows:
                self.tree.insert("", "end", values=row)
        else:
            # Non-SELECT query
            self.tree["columns"] = ["Result"]
            self.tree["show"] = "headings"
            self.tree.heading("Result", text="Result")
            self.tree.insert("", "end", values=("Query executed successfully",))


# ---------- MAIN ----------
if __name__ == "__main__":
    try:
        conn = setup_database()
        root = tk.Tk()
        app = DatabaseGUI(root, conn)
        root.mainloop()
    except Exception as err:
        messagebox.showerror("Database Error", str(err))