import sqlite3
import tkinter as tk
from tkinter import ttk, messagebox

# ---------- DATABASE SETUP ----------
def load_sql_file(cursor, filename):
    with open(filename, 'r') as f:
        sql_script = f.read()

    # sql_script = sql_script.replace("CREATE DATABASE rentruck;", "")
    # sql_script = sql_script.replace("USE rentruck;", "")
    # sql_script = sql_script.replace("DROP DATABASE IF EXISTS rentruck;", "")

    cursor.executescript(sql_script)


def setup_database():
    conn = sqlite3.connect("rentruck.db")
    cursor = conn.cursor()

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
        self.cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
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
    conn = setup_database()

    root = tk.Tk()
    app = DatabaseGUI(root, conn)
    root.mainloop()