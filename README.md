# NangJogja
Semuanya Tentang Jogja

# Container
```
nangjogja : Laravel 7
```
```
nangjogja-nginx : nginx:stable-alpine
```
```
nangjogja-db : mysql:5.7  
```

# How to use?
Clone this repository.
```
git clone git@gitlab.com:inudev/nangjogja.git
```
Make sure you have been install docker and docker-compose. Then run this command.
```
docker-compose up -d --build
```
Install dependencies
```
docker-compose run php-fpm composer update
```
