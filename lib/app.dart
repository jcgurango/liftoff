import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';

import 'app_link_handler.dart';
import 'l10n/l10n.dart';
import 'pages/home_page.dart';
import 'resources/app_theme.dart';
import 'resources/theme.dart';
import 'stores/config_store.dart';
import 'util/observer_consumers.dart';

final l10nDelegates = [
  ...L10n.localizationsDelegates,
  MaterialLocalizationsEo.delegate,
  CupertinoLocalizationsEo.delegate,
];

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: ChangeNotifierProvider(
        create: (context) => AppTheme(),
        child: Consumer<AppTheme>(
          builder: (context, state, child) {
            return ObserverBuilder<ConfigStore>(
              builder: (context, store) => MaterialApp(
                title: 'Liftoff',
                supportedLocales: L10n.supportedLocales,
                localizationsDelegates: l10nDelegates,
                themeMode: state.theme,
                darkTheme: themeFactory(
                    primaryColor: state.primaryColor,
                    amoled: state.amoled,
                    dark: true),
                locale: store.locale,
                theme: themeFactory(primaryColor: state.primaryColor),
                home: AppLinkHandler(const HomePage()),
              ),
            );
          },
        ),
      ),
    );
  }
}
