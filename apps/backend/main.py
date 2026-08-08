from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI Backend on K8s!"}

@app.get("/api/data")
def get_data():
    return {"status": "success", "data": "Platform Engineering Demo"}
