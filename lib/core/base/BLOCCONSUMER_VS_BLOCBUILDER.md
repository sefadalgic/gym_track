# BaseView BlocConsumer vs İç BlocBuilder - Detaylı Açıklama

## Soru: BlocConsumer zaten tetikleniyorsa, içerideki BlocBuilder ne fark eder?

Mükemmel bir soru! Cevap: **İki katmanlı optimizasyon** var.

## Widget Tree Yapısı

```
BaseView
  └─ BlocProvider
      └─ BlocConsumer ← DIŞ KATMAN (BaseView'da)
          └─ Scaffold
              └─ buildView() ← Bu metod çağrılır
                  └─ Column
                      ├─ BlocBuilder ← İÇ KATMAN (buildView içinde)
                      │   └─ Text
                      ├─ TextButton (statik)
                      └─ BlocBuilder
                          └─ Indicators
```

## State Değiştiğinde Ne Olur?

### Adım 1: BlocConsumer Tetiklenir (BaseView)

```dart
// base_view.dart
BlocConsumer<B, S>(
  listener: onStateChanged,  // ✅ ÇALIŞIR
  builder: (context, state) {
    // ✅ BU ÇALIŞIR
    return buildView(context, state);  // buildView() çağrılır
  }
)
```

**Sonuç:** `buildView()` metodu **tamamen** yeniden çalışır.

### Adım 2: buildView() Çalışır

```dart
Widget buildView(BuildContext context, OnboardingState state) {
  debugPrint('🔴 buildView çağrıldı');  // ✅ HER SEFERINDE YAZDIRILIIR
  
  return Column(  // ← YENİ Column instance
    children: [
      BlocBuilder<OnboardingBloc, OnboardingState>(  // ← YENİ BlocBuilder instance
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          // ❓ BU ÇALIŞIR MI?
          return Text('Page ${state.currentPage}');
        }
      ),
      TextButton(...),  // ← YENİ TextButton instance
    ],
  );
}
```

**Sonuç:** Tüm widget'lar yeniden oluşturulur (new instance).

### Adım 3: BlocBuilder Karar Verir

```dart
BlocBuilder<OnboardingBloc, OnboardingState>(
  buildWhen: (previous, current) {
    // ✅ BU KONTROL ÇALIŞIR
    return previous.currentPage != current.currentPage;
  },
  builder: (context, state) {
    // ❓ buildWhen true dönerse ÇALIŞIR
    // ❓ buildWhen false dönerse ÇALIŞMAZ
    return Text('Page ${state.currentPage}');
  }
)
```

## Gerçek Test Senaryoları

### Senaryo 1: currentPage Değişir (0 → 1)

```
1. BlocConsumer tetiklenir
   🔴 buildView çağrıldı - State: page=1
   
2. BlocBuilder.buildWhen kontrol eder
   🟢 BlocBuilder.buildWhen: true (0 → 1)
   
3. BlocBuilder.builder çalışır
   🟡 BlocBuilder.builder çağrıldı - Page: 1
   
4. Text widget güncellenir
   "Page 1 of 3" → "Page 2 of 3"
```

### Senaryo 2: isLoading Değişir (false → true)

```
1. BlocConsumer tetiklenir
   🔴 buildView çağrıldı - State: page=1
   
2. BlocBuilder.buildWhen kontrol eder
   🟢 BlocBuilder.buildWhen: false (1 → 1)
   
3. BlocBuilder.builder ÇALIŞMAZ ❌
   
4. Text widget AYNI KALIR
   "Page 2 of 3" (değişmez)
```

## Peki Gerçekten Fark Eder mi?

### ❌ Optimizasyon Olmadan

```dart
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      Text('Page ${state.currentPage}'),  // ← Her state değişikliğinde yeniden oluşturulur
      ComplexWidget(),                     // ← Her state değişikliğinde yeniden oluşturulur
      ExpensiveCalculation(),              // ← Her state değişikliğinde yeniden hesaplanır
    ],
  );
}
```

**isLoading değiştiğinde:**
- Text yeniden oluşturulur (gereksiz)
- ComplexWidget yeniden oluşturulur (gereksiz)
- ExpensiveCalculation yeniden hesaplanır (gereksiz)

### ✅ Optimizasyon İle

```dart
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text('Page ${state.currentPage}');
        }
      ),
      ComplexWidget(),           // ← Flutter widget tree diff ile yeniden kullanılır
      ExpensiveCalculation(),    // ← Flutter widget tree diff ile yeniden kullanılır
    ],
  );
}
```

**isLoading değiştiğinde:**
- BlocBuilder.buildWhen false döner
- Text **yeniden oluşturulmaz** ✅
- ComplexWidget Flutter tarafından yeniden kullanılır
- ExpensiveCalculation Flutter tarafından yeniden kullanılır

## Flutter'ın Widget Tree Diff'i

Flutter akıllıdır:

```dart
// Frame 1
TextButton(onPressed: fn, child: Text('Skip'))

// Frame 2 (buildView yeniden çalıştı)
TextButton(onPressed: fn, child: Text('Skip'))

// Flutter: "Aynı tip, aynı pozisyon → Element'i yeniden kullan"
// Yeni widget instance oluşturulur AMA Element ve RenderObject yeniden kullanılır
```

**Ama yine de:**
- Widget constructor çalışır (CPU)
- build() metodu çalışır (CPU)
- Gereksiz memory allocation (RAM)

## Asıl Kazanç: buildWhen ile Seçici Rebuild

```dart
BlocBuilder(
  buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
  builder: (context, state) {
    // SADECE currentPage değiştiğinde çalışır
    return ExpensiveWidget();
  }
)
```

**Kazanç:**
- ✅ Gereksiz build() çağrıları önlenir
- ✅ Gereksiz hesaplamalar önlenir
- ✅ Gereksiz memory allocation önlenir
- ✅ Daha iyi performans

## Özet

| Durum | BlocConsumer (Dış) | BlocBuilder (İç) | Sonuç |
|-------|-------------------|------------------|-------|
| currentPage değişir | ✅ Tetiklenir | ✅ buildWhen: true → Rebuild | Text güncellenir |
| isLoading değişir | ✅ Tetiklenir | ❌ buildWhen: false → Skip | Text aynı kalır |

**Cevap:** Evet, BlocConsumer tetiklenir ve buildView çalışır, **AMA** içerideki BlocBuilder'ın `buildWhen`'i sayesinde gereksiz rebuild'ler önlenir!

## Test Etmek İçin

Uygulamayı çalıştırın ve console'a bakın:

```bash
flutter run
```

Next butonuna bastığınızda:
```
🔴 buildView çağrıldı - State: page=1
🟢 BlocBuilder.buildWhen: true (0 → 1)
🟡 BlocBuilder.builder çağrıldı - Page: 1
```

Eğer başka bir state değişirse (örn: isLoading):
```
🔴 buildView çağrıldı - State: page=1
🟢 BlocBuilder.buildWhen: false (1 → 1)
(🟡 builder ÇALIŞMAZ)
```
