from fastapi import FastAPI

from .routers.health import router as health_router
from .routers.manifests import router as manifests_router
from .routers.sync import router as sync_router


def create_app() -> FastAPI:
    app = FastAPI(title="melingo api", version="0.1.0")
    app.include_router(health_router, prefix="/v1")
    app.include_router(manifests_router, prefix="/v1")
    app.include_router(sync_router, prefix="/v1")
    return app


app = create_app()
