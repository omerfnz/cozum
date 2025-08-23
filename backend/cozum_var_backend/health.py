from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
@require_http_methods(["GET"])
def health_check(request):
    """Health check endpoint for Docker container monitoring."""
    return JsonResponse({
        "status": "healthy",
        "service": "cozum-var-backend",
        "version": "1.0.0"
    })