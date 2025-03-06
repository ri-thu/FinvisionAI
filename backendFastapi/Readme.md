# FastAPI Setup Guide

## 1. **Set Up Python Virtual Environment**
It's recommended to use a virtual environment to manage dependencies.

```sh
# Create a virtual environment
python -m venv .venv

# Activate the virtual environment
# On Windows (cmd / PowerShell):
.venv\Scripts\activate

# On macOS / Linux:
source .venv/bin/activate
```

## 2. **Install Required Dependencies**

```sh
pip install -r requirements.txt
```

## 3. **Run the FastAPI Server**

Assuming the FastAPI app is inside the `app` folder, use Uvicorn to run it:

```sh
uvicorn app.main:app --reload
```

- `app.main` → The path to the FastAPI instance (`app/main.py`).
- `app` → The FastAPI instance inside `main.py`.
- `--reload` → Enables auto-reloading (useful during development).

## 4. **Test the API**
Once the server is running, open your browser and visit:

- **Swagger UI:** [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **Redoc UI:** [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)
- **Test API Endpoint:** [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## 5. **(Optional) Create a `requirements.txt` File**
To save dependencies, run:

```sh
pip freeze > requirements.txt
```

To install dependencies later, run:

```sh
pip install -r requirements.txt
```

## 6. **(Optional) Run FastAPI with Gunicorn (for production)**
Instead of Uvicorn, use Gunicorn for better performance:

```sh
pip install gunicorn

gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app
```

- `-w 4` → Use 4 worker processes for handling requests.
- `-k uvicorn.workers.UvicornWorker` → Use Uvicorn worker for ASGI support.

---

### **FastAPI is now up and running! 🚀**
