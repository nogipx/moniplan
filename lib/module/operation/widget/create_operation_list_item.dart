import 'package:flutter/material.dart';
import 'package:moniplan/app/theme.dart';

class CreateOperationItem extends StatelessWidget {
  final VoidCallback? onPressed;

  const CreateOperationItem({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              color: AppTheme.lightBlueColor,
              size: 26,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добавить доход / расход',
                    style: Theme.of(context).textTheme.bodyText1?.apply(
                          color: AppTheme.blueColor,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '(или двойное нажатие в любом месте)',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
