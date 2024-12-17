# Template dockerfile repo
this repo - just a little suitcase with dockerfiles to keep the best practicies of mine projects in one place

## TODO:
- [x] postgres container
	- [x] cloning DB into testing variant
	- [ ] autodump if env var is set (optional)
- [ ] mysql container
	- [ ] basic init
	- [ ] cloning into testing DB
	- [ ] autodump if env var is set (optional)
- [x] laravel container
	- [ ] first startup checks
		- [x] composer check
		- [x] composer install/update
		- [ ] run migrations if db is empty (optional)
	- [x] startup checks (`composer test` || `php artisan test`)
	- [ ] test and debug production mode
- [ ] Yii container
	- [ ] ???


### Basic init
Basic init consists of few several parts:
0. make sure YOU:
    - activated frontend module (if you have one)
    - had set submodules and remotes urls at .gitmodules and .gitconfig
1. make the git read your custom `.gitconfig`
2. sync submodules
3. get submodules code
```
git config --local include.path "$PWD/.gitconfig"
git submodules sync
git pull
```
