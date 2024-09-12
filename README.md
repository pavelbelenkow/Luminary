# Luminary

# Назначение и цели приложения

iOS-приложение для поиска фотографий, которое состоит из двух экранов:

- Экран поиска медиа-контента
- Экран с детальной информацией, который отображается после нажатия на элемент из результатов поиска

Приложение предназначено для просмотра карточек с фотографиями из Unsplash API.

Цели приложения:

- Поиск и просмотр карточек с фотографиями
- Просмотр более подробной информации о выбранной карточке

# Запуск приложения

## Требования

- iOS 14.0 или позднее
- Xcode 14.0 или позднее
- Интернет-соединение
- Аккаунт разработчика на https://unsplash.com/developers

## Установка

1) Возможны несколько вариантов установки проекта:
- Склонировать репозиторий на свой компьютер https://github.com/pavelbelenkow/Luminary.git
- Воспользоваться кнопкой "Open with Xcode" в репозитории
- Скачать ZIP архив и распаковать его на компьютере
2) Откройте проект в Xcode

## Запуск

1) Откройте файл Luminary.xcodeproj в Xcode
2) В проекте откройте разверните папку Helpers и откройте файл Const
3) В файле Const замените значение для переменной accessKey вашим ключем, полученным после регистрации приложения на https://unsplash.com/developers
4) Выберите целевое устройство (симулятор или реальное устройство)
5) Нажмите кнопку "Start" или воспользуйтесь hotkey "cmd + R" в Xcode

## Примеры использования

### Экран поиска

1) Введите поисковый запрос в поле поиска
2) Нажмите кнопку "Поиск" на клавиатуре
3) Результаты поиска будут отображены в виде плиток на экране
4) В левом верхнем углу навигационного бара есть кнопка для сортировки контента по популярности и дате размещения
5) В правом верхнем углу навигационного бара есть кнопка для применения фильтра по формату отображения контента (2 плиточки в ряд или одна большая)
6) При скролле коллекции есть пагинация

### Экран с детальной информацией

1) Нажмите на элемент поисковой выдачи, чтобы открыть экран с детальной информацией
2) На этом экране будет отображена детальная информация о выбранном фото: сама фотография, описание, автор, кнопки для скачивания и поделиться фото в соц сетях
