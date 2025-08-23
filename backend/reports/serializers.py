"""Reports app serileştiricileri"""

from rest_framework import serializers

from users.serializers import TeamSerializer, UserDetailSerializer

from .models import Category, Comment, Media, Report


class CategorySerializer(serializers.ModelSerializer):
    """Kategori serileştiricisi"""

    class Meta:
        model = Category
        fields = ["id", "name", "description", "is_active"]


class MediaSerializer(serializers.ModelSerializer):
    """Medya serileştiricisi"""

    # 'file' alanını absolute URL olarak döndür
    file = serializers.SerializerMethodField()

    class Meta:
        model = Media
        fields = [
            "id",
            "file",
            "file_path",
            "file_size",
            "media_type",
            "uploaded_at",
        ]
        read_only_fields = ["file_path", "file_size", "uploaded_at"]

    def get_file(self, obj):
        file_field = getattr(obj, "file", None)
        if not file_field:
            return None
        try:
            url = file_field.url
            request = self.context.get("request") if hasattr(self, "context") else None
            if request is not None:
                return request.build_absolute_uri(url)
            return url
        except Exception:
            return None


class CommentSerializer(serializers.ModelSerializer):
    """Yorum serileştiricisi"""

    user = UserDetailSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ["id", "user", "content", "created_at"]
        read_only_fields = ["user", "created_at"]


class ReportListSerializer(serializers.ModelSerializer):
    """Bildirim listesi serileştiricisi (summary view için)"""

    reporter = UserDetailSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    assigned_team = TeamSerializer(read_only=True)
    media_count = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()
    first_media_url = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = [
            "id",
            "title",
            "status",
            "priority",
            "reporter",
            "category",
            "assigned_team",
            "location",
            "created_at",
            "updated_at",
            "media_count",
            "comment_count",
            "first_media_url",
        ]

    def get_media_count(self, obj):
        return obj.media_files.count()

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_first_media_url(self, obj):
        media = obj.media_files.first()
        if media and getattr(media, "file", None):
            try:
                request = self.context.get("request") if hasattr(self, "context") else None
                url = media.file.url
                if request is not None:
                    return request.build_absolute_uri(url)
                return url
            except Exception:
                return None
        return None


class ReportDetailSerializer(serializers.ModelSerializer):
    """Bildirim detayı serileştiricisi"""

    reporter = UserDetailSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    assigned_team = TeamSerializer(read_only=True)
    media_files = MediaSerializer(many=True, read_only=True)
    comments = CommentSerializer(many=True, read_only=True)

    # DecimalField olabilecek alanları mobil uyumluluğu için float olarak serileştir
    latitude = serializers.FloatField(allow_null=True, required=False)
    longitude = serializers.FloatField(allow_null=True, required=False)

    class Meta:
        model = Report
        fields = [
            "id",
            "title",
            "description",
            "status",
            "priority",
            "reporter",
            "category",
            "assigned_team",
            "location",
            "latitude",
            "longitude",
            "created_at",
            "updated_at",
            "media_files",
            "comments",
        ]


class ReportCreateSerializer(serializers.ModelSerializer):
    """Bildirim oluşturma serileştiricisi"""

    media_files = serializers.ListField(
        child=serializers.FileField(allow_empty_file=False), write_only=True, required=False
    )

    # Mobil taraf ile uyum için bu alanları float kabul et
    latitude = serializers.FloatField(allow_null=True, required=False)
    longitude = serializers.FloatField(allow_null=True, required=False)

    class Meta:
        model = Report
        fields = [
            "id",
            "title",
            "description",
            "category",
            "location",
            "latitude",
            "longitude",
            "media_files",
        ]
        read_only_fields = ["id"]

    def validate(self, attrs):
        """Tek dosya gönderiminde media_files alanını listeye dönüştür"""
        request = self.context.get("request")
        if request and hasattr(request, "FILES"):
            files = request.FILES.getlist("media_files")
            if files:
                attrs["media_files"] = files
        return attrs

    def create(self, validated_data):
        """Bildirim ve medya dosyalarını birlikte oluştur"""
        media_files = validated_data.pop("media_files", [])

        # Bildirimi oluştur
        report = Report.objects.create(**validated_data)

        # Medya dosyalarını oluştur
        for media_file in media_files:
            Media.objects.create(report=report, file=media_file, media_type="IMAGE")

        return report


class ReportUpdateSerializer(serializers.ModelSerializer):
    """Bildirim güncelleme serileştiricisi (operatör/ekip için)"""

    class Meta:
        model = Report
        fields = ["status", "priority", "assigned_team"]

    def validate(self, data):
        """Güncelleme yetkilerini kontrol et (isteğe bağlı olarak devre dışı bırakılabilir)"""
        # View tarafında override ile bu validasyonun atlanmasını sağlayacak flag
        if self.context.get("skip_permission_validation"):
            return data

        user = self.context["request"].user

        # EKIP sadece kendi takımına atanan raporları güncelleyebilir
        if getattr(user, "role", None) == "EKIP":
            report = self.instance
            if report and report.assigned_team != getattr(user, "team", None):
                raise serializers.ValidationError("Bu bildirimi güncelleme yetkiniz yok.")
        return data
