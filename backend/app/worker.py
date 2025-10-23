"""Celery worker configuration."""
from celery import Celery

from app.core.config import settings

# Create Celery app
celery_app = Celery(
    "burnp3",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
)

# Configure Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes max
    task_soft_time_limit=25 * 60,  # 25 minutes soft limit
    worker_prefetch_multiplier=1,  # Only fetch one task at a time
    worker_max_tasks_per_child=10,  # Restart worker after 10 tasks
)

# Import tasks
# from app.tasks import ignition_sampling, burning_conditions, fire_growth, summarization

# Auto-discover tasks
# celery_app.autodiscover_tasks(['app.tasks'])


@celery_app.task(bind=True)
def debug_task(self):
    """Debug task for testing Celery setup."""
    print(f"Request: {self.request!r}")
    return {"status": "ok", "task_id": self.request.id}
