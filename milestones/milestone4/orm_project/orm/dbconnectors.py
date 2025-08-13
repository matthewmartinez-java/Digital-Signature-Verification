import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()


class MySQL:
    def connect(self):
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST"),         # Host where the MySQL server is running
            user=os.getenv("DB_USER"),                # Username for the database
            password=os.getenv("DB_PASSWORD"),        # Password for the user
            database=os.getenv("DB_NAME"),     # Name of the database to connect to
        )
        return connection


