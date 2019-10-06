# docker-accurev
Containerized AccuRev

You need to mount in a `aclicense.txt` to `/var/accurev/license`

For persistance you need to persist `/var/accurev/database` and `/var/accurev/storage`

You need to expose port `5050` for AccuRev server and optionally you can expose `1883` for mosquitto

```
docker build -t accurev .
```

```
docker run -d -v /accurev/license:/var/accurev/license -v /accurev/database:/var/accurev/database -v /accurev/storage:/var/accurev/storage -p 1883:1883 -p 5050:5050
```
