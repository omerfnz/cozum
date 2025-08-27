from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response
from rest_framework import status

from .models import Category, Comment, Report
from .serializers import (
    CategorySerializer,
    CommentSerializer,
    ReportCreateSerializer,
    ReportDetailSerializer,
    ReportListSerializer,
    ReportUpdateSerializer,
)


class CategoryListCreateView(generics.ListCreateAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Normal kullanıcılar sadece aktif kategorileri görür
        return Category.objects.filter(is_active=True).order_by("name")

    def perform_create(self, serializer):
        # Kategori oluşturma işini sadece staff üyeler yapabilir
        if not self.request.user.is_staff:
            raise PermissionDenied("Kategori oluşturma yetkiniz yok.")
        serializer.save()


class CategoryRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_update(self, serializer):
        # Kategori düzenleme işini sadece staff üyeler yapabilir
        if not self.request.user.is_staff:
            raise PermissionDenied("Kategori düzenleme yetkiniz yok.")
        serializer.save()

    def perform_destroy(self, instance):
        # Kategori silme işini sadece staff üyeler yapabilir
        if not self.request.user.is_staff:
            raise PermissionDenied("Kategori silme yetkiniz yok.")
        # Kategoriyi tamamen silmek yerine pasif yaparız
        instance.is_active = False
        instance.save()


class ReportListCreateView(generics.ListCreateAPIView):
    parser_classes = [MultiPartParser]

    def get_queryset(self):
        user = self.request.user
        qs = Report.objects.select_related("reporter", "category", "assigned_team")
        scope = self.request.query_params.get("scope")
        tasks_only = self.request.query_params.get("tasks_only", "false").lower() == "true"
        
        # Görevler için özel filtreleme - sadece atanmış bildirimleri göster
        if tasks_only:
            qs = qs.filter(assigned_team__isnull=False)
        
        if scope == "all":
            return qs
        if scope == "mine":
            return qs.filter(reporter=user)
        if scope == "assigned":
            return qs.filter(assigned_team=getattr(user, "team", None))
        if user.role == "OPERATOR" or user.is_staff:
            return qs
        if user.role == "EKIP":
            return qs.filter(assigned_team=user.team)
        # VATANDAS
        return qs.filter(reporter=user)

    def get_serializer_class(self):
        if self.request.method == "POST":
            return ReportCreateSerializer
        return ReportListSerializer

    def create(self, request, *args, **kwargs):
        """Oluşturma sonrası detay serileştirici ile yanıt dön (mobil ile uyum)"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        instance = serializer.instance
        output_serializer = ReportDetailSerializer(instance, context=self.get_serializer_context())
        headers = self.get_success_headers(output_serializer.data)
        return Response(output_serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)


class ReportRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Report.objects.select_related("reporter", "category", "assigned_team")
    lookup_url_kwarg = "report_id"

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        # API tarafında yetki kontrolü view'da yapılacağından serializer'daki izin validasyonunu atla
        ctx["skip_permission_validation"] = True
        return ctx

    def get_serializer_class(self):
        if self.request.method in ("PATCH", "PUT"):
            return ReportUpdateSerializer
        return ReportDetailSerializer

    def perform_update(self, serializer):
        user = self.request.user
        report = self.get_object()
        # Vatandaşlar güncelleyemez
        if user.role == "VATANDAS" and not user.is_staff:
            raise PermissionDenied("Bu bildirimi güncelleme yetkiniz yok.")
        # EKIP ise sadece kendi takımına atananları güncelleyebilir
        if user.role == "EKIP" and report.assigned_team != user.team:
            raise PermissionDenied("Bu bildirimi güncelleme yetkiniz yok.")
        serializer.save()

    def perform_destroy(self, instance):
        user = self.request.user
        # Vatandaşlar sadece kendi raporlarını silebilir
        if user.role == "VATANDAS" and instance.reporter != user:
            raise PermissionDenied("Bu bildirimi silme yetkiniz yok.")
        # EKIP silme yetkisi yok
        if user.role == "EKIP":
            raise PermissionDenied("Görev silme yetkiniz yok.")
        # OPERATOR/ADMIN tüm raporları silebilir
        if user.role not in ["OPERATOR", "ADMIN"] and not user.is_staff:
            raise PermissionDenied("Bu bildirimi silme yetkiniz yok.")
        instance.delete()


class ReportCommentsListCreateView(generics.ListCreateAPIView):
    serializer_class = CommentSerializer
    lookup_url_kwarg = "report_id"
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        report_id = self.kwargs.get(self.lookup_url_kwarg)
        return Comment.objects.filter(report_id=report_id).select_related("user")

    def perform_create(self, serializer):
        user = self.request.user
        report_id = self.kwargs.get(self.lookup_url_kwarg)
        # Vatandaşlar yalnızca kendi oluşturdukları raporlara yorum ekleyebilir
        if getattr(user, "role", None) == "VATANDAS" and not user.is_staff:
            try:
                report = Report.objects.get(id=report_id)
            except Report.DoesNotExist:
                raise PermissionDenied("Rapor bulunamadı.")
            if report.reporter_id != user.id:
                raise PermissionDenied("Bu rapora yorum ekleme yetkiniz yok.")
        serializer.save(user=user, report_id=report_id)


class CommentRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Comment.objects.select_related("user", "report")
    serializer_class = CommentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_update(self, serializer):
        user = self.request.user
        comment = self.get_object()
        if getattr(user, "role", None) != "OPERATOR" and not getattr(user, "is_staff", False) and comment.user_id != user.id:
            raise PermissionDenied("Yorum düzenleme yetkiniz yok.")
        serializer.save()

    def perform_destroy(self, instance):
        user = self.request.user
        if getattr(user, "role", None) != "OPERATOR" and not getattr(user, "is_staff", False) and instance.user_id != user.id:
            raise PermissionDenied("Yorum silme yetkiniz yok.")
        instance.delete()
