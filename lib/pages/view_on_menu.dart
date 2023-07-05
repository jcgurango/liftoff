import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v3.dart';

import '../hooks/memo_future.dart';
import '../hooks/stores.dart';
import '../l10n/l10n.dart';
import '../stores/accounts_store.dart';
import '../util/mobx_provider.dart';
import '../util/observer_consumers.dart';
import '../widgets/bottom_modal.dart';
import '../widgets/cached_network_image.dart';
import 'community/community.dart';
import 'community/community_store.dart';

class ViewOnMenu extends HookWidget {
  final void Function(UserData userData) onSelect;

  const ViewOnMenu({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final accountsStore = useAccountsStore();
    final theme = Theme.of(context);
    final instancesIcons = useMemoFuture(() async {
      final sites = await Future.wait(accountsStore.instances.map((e) =>
          LemmyApiV3(e)
              .run<FullSiteView?>(const GetSite())
              .catchError((e) => null)));

      return {
        for (final site in sites)
          if (site != null) site.instanceHost: site.siteView?.site.icon
      };
    });

    return Column(children: [
      ListTile(
          title: Text(
        L10n.of(context).view_on,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )),
      for (final instance in accountsStore.loggedInInstances) ...[
        ListTile(
          title: Text(
            instance.toUpperCase(),
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7)),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity:
              const VisualDensity(vertical: VisualDensity.minimumDensity),
          leading:
              (instancesIcons.hasData && instancesIcons.data![instance] != null)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: CachedNetworkImage(
                          imageUrl: instancesIcons.data![instance]!,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    )
                  : const SizedBox(width: 30),
        ),
        for (final account in accountsStore.allUserDataFor(instance)) ...[
          ListTile(
            title: Text('${account.username}@$instance'),
            onTap: () => onSelect(account),
            leading: const SizedBox(width: 20),
          ),
        ]
      ],
    ]);
  }

  static void open(
      BuildContext context, void Function(UserData userData) onSelect) {
    final store = context.read<CommunityStore>();

    showBottomModal(
      context: context,
      builder: (context) => MobxProvider.value(
        value: store,
        child: ViewOnMenu(
          onSelect: onSelect,
        ),
      ),
    );
  }

  static void openForCommunity(
      BuildContext context, CommunityView communityView) {
    ViewOnMenu.open(context, (UserData userData) {
      Navigator.of(context).push(CommunityPage.fromApIdRoute(
          userData, communityView.community.actorId));
    });
  }
}
