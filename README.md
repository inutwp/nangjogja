# NangJogja
Semuanya Tentang Jogja

# Container
```
nangjogja : Laravel 7 | Nginx Alpine | PHP7.4:fpm | Traefik
```

# How to use?
Clone this repository.
```
git clone git@gitlab.com:inudev/nangjogja.git
```
Make sure you have been install docker and docker-compose. Then run this command.
```
docker-compose up -d --build --remove-orphans
```
Install dependencies
```
docker-compose exec app composer install
```
