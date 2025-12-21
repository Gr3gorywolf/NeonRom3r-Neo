import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_action_button.dart';
import 'package:neonrom3r/ui/widgets/rom_thumbnail.dart';
import 'package:neonrom3r/services/console_service.dart';

enum RomListItemType { card, listItem }

class RomListItem extends StatelessWidget {
  final RomInfo romItem;
  RomListItemType itemType;
  bool showConsole;

  RomListItem(
      {required this.romItem,
      this.showConsole = false,
      this.itemType = RomListItemType.listItem});
  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var _downloadInfo = _provider.getDownloadInfo(romItem);
    var _isRomDownloaded = _provider.getDownloadedRomInfo(romItem);
    var thumbnail = RomThumbnail(this.romItem!);
    var console = ConsoleService.getConsoleFromName(romItem!.console);
    var lastPlayed =
        _isRomDownloaded != null ? "Last played: " : "Not installed";

    navigateToDetails() {
      // MaterialPageRoute route = MaterialPageRoute(
      //     builder: (context) => RomDetailsPage(rom: romItem));
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => RomDetailsDialog(
                rom: romItem!,
              ));
    }

    handleLike() {}

    String getSubHeader() {
      var releaseDate = (romItem?.releaseDate?.isNotEmpty ?? false
              ? romItem.releaseDate
              : "---") ??
          "";
      if (showConsole) {
        return (console?.name ?? "") + " ● " + releaseDate;
      } else {
        return releaseDate;
      }
    }

    iconButtonStyle() {
      return IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          padding: EdgeInsets.all(4),
          minimumSize: Size(35, 35));
    }

    if (itemType == RomListItemType.listItem) {
      return InkWell(
          onTap: () {
            navigateToDetails();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                        child: thumbnail,
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 82),
                              child: Text(
                                romItem!.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Opacity(
                              opacity: 0.7,
                              child: Text(
                                getSubHeader(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            ...(_downloadInfo != null
                                ? [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    LinearProgressIndicator(
                                      backgroundColor: Colors.grey[800],
                                      value:
                                          (_downloadInfo.downloadPercent ?? 0) /
                                              100,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        _downloadInfo.downloadInfo ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    )
                                  ]
                                : []),
                            SizedBox(
                              height: 18,
                            ),
                            RomActionButton(
                              romItem,
                              size: RomActionButtonSize.small,
                            )
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom:
                              MediaQuery.of(context).size.width > 380 ? 9 : 36,
                          child: Row(
                            children: [
                              Opacity(
                                opacity: 0.7,
                                child: Text(lastPlayed,
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: 22,
                                style: iconButtonStyle(),
                                icon: Icon(Icons.star_border),
                                onPressed: () {
                                  navigateToDetails();
                                },
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              IconButton(
                                iconSize: 22,
                                style: iconButtonStyle(),
                                icon: Icon(Icons.tune),
                                onPressed: () {
                                  navigateToDetails();
                                },
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }

    return InkWell(
      onTap: () {
        navigateToDetails();
      },
      child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        child: thumbnail,
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      romItem!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        getSubHeader(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    ...(_downloadInfo != null
                        ? [
                            Spacer(),
                            LinearProgressIndicator(
                              backgroundColor: Colors.grey[800],
                              value: (_downloadInfo.downloadPercent ?? 0) / 100,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Opacity(
                              opacity: 0.7,
                              child: Text(
                                _downloadInfo.downloadInfo ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            )
                          ]
                        : []),
                    Spacer(),
                    Row(children: [
                      RomActionButton(
                        romItem,
                        size: RomActionButtonSize.small,
                      ),
                      Spacer(),
                      IconButton(
                        iconSize: 22,
                        style: iconButtonStyle(),
                        icon: Icon(Icons.star_border),
                        onPressed: () {
                          navigateToDetails();
                        },
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      IconButton(
                        iconSize: 22,
                        style: iconButtonStyle(),
                        icon: Icon(Icons.tune),
                        onPressed: () {
                          navigateToDetails();
                        },
                        color: Colors.grey,
                      ),
                    ]),
                    SizedBox(
                      height: 3,
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(lastPlayed,
                          style: Theme.of(context).textTheme.labelSmall),
                    )
                  ]))),
    );
  }
}
