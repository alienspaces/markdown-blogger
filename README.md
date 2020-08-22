# Markdown Blogger

Write and publish posts to multiple social networking platforms using markdown only.

## Support

Currently supports the following social networking platforms:

* Wordpress

## How

* Clone this repository
* Add `./articles`
* Export some environment variables
* Use the CLI to publish.

### Articles

By default articles are located in their own directory inside an `articles` directory:

```bash
./articles
./articles/20200814/
./articles/20200814/article-title.md
./articles/20200814/article-image.jpeg
./articles/20200821/
./articles/20200821/article-title.md
./articles/20200821/article-image.jpeg
```

### Environment Variables

Environment variables are used for configuration making it easy to implement automated publishing with CI pipelines and it keeps all configuration in the one place.

The following environment variables are required for publishing to Wordpress:

```bash
# Wordpress - https://developer.wordpress.com/appsWrite and publish posts to multiple social networking platforms using markdown only.
export WORDPRESS_SITE=https://yoursite.com
export WORDPRESS_CLIENT_ID=YOURNUMERICCLIENTID
export WORDPRESS_CLIENT_SECRET=YourAlphaNumericClientSecret
export WORDPRESS_USERNAME=youraccountusernameWrite and publish posts to multiple social networking platforms using markdown only.
export WORDPRESS_PASSWORD=youraccountpassword
```

The following environment variables are required for publishing to Instagram:

```bash
# Instagram -
export INSTAGRAM=
export INSTAGRAM=
export INSTAGRAM=
export INSTAGRAM=
export INSTAGRAM=
```

### CLI

To publish articles manually or via your CI pipeline:

* Install Dart [https://dart.dev/get-dart](https://dart.dev/get-dart)
* Create a `.env` file with your configuration
* Use scripts in the `./tool` directory

```bash
# Publish all articles
./tool/publish
```

## Why

I wanted to learn:

* The [Dart](https://dart.dev/guides) programming language
* The origins and creative process behind monsters in games

So how about I write about and [publish](https://monsterweekly.com) my monster investigations using a tool I built with [Dart](https://dart.dev/guides).
