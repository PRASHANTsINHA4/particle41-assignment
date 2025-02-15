from flask import Flask, request, jsonify  
from datetime import datetime  

app = Flask(__name__)  

@app.route('/')  
def get_time():  
    return jsonify(dict(timestamp=str(datetime.utcnow()), ip=request.remote_addr))  

if __name__ == '__main__':  
    app.run(host='0.0.0.0', port=5000)  

