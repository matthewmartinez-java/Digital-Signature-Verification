# base.py
#
# This file defines the `Base` class, which serves as the foundation for all ORM models.
# The `Base` class provides essential methods for interacting with the database, such as:
#   - `save()`: Insert or update the current model instance in the database.
#   - `_insert()`: Insert the current instance into the database (private method).
#   - `_update()`: Update the current instance in the database (private method).
#   - `get()`: Retrieve a record by its ID.
#   - `delete()`: Delete a record by its ID.
#   - `get_all()`: Retrieve all records of the model from the database.
#   - `query()`: Query records based on filter conditions.
#   - `create_table()`: Create a table in the database based on the model's schema.
#   - `create_schema()`: Generate the schema for the model in the database.
#   - `join()`: Join multiple models together for data retrieval.
#   - `where()`: Add WHERE conditions to queries.
#   - `having()`: Add HAVING conditions to queries.
#   - `group_by()`: Add GROUP BY clauses to queries.
#
# Connection management is critical. Every method interacting with the database must:
#   - Open a new connection and cursor at the start of the operation.
#   - Close the cursor and connection after the operation is complete,
#     whether the operation is successful or not, to avoid memory leaks.
#   - Transactions must be committed on success, and rolled back on failure.
#
# Students should implement proper connection management in each method, including:
#   - Using `try`, `except`, and `finally` to ensure the connection and cursor are always closed.
#   - Handling potential exceptions during database operations and performing rollbacks if needed.
#
# Example usage of the Base class:
#
#   class User(Base):
#       def __init__(self, **kwargs):
#           super().__init__(**kwargs)
#           self.name = kwargs.get('name')
#           self.email = kwargs.get('email')
#
#   # Using the `User` model:
#   user = User(name='Alice', email='alice@example.com')
#   user.save()  # Insert or update the user record in the database.
#
#   # Example of using WHERE condition:
#   where_condition = User.where(name="Alice", age=25)
#   query = f"SELECT * FROM users {where_condition}"
#   print(query)  # Output: SELECT * FROM users WHERE name = 'Alice' AND age = 25
#
#   # Example of using GROUP BY:
#   group_by_condition = User.group_by('name')
#   query = f"SELECT name, COUNT(*) FROM users {group_by_condition} HAVING COUNT(*) > 5"
#   print(query)  # Output: SELECT name, COUNT(*) FROM users GROUP BY name HAVING COUNT(*) > 5
#
#   # Example of using HAVING condition:
#   having_condition = User.having(count="orders", condition="> 5")
#   query = f"SELECT * FROM users {having_condition}"
#   print(query)  # Output: SELECT * FROM users HAVING COUNT(orders) > 5
#
# The `Base` class is meant to be subclassed, and any model that extends `Base` will automatically
# inherit the methods for database interaction.


from orm.dbconnectors import MySQL
from orm.columns import Column


class Base:
    def __init__(self, **kwargs):
        """Initialize model instance with attributes."""
        self._db = MySQL()
        for key, value in kwargs.items():
            setattr(self, key, value)

    def save(self):
        """Insert or update the record in the database.

        TODO:
            - If the model instance has an `id`, call `_update()` to update the existing record.
            - Otherwise, call `_insert()` to insert the new record.
            - Ensure connection and cursor management is handled properly (open and close as needed).
        """

        if hasattr(self, "id") and getattr(self, "id") is not None:
            self._update()
        else:
            self._insert()

    def _insert(self):
        """Insert the current instance into the database.

        TODO:
            - Open a new connection and cursor.
            - Construct the `INSERT` SQL query to add the model instance.
            - Ensure the connection and cursor are properly closed after the operation, even if an error occurs.
            - Commit the transaction if successful; rollback if there's an error.
        """
        table = self.__class__.__name__.lower()
        columns = []
        values = []
        placeholders = []

        for attr, value in self.__dict__.items():
            if attr.startswith("_") or callable(value) or isinstance(value, (list, dict)):
                continue
            columns.append(attr)
            values.append(value)
            placeholders.append("%s")

        sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({', '.join(placeholders)})"

        conn = self._db.connect()
        cursor = conn.cursor()

        try:
            cursor.execute(sql, values)
            conn.commit()

            for attr in self.__dict__:
                if attr.endswith("_id") and getattr(self, attr) is None:
                    setattr(self, attr, cursor.lastrowid)
        except Exception as e:
            print(f"[ERROR] Insert failed: {e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()

    def _update(self):
        """Update the current instance in the database.

        TODO:
            - Open a new connection and cursor.
            - Construct the `UPDATE` SQL query to modify the existing record.
            - Ensure the connection and cursor are properly closed after the operation, even if an error occurs.
            - Commit the transaction if successful; rollback if there's an error.
        """
        table = self.__class__.__name__.lower()
        updates = []
        values = []
        pk = None
        pk_column = None

        for attr, value in self.__dict__.items():
            if attr.startswith("_") or callable(value) or isinstance(value, (list, dict)):
                continue
            if attr.endswith("_id") and pk is None:
                pk = value
                pk_column = attr
                continue
            updates.append(f"{attr} = %s")
            values.append(value)

        if not pk or not pk_column:
            print("[ERROR] Cannot update: Primary key is missing")
            return

        values.append(pk)
        sql = f"UPDATE {table} SET {', '.join(updates)} WHERE {pk_column} = %s"

        conn = self._db.connect()
        cursor = conn.cursor()

        try:
            cursor.execute(sql, values)
            conn.commit()
        except Exception as e:
            print(f"[ERROR] Update failed: {e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def get(cls, table, id):
        """Retrieve a record from the database by its ID.

        TODO:
            - Open a connection and cursor.
            - Construct the `SELECT` SQL query to fetch the record by its primary key (`id`).
            - Ensure the connection and cursor are properly closed after the operation.
            - Handle potential exceptions using `try`, `except`, and `finally` blocks.
        """
        conn = MySQL().connect()
        cursor = conn.cursor(dictionary=True)

        try:
            pk = "user_id" if table == "user" else "id"
            query = f"SELECT * FROM {table} WHERE {pk} = %s"
            cursor.execute(query, (id,))
            result = cursor.fetchone()
            return cls(**result) if result else None
        except Exception as e:
            print(f"[ERROR] Failed to get {table} by id: {e}")
            return None
        finally:
            cursor.close()
            conn.close()


    @classmethod
    def delete(cls, table, id):
        """Delete a record from the database by its ID.

        TODO:
            - Open a connection and cursor.
            - Construct the `DELETE` SQL query to remove the record by its primary key (`id`).
            - Ensure the connection and cursor are properly closed after the operation.
            - Commit the transaction if successful; rollback if there's an error.
        """
        conn = MySQL().connect()
        cursor = conn.cursor()

        try:
            pk_column = "user_id" if table == "user" else "id"
            query = f"DELETE FROM {table} WHERE {pk_column} = %s"
            cursor.execute(query, (id,))
            conn.commit()
            print(f"[INFO] Record with {pk_column}={id} deleted from {table}")
        except Exception as e:
            print(f"[ERROR] Failed to delete from {table}: {e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def get_all(cls, table=None):
        """Retrieve all records of this model from the database.

        TODO:
            - Open a connection and cursor.
            - Construct the `SELECT` SQL query to fetch all records.
            - Ensure the connection and cursor are properly closed after the operation.
            - Return the results as instances of the model.
        """
        table = table or cls.__name__.lower()
        conn = MySQL().connect()
        cursor = conn.cursor(dictionary=True)

        try:
            cursor.execute(f"SELECT * FROM {table}")
            results = cursor.fetchall()
            return [cls(**row) for row in results]
        except Exception as e:
            print(f"[ERROR] failed to get all from {table}: {e}")
            return []
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def query(cls, **filters):
        """Query records based on filters.

        TODO:
            - Open a connection and cursor.
            - Construct the `SELECT` SQL query using the provided filters as conditions.
            - Ensure the connection and cursor are properly closed after the operation.
            - Return the results as instances of the model.
        """
        table = cls.__name__.lower()
        conn = MySQL().connect()
        cursor = conn.cursor(dictionary=True)

        try:
            where_clause = cls.where(**filters)
            sql = f"SELECT * FROM {table} {where_clause}"
            values = tuple(filters.values())
            cursor.execute(sql, values)
            rows = cursor.fetchall()
            return [cls(**row) for row in rows]
        except Exception as e:
            print(f"[ERROR] Query failed: {e}")
            return []
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def create_table(cls, table_name, schema=None):
        """Create a table for an existing schema.

        TODO:
            - Open a connection and cursor.
            - Construct the `CREATE TABLE` SQL query using the provided schema.
            - Ensure the connection and cursor are properly closed after the operation.
            - Commit the transaction if successful; rollback if there's an error.
        """
        conn = MySQL().connect()
        cursor = conn.cursor()

        try:
            fields = []
            for attr, value in cls.__dict__.items():
                if isinstance(value, Column):
                    col_name = attr
                    col_type = value.type.get_sql()
                    col_constraints = value.get_constraints()
                    fields.append(f"{col_name} {col_type} {col_constraints}".strip())

            sql = f"CREATE TABLE IF NOT EXISTS {table_name} ({', '.join(fields)})"
            cursor.execute(sql)
            conn.commit()
        except Exception as e:
            print(f"[ERROR] Create table failed: {e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def create_schema(cls, descriptor=None):
        """Generate the schema for the model in the database.

        TODO:
            - Open a connection and cursor.
            - Construct the `CREATE SCHEMA` SQL query using the provided descriptor.
            - Ensure the connection and cursor are properly closed after the operation.
            - Commit the transaction if successful; rollback if there's an error.
        """
        pass

    @classmethod
    def join(cls, join_model, on=None, where=None):
        """Join multiple models to organize your data.

        TODO:
            - Open a connection and cursor.
            - Construct the appropriate `JOIN` SQL query to combine data from multiple models.
            - Ensure the connection and cursor are properly closed after the operation.
            - Return the joined results.
        """
        conn = MySQL().connect()
        cursor = conn.cursor(dictionary=True)

        try:
            table1 = cls.__name__.lower()
            table2 = join_model.__name__.lower()

            if not on or len(on) != 2:
                raise ValueError("Join must include a tuple of ON fields")

            on_clause = f"{on[0]} = {on[1]}"
            sql = f"SELECT * FROM {table1} JOIN {table2} ON {on_clause}"

            values = ()
            if where:
                filters = " AND ".join([f"{k} = %s" for k in where])
                sql += f" WHERE {filters}"
                values = tuple(where.values())

            cursor.execute(sql, values)
            return cursor.fetchall()
        except Exception as e:
            print(f"[ERROR] Failed JOIN: {e}")
            return []
        finally:
            cursor.close()
            conn.close()

    @classmethod
    def where(cls, **conditions):
        """Add WHERE conditions to a query.

        TODO:
            - This method should help in adding WHERE conditions to any SELECT query.
            - Build the WHERE clause dynamically based on the given conditions (e.g., `WHERE column = value`).
            - Return the generated WHERE condition string.
        """
        if not conditions:
            return ""
        clause = " AND ".join([f"{col} = %s" for col in conditions])
        return f"WHERE {clause}"

    @classmethod
    def having(cls, **conditions):
        """Add HAVING conditions to a query.

        TODO:
            - This method should help in adding HAVING conditions to a query.
            - Construct the HAVING clause dynamically (useful when performing aggregate functions).
            - Return the generated HAVING condition string.
        """
        if not conditions:
            return ""
        clause = " AND ".join([f"{col} {cond}" for col, cond in conditions.items()])
        return f"HAVING {clause}"

    @classmethod
    def group_by(cls, *columns):
        """Add GROUP BY clauses to a query.

        TODO:
            - This method should help in adding GROUP BY clauses to any SELECT query.
            - Construct the GROUP BY clause dynamically based on the provided columns (e.g., `GROUP BY column1, column2`).
            - Return the generated GROUP BY condition string.
        """
        if not columns:
            return ""
        return "GROUP BY " + ", ".join(columns)
