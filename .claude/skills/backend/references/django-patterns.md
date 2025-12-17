# Django Backend Patterns

## Model Definition

```python
from django.db import models

class Token(models.Model):
    address = models.CharField(max_length=42, unique=True)
    name = models.CharField(max_length=255)
    symbol = models.CharField(max_length=10)
    total_supply = models.DecimalField(max_digits=78, decimal_places=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.symbol})"
```

## Serializers

```python
from rest_framework import serializers

class TokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = Token
        fields = ['id', 'address', 'name', 'symbol', 'total_supply', 'created_at']
        read_only_fields = ['id', 'created_at']
```

## ViewSets

```python
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

class TokenViewSet(viewsets.ModelViewSet):
    queryset = Token.objects.all()
    serializer_class = TokenSerializer

    @action(detail=False, methods=['get'])
    def popular(self, request):
        popular_tokens = self.queryset.filter(total_supply__gt=1000000)
        serializer = self.get_serializer(popular_tokens, many=True)
        return Response(serializer.data)
```

## URL Configuration

```python
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'tokens', TokenViewSet)

urlpatterns = router.urls
```
