from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.auth import router as auth_router
from api.dashboard import router as dashboard_router
from api.documents import router as documents_router
from api.ai import router as ai_router
from database import init_db

app = FastAPI(title='Seqotia API')

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        'http://localhost',
        'http://127.0.0.1',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:5555',
        'http://127.0.0.1:5555',
    ],
    allow_origin_regex=r'http://(localhost|127\.0\.0\.1)(:\d+)?',
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

app.include_router(auth_router)
app.include_router(dashboard_router)
app.include_router(documents_router)
app.include_router(ai_router)


@app.on_event('startup')
def startup() -> None:
    init_db()


@app.get('/health')
def health():
    return {'status': 'ok'}
