# BaseView ile Granüler Optimizasyon

## Sorun

`BaseView` kullanırken her state değişikliğinde tüm `buildView()` metodu yeniden çağrılır. Eğer sadece küçük bir text widget değişiyorsa, tüm scaffold'un rebuild edilmesi verimsizdir.

## Çözüm: İçeride BlocBuilder Kullanın

`BaseView`'i kullanırken, **buildView içinde** sadece değişen kısımları `BlocBuilder` ile sarmalayın.

## Nasıl Çalışır?

### ❌ Verimsiz Yaklaşım (Eski)

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  // Her state değişikliğinde TÜM buildView çağrılır
  return Column(
    children: [
      Text('Page ${state.currentPage}'), // Rebuild
      SomeComplexWidget(),                // Rebuild (gereksiz!)
      AnotherWidget(),                    // Rebuild (gereksiz!)
      Button(),                           // Rebuild (gereksiz!)
    ],
  );
}
```

**Sorun:** `state.currentPage` değiştiğinde tüm widget'lar rebuild edilir.

### ✅ Verimli Yaklaşım (Yeni)

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  // buildView SADECE BİR KERE çağrılır (view ilk oluşturulduğunda)
  return Column(
    children: [
      // SADECE BU REBUILD EDİLİR
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text('Page ${state.currentPage}');
        },
      ),
      
      // BUNLAR HİÇ REBUILD EDİLMEZ
      SomeComplexWidget(),
      AnotherWidget(),
      Button(),
    ],
  );
}
```

**Avantaj:** Sadece text widget rebuild edilir, diğerleri statik kalır.

## buildWhen Nedir?

`buildWhen` parametresi, **ne zaman rebuild edileceğini** kontrol eder:

```dart
buildWhen: (previous, current) => previous.currentPage != current.currentPage
```

Bu şu anlama gelir:
- ✅ `currentPage` değişirse → Rebuild et
- ❌ Başka bir şey değişirse (örn: `isLoading`) → Rebuild etme

## Gerçek Dünya Örneği

### Onboarding View

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      // Sayfa içeriği - SADECE currentPage değiştiğinde rebuild
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text('Page ${state.currentPage + 1} of ${state.totalPages}');
        },
      ),
      
      // Skip butonu - HİÇ rebuild edilmez (statik)
      TextButton(
        onPressed: () => context.read<OnboardingBloc>().add(Skip()),
        child: const Text('Skip'),
      ),
      
      // Page indicators - SADECE currentPage değiştiğinde rebuild
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Row(
            children: List.generate(
              state.totalPages,
              (i) => Dot(isActive: i == state.currentPage),
            ),
          );
        },
      ),
      
      // Next butonu - SADECE currentPage değiştiğinde rebuild
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return ElevatedButton(
            onPressed: () => /* ... */,
            child: Text(state.isLastPage ? 'Done' : 'Next'),
          );
        },
      ),
    ],
  );
}
```

## Performans Karşılaştırması

| Yaklaşım | Rebuild Edilen Widget Sayısı | Performans |
|----------|------------------------------|------------|
| Verimsiz (tüm buildView) | ~10 widget | ⚠️ Orta |
| Verimli (granüler BlocBuilder) | ~3 widget | ✅ Yüksek |

## Ne Zaman Kullanmalı?

### ✅ Granüler BlocBuilder Kullan

- Karmaşık UI'lar
- Sadece küçük bir kısım değişiyorsa
- Performans kritikse
- Liste/grid gibi ağır widget'lar varsa

### ❌ Gerek Yok

- Basit UI'lar (2-3 widget)
- Zaten tüm UI değişiyorsa
- Profiler'da sorun yoksa

## En İyi Pratikler

### 1. buildWhen Kullanın

```dart
// ✅ İyi - Sadece gerektiğinde rebuild
buildWhen: (prev, curr) => prev.currentPage != curr.currentPage

// ❌ Kötü - Her state değişikliğinde rebuild
// buildWhen kullanmamak
```

### 2. Statik Widget'ları Dışarıda Bırakın

```dart
// ✅ İyi
const Text('Statik başlık')  // const = hiç rebuild edilmez

// ❌ Kötü
Text('Statik başlık')  // Her seferinde yeniden oluşturulur
```

### 3. Karmaşık Widget'ları Ayırın

```dart
// ✅ İyi
class ComplexWidget extends StatelessWidget {
  const ComplexWidget({super.key});
  // ...
}

// Kullanım
const ComplexWidget()  // const = hiç rebuild edilmez
```

## Özet

1. **BaseView her state değişikliğinde buildView'i çağırır** ✓
2. **İçeride BlocBuilder kullanarak sadece değişen kısımları rebuild edin** ✓
3. **buildWhen ile rebuild koşulunu kontrol edin** ✓
4. **Statik widget'lar için const kullanın** ✓

Bu yaklaşımla hem `BaseView`'in basitliğinden hem de granüler optimizasyondan faydalanırsınız! 🚀
