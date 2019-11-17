C недавних пор ["Сириус"](https://sochisirius.ru/) стал публиковать в открытом доступе списки школьников, прошедших [проектные смены](https://sochisirius.ru/obuchenie/project)

Разумеется в этих списках нет никаких контактов, иначе это было бы нарушением закона о защите персональных данных.

Однако зная ФИО и к тому же регион несложно найти нужного человека - с большой вероятностью он/она подписан(а) на [официальную группу Сириуса ВК](https://vk.com/siriusdeti) и другие сообщества Сириуса в других соцсетях (Instagram, Facebook и др.).

В общем случае можно использовать [поиск Яндекса по людям](https://yandex.ru/people)

Я сделал парсер на Perl, который извлекает все ФИО школьников в csv файл, а также [обертку на javascript](https://github.com/pavelsr/csv-to-tablesorter) которая отображает результаты в удобном виде

Настоящий репозиторий является форком от обёртки, дополнительно сюда помещён исходный код парсера (файл `parse.pl`)

## Как запустить парсер?

```
sudo cpm install -gv Mojolicious Text::CSV Data::Dumper::AutoEncode
perl parse.pl
```

Для установки перловых зависимостей можно использовать вместо `cpm` `cpan` или `cpanm`, однако я настоятельно рекомендую использовать [cpm](https://github.com/skaji/cpm) ибо он в разы быстрее.

## Как работает парсер?

Ниже описаны общие принципы работы

Пример ссылки со списком участников: https://sochisirius.ru/obuchenie/project/smena111/481

В общем виде к таким ссылкам можно получить доступ как

```
https://sochisirius.ru/obuchenie/project/smena<n>/<любой id>
```

, где `n` от `1` до крайнего id на https://sochisirius.ru/obuchenie/project

обращаемся к списку по id `tab-content-container`:

```
curl -L https://sochisirius.ru/obuchenie/project/smena111/481 | xmllint --format  --html --xpath '//div[contains(@id,"tab-content-container")]//text()' - 2>/dev/null
```

и обрабатываем исключения

https://sochisirius.ru/obuchenie/project/smena102/481 - страница не найдена

https://sochisirius.ru/obuchenie/iskusctvo/smena99/375 - нет пофамильного списка

https://sochisirius.ru/obuchenie/project/smena400/1993 - здесь список в виде li, а на предыдущих страницах нет

## Как родилась идея?

После [Хакатона ВК](https://vk.com/wall-103600381_1035)
