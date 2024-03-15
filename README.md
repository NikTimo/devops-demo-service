
# Описание

Тестовое задание на должность стажера DevOps. Выполнил Николай Т.
Выполнены следующие задания:
1. Подготовлен Compose для сборки и запуска сервиса с базой данных.

2. 

3. Первое задание выполненно с усложнением в виде контейнера с шлюзом nginx, реализовано создание SuperUser при запуске Compose.


## Запуск сервиса
1. Для запуска сервиса необходимо создать в корневой папке проекта файл .env с переменными окржуения. Ниже представлен пример содержимого файла.
```
# Database Variables
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
DB_HOST=db
DB_PORT=5432

# Django SuperUser Variables
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@admin.ru
DJANGO_SUPERUSER_PASSWORD=123
```
2. Запуск compose `docker compose up --build`

3. После запуска панель администратора достпуна по адресу [http://localhost:9999/admin/](http://localhost:9999/admin/)


## Особенности, заменчания и изменения в исходных файлах
1. Для контроля базы данных в контейнере применен скрипт [Wait-for-it.sh](https://github.com/vishnubob/wait-for-it). Стандартные средства depends_on не обепечивают контроля запуска содержимого контенейра, а не смаого контейнера, таким образом возможна ситуация, когда контейнера уже запущен, а база данных в нем - нет. Скрипт контролирует возможность соединения с базой данных по заданным хосту и порту. Актуально при первом запуске, инициализации базы.

2. Согласно усложнению добавлена команда в стартовый скрипт для создания SuperUser с параметрами из переменных окружения: `python manage.py createsuperuser --noinput --username $DJANGO_SUPERUSER_USERNAME --email $DJANGO_SUPERUSER_EMAIL`.
С моей точки зрения, не самая лучшая практика: это действие требуется один раз при инициализации проекта и базы данных, в последующих развертываниях будет вызывать ошибку `CommandError: Error: That username is already taken.`. Правильнее будет единожды, в ручном режиме, передать в контейнер с Django команду на создание SuperUser.

3. Старался миинимально затрагивать исходные файлы проекта, поэтому, к примеру, скрипты передаются через volume в compose.

4. В головной файл urls.py добавлен путь для статики админ-панели Django.

5. В Dockerfile преобразовал установку зависимостей в одну команду, т.к. при повторном вызове pip install не добавляет исполнительный файл gunicorn в $PKGS_DIR/bin. Использование опции --upgrade приводит к перезаписи папки $PKGS_DIR/bin и удалению исполняемых файлов от установки зависимостей.

Было:
```
# Install dependencies to local folder
RUN pip install --target=$PKGS_DIR -r ./requirements.txt
RUN pip install --target=$PKGS_DIR gunicorn
```
Стало:
```
# Install dependencies to local folder
RUN pip install --target=$PKGS_DIR -r ./requirements.txt gunicorn
```