import sqlite3
import tkinter as tk
from tkinter import ttk

# ---------- DATABASE SETUP ----------
def load_sql_file(cursor, filename):
    with open(filename, 'r') as f:
        sql_script = f.read()

    # Remove MySQL-specific commands
    # sql_script = sql_script.replace("CREATE DATABASE rentruck;", "")
    # sql_script = sql_script.replace("USE rentruck;", "")
    # sql_script = sql_script.replace("DROP DATABASE IF EXISTS rentruck;", "")

    cursor.executescript(sql_script)


def setup_database():
    conn = sqlite3.connect("rentruck.db")
    cursor = conn.cursor()

    # Load schema and data
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
        self.root.geometry("800x500")

        # Dropdown for tables
        self.table_var = tk.StringVar()
        self.table_dropdown = ttk.Combobox(root, textvariable=self.table_var)
        self.table_dropdown.pack(pady=10)

        # Button
        self.load_button = tk.Button(root, text="Load Table", command=self.load_table)
        self.load_button.pack()

        # Treeview (table display)
        self.tree = ttk.Treeview(root)
        self.tree.pack(expand=True, fill="both")

        self.load_table_names()

    def load_table_names(self):
        self.cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [t[0] for t in self.cursor.fetchall()]
        self.table_dropdown['values'] = tables

    def load_table(self):
        table_name = self.table_var.get()

        # Clear existing data
        self.tree.delete(*self.tree.get_children())

        # Get data
        self.cursor.execute(f"SELECT * FROM {table_name}")
        rows = self.cursor.fetchall()

        # Get column names
        col_names = [description[0] for description in self.cursor.description]

        self.tree["columns"] = col_names
        self.tree["show"] = "headings"

        for col in col_names:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=100)

        for row in rows:
            self.tree.insert("", "end", values=row)


# ---------- MAIN ----------
if __name__ == "__main__":
    conn = setup_database()

    root = tk.Tk()
    app = DatabaseGUI(root, conn)
    root.mainloop()