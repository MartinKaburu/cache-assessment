from flask import Flask, jsonify
from google.cloud import pubsub_v1
import psycopg2
import logging
import json
import os
import time
from threading import Thread

# --- Config ---
PUBSUB_TOPIC = os.environ.get("PUBSUB_TOPIC")
PROJECT_ID = os.environ.get("GCP_PROJECT")
DB_CONNECTION_STRING = os.environ.get("DB_CONNECTION_STRING")

# --- Logging ---
logger = logging.getLogger('app_logger')
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter(json.dumps({
    "timestamp": "%(asctime)s",
    "level": "%(levelname)s",
    "message": "%(message)s"
}))
handler.setFormatter(formatter)
logger.addHandler(handler)

app = Flask(__name__)

# --- DB Connection ---
def get_db_connection():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    return conn

# --- Ensure Table Exists ---
def ensure_messages_table():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id SERIAL PRIMARY KEY,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
        logger.info("Ensured 'messages' table exists.")
    except Exception as e:
        logger.error(f"Error ensuring messages table: {e}")

# --- Pub/Sub Publisher ---
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, PUBSUB_TOPIC)

# --- Background Task ---
def publish_and_write():
    while True:
        message = "Hello from Flask!"
        # Publish to Pub/Sub
        future = publisher.publish(topic_path, message.encode("utf-8"))
        logger.info(f"Published message to Pub/Sub: {message}")

        # Write to PostgreSQL
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("INSERT INTO messages (content) VALUES (%s)", (message,))
            conn.commit()
            cur.close()
            conn.close()
            logger.info(f"Wrote message to DB: {message}")
        except Exception as e:
            logger.error(f"DB error: {e}")

        time.sleep(300)  # 5 minutes

# --- Health Endpoint ---
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    # Ensure table exists at startup
    ensure_messages_table()

    # Start background thread
    thread = Thread(target=publish_and_write)
    thread.start()

    app.run(host="0.0.0.0", port=8080)
