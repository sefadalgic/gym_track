# Statik Widget'lar İçin Optimizasyon Rehberi

## Kural: Her Widget'ı BlocBuilder ile Sarmalamayin!

Sadece **state'e bağlı olan** widget'ları BlocBuilder ile sarmalayın. Statik widget'lar için `const` kullanın.

## Karar Ağacı

```
Widget state'e bağlı mı?
├─ HAYIR → const kullan (BlocBuilder GEREKSIZ)
└─ EVET → BlocBuilder + buildWhen kullan
```

## Örnekler

### ✅ Statik Widget - const Kullan

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      // ✅ Hiç değişmeyen başlık
      const Text('Welcome to Gym Track'),
      
      // ✅ Hiç değişmeyen padding
      const SizedBox(height: 20),
      
      // ✅ Hiç değişmeyen divider
      const Divider(),
      
      // ✅ Hiç değişmeyen icon
      const Icon(Icons.fitness_center),
    ],
  );
}
```

**Neden const?**
- Flutter const widget'ları **compile time'da** oluşturur
- Bellekte **tek bir instance** tutulur
- `buildView()` her çağrıldığında **aynı instance** kullanılır
- **Hiç rebuild edilmez** - en performanslı yöntem

### ✅ Dinamik Widget - BlocBuilder Kullan

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      // ✅ currentPage'e bağlı - BlocBuilder kullan
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text('Page ${state.currentPage}');
        },
      ),
      
      // ✅ isLastPage'e bağlı - BlocBuilder kullan
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text(state.isLastPage ? 'Done' : 'Next');
        },
      ),
    ],
  );
}
```

### ⚠️ Callback'li Widget - const Kullanılamaz

```dart
// ❌ HATA: const ile callback kullanılamaz
const TextButton(
  onPressed: () => print('clicked'),  // Callback = const olamaz
  child: Text('Click'),
)

// ✅ DOĞRU: const kullanma, Flutter optimize eder
TextButton(
  onPressed: () => context.read<Bloc>().add(Event()),
  child: const Text('Click'),  // ✅ Child const olabilir
)
```

**Neden const kullanılamaz?**
- Callback'ler runtime'da oluşturulur
- const sadece compile-time sabitler için

**Flutter nasıl optimize eder?**
- Widget tree diff algoritması
- Aynı tip, aynı key → Element yeniden kullanılır
- Performans kaybı minimal

## Gerçek Dünya Örneği

```dart
@override
Widget buildView(BuildContext context, OnboardingState state) {
  return Column(
    children: [
      // ✅ STATIK - const
      const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Welcome to Gym Track',
          style: TextStyle(fontSize: 24),
        ),
      ),
      
      // ✅ DİNAMİK - BlocBuilder
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        builder: (context, state) {
          return Text('Page ${state.currentPage + 1}');
        },
      ),
      
      // ✅ STATIK - const
      const Divider(),
      
      // ⚠️ CALLBACK VAR - const kullanılamaz ama sorun değil
      TextButton(
        onPressed: () => context.read<OnboardingBloc>().add(Skip()),
        child: const Text('Skip'),  // ✅ Child const
      ),
      
      // ✅ DİNAMİK - BlocBuilder
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

| Widget Tipi | Optimizasyon | Rebuild Sıklığı | Performans |
|-------------|--------------|-----------------|------------|
| `const Text('Static')` | ✅ En iyi | ❌ Hiç | ⭐⭐⭐⭐⭐ |
| `TextButton(onPressed: ...)` | ✅ İyi | ⚠️ buildView her çağrıldığında | ⭐⭐⭐⭐ |
| `BlocBuilder + buildWhen` | ✅ İyi | ⚠️ buildWhen true ise | ⭐⭐⭐⭐ |
| `Text(state.value)` | ❌ Kötü | ✅ Her state değişikliğinde | ⭐⭐ |

## En İyi Pratikler

### 1. const Kullanımı Maksimize Edin

```dart
// ✅ İyi
const Column(
  children: [
    Text('Title'),
    SizedBox(height: 20),
    Icon(Icons.check),
  ],
)

// ❌ Kötü
Column(
  children: [
    Text('Title'),
    SizedBox(height: 20),
    Icon(Icons.check),
  ],
)
```

### 2. Karmaşık Statik Widget'ları Ayırın

```dart
// ✅ İyi
class _StaticHeader extends StatelessWidget {
  const _StaticHeader();
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Welcome'),
        Icon(Icons.fitness_center),
      ],
    );
  }
}

// Kullanım
const _StaticHeader()  // Hiç rebuild edilmez
```

### 3. BlocBuilder'ı Mümkün Olduğunca Dar Tutun

```dart
// ✅ İyi - Sadece gerekli kısım sarmalanmış
Column(
  children: [
    const Text('Static'),
    BlocBuilder<Bloc, State>(
      builder: (context, state) => Text(state.value),
    ),
    const Text('Static'),
  ],
)

// ❌ Kötü - Tüm column sarmalanmış
BlocBuilder<Bloc, State>(
  builder: (context, state) {
    return Column(
      children: [
        const Text('Static'),  // Gereksiz rebuild
        Text(state.value),
        const Text('Static'),  // Gereksiz rebuild
      ],
    );
  },
)
```

## Özet

1. **Statik widget → `const` kullan** (en performanslı)
2. **Dinamik widget → `BlocBuilder + buildWhen`** (seçici rebuild)
3. **Callback'li widget → `const` kullanılamaz ama sorun değil** (Flutter optimize eder)
4. **buildView parametresindeki `state`'i KULLANMA** (her state değişikliğinde rebuild)

Bu kurallara uyarsanız maksimum performans alırsınız! 🚀
