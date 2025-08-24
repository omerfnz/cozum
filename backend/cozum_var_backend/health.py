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
        
        # Test URL generation with dummy path
        try:
            from django.core.files.storage import default_storage
            test_url = default_storage.url('test/dummy.jpg')
            health_info["storage"]["test_url"] = test_url
            
            # Test R2 write permissions
            try:
                from django.core.files.base import ContentFile
                import boto3
                from botocore.exceptions import ClientError, NoCredentialsError
                
                test_file = ContentFile(b"test content", name="health_check_test.txt")
                test_path = default_storage.save('health_test/test.txt', test_file)
                health_info["storage"]["write_test"] = "SUCCESS"
                health_info["storage"]["test_file_path"] = test_path
                
                # Clean up test file
                try:
                    default_storage.delete(test_path)
                    health_info["storage"]["cleanup"] = "SUCCESS"
                except:
                    health_info["storage"]["cleanup"] = "FAILED"
                    
            except ClientError as client_error:
                health_info["storage"]["write_test"] = "FAILED"
                health_info["storage"]["write_error"] = f"ClientError: {str(client_error)}"
                health_info["storage"]["error_code"] = getattr(client_error, 'response', {}).get('Error', {}).get('Code', 'Unknown')
            except NoCredentialsError:
                health_info["storage"]["write_test"] = "FAILED"
                health_info["storage"]["write_error"] = "No credentials provided"
            except Exception as write_error:
                health_info["storage"]["write_test"] = "FAILED"
                health_info["storage"]["write_error"] = str(write_error)
                
        except Exception as e:
            health_info["storage"]["url_error"] = str(e)
    
    return JsonResponse(health_info)