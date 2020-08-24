# Markdown Blogger

Write and publish posts to blogging platforms using markdown only.

## Support

Currently supports the following blogging platforms:

* Wordpress

## How

* Clone this repository
* Add `./articles`
* Export some environment variables
* Use the CLI to publish.

### Articles

Articles should be placed in their own directory inside an `articles` directory:

```bash
./articles
./articles/20200814/
./articles/20200814/the-final-frontier.md
./articles/20200814/enterprise.jpeg
./articles/20200821/
./articles/20200821/from-beyond.md
./articles/20200821/alien.jpeg
```

* There should be only one `.md` file per directory.
* The first `<h1>` tag found after HTML conversion will be used as the article title. If no heading tag can be found then the `.md` file name will be used as the article title.
* A `.meta` file will be created automatically in each article directory to track changes. If you delete this file new posts will be created.

### Environment Variables

Environment variables are used for configuration making it easy to implement automated publishing with CI pipelines and it keeps all configuration in the one place.

The following environment variables are required for publishing to Wordpress:

```bash
# Wordpress - https://developer.wordpress.com/apps
export WORDPRESS_SITE=https://yoursite.com
export WORDPRESS_CLIENT_ID=YOURNUMERICCLIENTID
export WORDPRESS_CLIENT_SECRET=YourAlphaNumericClientSecret
export WORDPRESS_USERNAME=youraccountusername
export WORDPRESS_PASSWORD=youraccountpassword
```

### CLI

To publish articles manually or via your CI pipeline:

* Install Dart [https://dart.dev/get-dart](https://dart.dev/get-dart)
* Create a `.env` file with your configuration
* Use scripts in the `./tool` directory

```bash
# Publish new and update all articles
./tool/publish
# Delete all articles
./tool/delete
```

## Why

I wanted to learn:

* The [Dart](https://dart.dev/guides) programming language
* The origins and creative process behind monsters in games

So how about I write regular articles about monsters and then [publish](https://monsterweekly.com) those articles using a tool I built with [Dart](https://dart.dev/guides).
