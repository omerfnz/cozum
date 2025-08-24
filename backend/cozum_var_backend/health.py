from django.http import JsonResponse  # pyright: ignore[reportMissingImports]
from django.views.decorators.http import require_http_methods  # pyright: ignore[reportMissingImports]
from django.views.decorators.csrf import csrf_exempt  # pyright: ignore[reportMissingImports]
from django.conf import settings  # pyright: ignore[reportMissingImports]


@csrf_exempt
@require_http_methods(["GET"])
def health_check(request):
    """Health check endpoint for Docker container monitoring."""
    
    health_info = {
        "status": "healthy",
        "service": "cozum-var-backend",
        "version": "1.0.0",
        "storage": {
            "type": "R2" if getattr(settings, 'USE_R2', False) else "local",
            "configured": bool(getattr(settings, 'USE_R2', False))
        }
    }
    
    # Add R2 configuration details if enabled
    if getattr(settings, 'USE_R2', False):
        health_info["storage"]["bucket"] = getattr(settings, 'R2_BUCKET_NAME', 'not-set')
        health_info["storage"]["domain"] = getattr(settings, 'R2_CUSTOM_DOMAIN', 'not-set')
        health_info["storage"]["media_url"] = getattr(settings, 'MEDIA_URL', 'not-set')
    
    return JsonResponse(health_info)