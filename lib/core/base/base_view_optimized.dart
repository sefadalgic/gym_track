import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Optimized base view - Only rebuilds the body, not the entire Scaffold
///
/// Bu versiyonda sadece body kısmı state değişikliklerinde rebuild edilir.
/// AppBar ve FAB statik kalır, bu da daha iyi performans sağlar.
///
/// Eğer AppBar veya FAB'ın state'e göre değişmesi gerekiyorsa,
/// onları da BlocBuilder ile sarmalayabilirsiniz.
abstract class BaseViewOptimized<B extends StateStreamableSource<S>, S>
    extends StatelessWidget {
  const BaseViewOptimized({super.key});

  B createBloc(BuildContext context);

  /// Builds the main content - THIS IS THE ONLY PART THAT REBUILDS
  Widget buildView(BuildContext context, S state);

  /// Static app bar - does NOT rebuild on state changes
  /// If you need dynamic app bar, wrap it with BlocBuilder in your implementation
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  /// Static FAB - does NOT rebuild on state changes
  /// If you need dynamic FAB, wrap it with BlocBuilder in your implementation
  Widget? buildFloatingActionButton(BuildContext context) => null;

  bool isLoading(S state) => false;
  String? getErrorMessage(S state) => null;

  Widget buildLoadingWidget(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  void onStateChanged(BuildContext context, S state) {}

  Color? get backgroundColor => null;
  bool get resizeToAvoidBottomInset => true;
  bool get useSafeArea => true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: createBloc,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: buildAppBar(context), // Static - no rebuild
        floatingActionButton:
            buildFloatingActionButton(context), // Static - no rebuild
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        // Only the body rebuilds on state changes
        body: BlocConsumer<B, S>(
          listener: onStateChanged,
          builder: (context, state) {
            final errorMessage = getErrorMessage(state);
            final loading = isLoading(state);

            Widget body;
            if (errorMessage != null) {
              body = buildErrorWidget(context, errorMessage);
            } else if (loading) {
              body = buildLoadingWidget(context);
            } else {
              body = buildView(context, state);
            }

            if (useSafeArea) {
              body = SafeArea(child: body);
            }

            return body;
          },
        ),
      ),
    );
  }
}
