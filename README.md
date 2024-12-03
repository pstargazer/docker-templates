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
- [ ] laravel container
	- [ ] first startup checks
		- [ ] composer check
		- [ ] composer install/update
		- [ ] run migrations if db is empty (optional)
	- [ ] startup checks (`composer test` || `php artisan test`)
	- [ ] test and debug production mode
- [ ] Yii container
	- [ ] ???