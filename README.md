# tnqrokgh: UniXNU на Xiaomi Pad 6S Pro

Этот репозиторий собирает [UniXNU](https://github.com/UniXNU/UniXNU) для
**Xiaomi Pad 6S Pro 12.4** (кодовое имя `sheng`, чип Snapdragon 8 Gen 2 / SM8550).
UniXNU — это UEFI-загрузчик и набор драйверов, который запускает ядро Apple XNU,
а вместе с ним iPadOS или macOS, на ARM64-устройствах, сделанных не Apple.

> ⚠️ **Перед началом.** Проект экспериментальный. На `sheng` сейчас лучше всего
> работает **iPadOS 27**. Профиль **macOS 27.3** тоже есть, но графический рабочий
> стол macOS на этом планшете пока не готов: по записям сообщества WindowServer
> падает при запуске. Настоящий «MacBook» из планшета пока не получится, но
> собрать и попробовать можно.
>
> Для загрузки нужно **разблокировать загрузчик** Xiaomi. При разблокировке
> **стираются все данные** на планшете. Всё дальнейшее вы делаете на свой риск.

## Что внутри

| Путь | Что это |
| --- | --- |
| `UniXNU/` | Основной проект: сборщик `unixnu`, загрузчик, профили ОС, документация (`UniXNU/docs`) |
| `UniXNU-sheng/` | Поддержка конкретно Xiaomi Pad 6S Pro: драйверы, дерево устройств, `board.toml` |
| `uefi-sheng/` | UEFI-прошивка (Mu-Silicium) для этого планшета |
| `.github/workflows/build-sheng.yml` | Сборка образов в GitHub Actions на macOS, свой Mac не нужен |
| `scripts/update-unixnu.sh` | Обновляет все три компонента до совместимых версий |

Все три компонента подключены как git-подмодули. Клонировать репозиторий нужно так:

```sh
git clone --recurse-submodules https://github.com/crystalzumpanel/tnqrokgh.git
```

## Шаг 1. Сделайте репозиторий приватным

Готовые образы содержат уникальный ключ вашего планшета. Откройте
GitHub → **Settings → General → Danger Zone → Change visibility → Private**.

## Шаг 2. Добавьте ключ планшета

В образ «зашивается» платформенный ключ устройства: 8 шестнадцатеричных цифр,
например `0a1b2c3d`. Документация UniXNU не объясняет, как его получить. Узнайте
это в [issues UniXNU](https://github.com/UniXNU/UniXNU/issues) или в сообществе
`sheng` и **никому его не показывайте**.

GitHub → **Settings → Secrets and variables → Actions → New repository secret**:

- Name: `UNIXNU_UNIQUE_CHIP_ID`
- Secret: ваши 8 hex-цифр

## Шаг 3. Соберите образы в GitHub

1. Откройте вкладку **Actions** → **build-sheng** → **Run workflow**.
2. Выберите `os`:
   - `27` — iPadOS 27, рекомендуется;
   - `macos-27.3-26C5035r` — macOS, экспериментально.
3. При **первой** установке iPadOS 27 включите `init_data`.
4. Подождите: сборка может занять несколько часов, лимит задачи 6 часов.
5. Скачайте артефакт `images-…`. Сохраните и `installation-seed-…`, если он есть:
   в нём ваши данные для следующих сборок.
6. **Удалите запуск** (⋯ → Delete workflow run). Артефакты в любом случае
   удаляются через 1 день.

В артефакте лежат `boot/boot.img`, `payload/payload.img`, `kernel/kernel.macho`
и `package.manifest.json`.

## Шаг 4. Загрузите планшет

Для этого нужен компьютер (Windows, macOS или Linux) с
[Android platform-tools](https://developer.android.com/tools/releases/platform-tools)
(`fastboot`) и USB-кабель.

1. Разблокируйте загрузчик официальным способом Xiaomi (Mi Unlock).
2. Выключите планшет. Зажмите **громкость вниз + питание**, чтобы войти в режим fastboot.
3. Подключите планшет к компьютеру и проверьте, что он виден:
   ```sh
   fastboot devices
   ```
4. **Пробный запуск без прошивки.** Образ загружается в память один раз,
   Android на планшете остаётся:
   ```sh
   fastboot boot boot.img
   ```
5. Появится меню UniXNU: оно управляется клавишами ↑/↓ и Enter, удобнее всего с клавиатурой-обложкой. Если ничего не нажимать, через несколько секунд загрузится пункт по умолчанию.

Чтобы вернуться в Android, перезагрузите планшет (долгое нажатие питания).
Если планшет завис, снова войдите в fastboot: громкость вниз + питание.

Скрипт `UniXNU-sheng/scripts/build-flash-image.sh` готовит образ для постоянной
прошивки в слот `boot_b`. Делайте это, только когда пробный запуск уже работает.

## Сборка на своём компьютере (необязательно)

Подробно это описано в `UniXNU/docs/building.md` и `UniXNU/docs/guide/requirements.md`.
Коротко, на Mac с Xcode:

```sh
brew install dtc llvm lld cmake mtools ninja blacktop/tap/ipsw
cd UniXNU-sheng
UNIXNU_UNIQUE_CHIP_ID=<8 hex> scripts/package.sh --os 27 --uefi ../uefi-sheng
```

На Linux сначала соберите тулчейн командой `sudo UniXNU/scripts/linux/setup-toolchain.py`.
Некоторые шаги всё равно требуют macOS.

## Обновление

```sh
scripts/update-unixnu.sh
git commit -am "Update UniXNU" && git push
```

## Ссылки

- Документация: `UniXNU/docs` (сайт unixnu.com)
- Страница планшета: `UniXNU/docs/devices/sheng.md`
- macOS на sheng: `UniXNU/docs/devices/sheng-macos.md`
- Лицензии: UniXNU — BSD-2-Clause-Patent, uefi-sheng — BSD-2-Clause и GPLv2 (драйверы в папках `GPL*`)
