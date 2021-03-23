# Markdown Blogger

Write and publish posts to blogging platforms using markdown only.

## Support

Currently supports the following blogging platforms:

* Wordpress

_I should probably just call this wordpress-markdown-blogger..._

## How

* Fork this repository.
* Install dependencies.
  * `dart pub get`
* Create an `./articles` directory with some content.
  * See [Articles](#articles) below.
* Configure the environment.
  * See [Configuration](#configuration) below
* Use the [CLI](#cli) to publish.
  * `./script/publish`

### Articles

Articles should be placed in their own directory inside an `./articles` directory:

```bash
./articles
./articles/20200814/
./articles/20200814/the-final-frontier.md
./articles/20200814/featured.jpeg
./articles/20200814/enterprise.jpeg
./articles/20200821/
./articles/20200821/from-beyond.md
./articles/20200821/featured.jpeg
./articles/20200821/alien.jpeg
```

(__See the provided example articles in the repository__)

* There should be only one `.md` file per directory.
* A `<h1>` tag found on the first row after HTML conversion will be used as the article title. If not found then the `.md` file name will be used as the article title.
  * `# This is a title`
* The first `<blockquote>` or `<p>` element will be used as the article excerpt.
  * `> This will be used as the excerpt`
* If an image with a name of `featured` exists in the article directory it will be used as the articles "featured image" appearing at the top of the article.
* A `.meta` file will be created automatically in each article directory to track changes. If you delete this file new posts will be created.

### Configuration

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
* Use scripts in the `./scripts` directory

```bash
# Publish new and update all articles
./script/publish
# Delete all articles
./script/delete
```

### Tools

#### Banner

Create a `featured.png` image from an existing banner image.

```bash
$ ./script/banner --banner flutter --text 'Unit testing in Flutter'
INFO: 2021-03-21 21:25:59.050215: main: Created ./articles/2021-03-21/featured.png
```

## Why

As a developer:

* I wanted to learn the [Dart](https://dart.dev/guides) programming language
* Make blogging to Wordpress in a format I can deal with easier

## Epilogue

I do not need Wordpress, specifically the cost, so I am subsequently moving [https://alienspaces.com](https://alienspaces.com) to another location, more than likely a github page.

So while the code in this repository is functional, it is no longer maintained, sorry!
