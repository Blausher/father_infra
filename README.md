# Father Infra

Воспроизводимый деплой персонального [Hermes Agent](https://hermes-agent.nousresearch.com/docs/) на этом сервере.

Hermes работает в Docker, принимает сообщения из Telegram и выделенного почтового ящика и хранит знания в локальном Obsidian vault. Сервис не публикует входящие порты в интернет: Telegram и email работают через исходящие соединения, а управление выполняется по SSH.

## Архитектура

```text
Telegram ─┐
          ├─> Hermes gateway ─> LLM provider
Email ────┘         │
                    └─> ./data/obsidian-vault (Markdown)
```

Состояние Hermes хранится в `./data/hermes`, а Obsidian vault — в `./data/obsidian-vault`. Оба каталога исключены из Git, потому что первый содержит секреты и историю разговоров, а второй — личные знания.

## Первый запуск

Самый короткий путь — запустить единый интерактивный установщик и следовать подсказкам:

```bash
./scripts/install.sh
```

Он запросит системный пароль через `sudo`, затем откроет официальные мастера Hermes для выбора модели, Telegram и email. Секреты вводятся непосредственно на сервере и не проходят через Git.

Те же действия вручную описаны ниже.

Подготовить приватные каталоги и стартовые правила:

```bash
./scripts/init.sh
```

Загрузить стабильный образ и пройти мастер настройки модели:

```bash
sudo docker compose pull
sudo docker compose run --rm hermes setup
```

Затем настроить каналы связи:

```bash
sudo docker compose run --rm hermes gateway setup
```

В мастере выберите Telegram и Email. Для Telegram понадобятся токен от `@BotFather` и ваш числовой Telegram user ID. Для почты используйте отдельный ящик, app password и обязательно задайте список разрешённых отправителей.

После настройки запустить сервис:

```bash
sudo docker compose up -d
sudo docker compose logs --tail=100 hermes
```

Проверить состояние:

```bash
sudo docker compose exec hermes hermes status --full
sudo docker compose exec hermes hermes doctor
```

## Как сохранять знания

Напишите боту, например:

```text
Запомни: в нашем проекте production-деплой выполняется только из main.
```

Hermes создаст или обновит Markdown-заметку в `10 Knowledge/`, добавит источник и дату, а исходный материал при необходимости положит в `00 Inbox/`. Правила находятся в `.hermes.md` внутри vault.

Чтобы открыть базу на другом компьютере в приложении Obsidian, синхронизируйте каталог `data/obsidian-vault` через Obsidian Sync, Syncthing или приватный Git-репозиторий. Выберите только один механизм синхронизации, чтобы избежать конфликтов файлов.

## Эксплуатация

Обновление до свежего стабильного образа:

```bash
sudo docker compose pull
sudo docker compose up -d
sudo docker compose exec hermes hermes doctor
```

Логи и остановка:

```bash
sudo docker compose logs -f hermes
sudo docker compose down
```

Для согласованной копии SQLite установщик кратко остановит сервис и затем запустит его снова:

```bash
./scripts/backup.sh
```

Архивы попадают в `./backups/` и исключены из Git.

## Секреты и доступ

- Не коммитьте `data/hermes/.env`: там находятся токены Telegram, пароль почты и API-ключ модели.
- Оставляйте `TELEGRAM_ALLOWED_USERS` и `EMAIL_ALLOWED_USERS` включёнными.
- Используйте отдельный почтовый ящик агента, а не личную почту.
- Hermes получает доступ на запись только к своим данным и Obsidian vault, смонтированным в контейнер.
