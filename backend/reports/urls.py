from django.urls import path

from .views import (
    CategoryListCreateView,
    CategoryRetrieveUpdateDestroyView,
    ReportCommentsListCreateView,
    ReportListCreateView,
    ReportRetrieveUpdateView,
    CommentRetrieveUpdateDestroyView,
)

urlpatterns = [
    path("categories/", CategoryListCreateView.as_view(), name="category-list-create"),
    path("categories/<int:pk>/", CategoryRetrieveUpdateDestroyView.as_view(), name="category-detail"),
    path("reports/", ReportListCreateView.as_view(), name="report-list-create"),
    path(
        "reports/<int:report_id>/",
        ReportRetrieveUpdateView.as_view(),
        name="report-detail-update",
    ),
    path(
        "reports/<int:report_id>/comments/",
        ReportCommentsListCreateView.as_view(),
        name="report-comments",
    ),
    path("comments/<int:pk>/", CommentRetrieveUpdateDestroyView.as_view(), name="comment-detail"),
]
