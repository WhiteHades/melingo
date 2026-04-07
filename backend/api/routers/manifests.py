from fastapi import APIRouter

router = APIRouter(tags=["manifests"])


@router.get("/models/manifest")
def model_manifest() -> dict[str, object]:
    return {
        "version": "2026.04.01",
        "bundles": ["lite", "balanced", "quality"],
        "encryption_required": True,
    }
