import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base view widget for all screens using BLoC pattern.
///
/// This widget provides a standardized structure for screens with:
/// - Automatic BLoC creation and disposal
/// - Loading state handling
/// - Error state handling
/// - Custom app bar support
///
/// Type parameters:
/// - [B]: The BLoC type that manages state for this view
/// - [S]: The state type emitted by the BLoC
///
/// Example usage:
/// ```dart
/// class LoginView extends BaseView<LoginBloc, LoginState> {
///   const LoginView({super.key});
///
///   @override
///   LoginBloc createBloc(BuildContext context) => LoginBloc();
///
///   @override
///   Widget buildView(BuildContext context, LoginState state) {
///     return Column(
///       children: [
///         TextField(/* ... */),
///         ElevatedButton(/* ... */),
///       ],
///     );
///   }
/// }
/// ```
abstract class BaseView<B extends StateStreamableSource<S>, S>
    extends StatelessWidget {
  const BaseView({super.key});

  /// Creates the BLoC instance for this view.
  ///
  /// This method is called once when the view is built.
  /// The BLoC will be automatically disposed when the view is removed.
  B createBloc(BuildContext context);

  /// Builds the main content of the view based on the current state.
  ///
  /// This method is called whenever the state changes.
  Widget buildView(BuildContext context, S state);

  /// Optional: Builds a custom app bar for this view.
  ///
  /// Return null to hide the app bar.
  PreferredSizeWidget? buildAppBar(BuildContext context, S state) => null;

  /// Optional: Builds a floating action button for this view.
  ///
  /// Return null to hide the FAB.
  Widget? buildFloatingActionButton(BuildContext context, S state) => null;

  /// Optional: Determines if the view should show a loading indicator.
  ///
  /// Override this to customize loading state detection.
  bool isLoading(S state) => false;

  /// Optional: Extracts error message from state.
  ///
  /// Return null if there's no error.
  String? getErrorMessage(S state) => null;

  /// Optional: Builds a custom loading widget.
  ///
  /// Override this to customize the loading indicator.
  Widget buildLoadingWidget(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Optional: Builds a custom error widget.
  ///
  /// Override this to customize error display.
  Widget buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Optional: Called when state changes.
  ///
  /// Use this for side effects like showing snackbars or navigation.
  void onStateChanged(BuildContext context, S state) {}

  /// Optional: Background color for the scaffold.
  Color? get backgroundColor => null;

  /// Optional: Whether to resize the view when keyboard appears.
  bool get resizeToAvoidBottomInset => true;

  /// Optional: Whether to use SafeArea.
  bool get useSafeArea => true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: createBloc,
      child: BlocConsumer<B, S>(
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

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: buildAppBar(context, state),
            body: body,
            floatingActionButton: buildFloatingActionButton(context, state),
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          );
        },
      ),
    );
  }
}
