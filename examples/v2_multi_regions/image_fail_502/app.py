import os
import sys
from flask import Flask

app = Flask(__name__)

@app.route("/")
def fail():
    # Isso mata o container abruptamente. 
    # O Cloud Run/Load Balancer retornará 502 Bad Gateway.
    os._exit(1) 

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
