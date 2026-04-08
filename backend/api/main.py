from fastapi import FastAPI

from .routers.auth import router as auth_router
from .routers.health import router as health_router
from .routers.manifests import router as manifests_router
from .routers.profile import router as profile_router
from .routers.stats import router as stats_router
from .routers.sync import router as sync_router
from .state import ApiState


def create_app() -> FastAPI:
    app = FastAPI(title="melangua api", version="0.1.0")
    app.state.api_state = ApiState()
    app.include_router(auth_router, prefix="/v1")
    app.include_router(health_router, prefix="/v1")
    app.include_router(manifests_router, prefix="/v1")
    app.include_router(profile_router, prefix="/v1")
    app.include_router(stats_router, prefix="/v1")
    app.include_router(sync_router, prefix="/v1")
    return app


app = create_app()
