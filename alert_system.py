import psycopg

fileName = "/Users/obaidahmed/Desktop/P1_OA/logs/errorlogs.txt"

try :
    with psycopg.connect("dbname=log_monitoring user=obaidahmed") as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM log_entries WHERE log_level='[ERROR]'")
            error_count = cur.fetchone()[0]

            cur.execute("SELECT * FROM log_entries WHERE log_level='[ERROR]'")
            records = cur.fetchall()
            for row in records:
                with open(fileName, "a") as file:
                    file.write(str(row) + "\n")

            cur.execute("SELECT COUNT(*) FROM log_entries WHERE log_level='[FATAL]'")
            fatal_count = cur.fetchone()[0]

            cur.execute("SELECT * FROM log_entries WHERE log_level='[FATAL]'")
            records = cur.fetchall()
            for row in records:
                with open(fileName, "a") as file:
                    file.write(str(row) + "\n")

            if error_count >= 5 and fatal_count >=1:
                print(f"ALERT: ERROR - {error_count} logs, FATAL - {fatal_count} logs")

except Exception as e:
    print("Error connecting to db: ", e)