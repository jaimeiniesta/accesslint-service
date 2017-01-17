# accesslint-service

A web service to check Accessibility on your sites using [accesslint-cli](https://github.com/accesslint/accesslint-cli.js)

## Dependencies

To set up this app on your machine you'll need to install:

* [Elixir](http://elixir-lang.org/install.html)
* [PhantomJS](http://phantomjs.org/)
* [accesslint-cli](https://www.npmjs.com/package/accesslint-cli)

## Starting the web service

`PORT=4000 mix trot.server`

## Usage

There is currently only one endpoint, `/check`, that accepts an `url` parameter and returns the results in JSON format,
for example:

`$ curl http://accesslint-service-demo.herokuapp.com/check?url=http://validationhell.com`

```json
{
    "url": "http://validationhell.com",
    "outcome": "ok",
    "violations": [
        {
            "url": "http://validationhell.com/",
            "nodes": [
                "body > .navbar.navbar-fixed-top > .navbar-inner > .container-fluid > .brand > img",
                "body > .container-fluid > .row-fluid > .span10 > .hero-unit > div > a:nth-of-type(1) > img"
            ],
            "impact": "critical",
            "help": "Images must have alternate text"
        },
        {
            "url": "http://validationhell.com/",
            "nodes": [
                "body > .container-fluid > .row-fluid > .span2 > .well.sidebar-nav > .nav.nav-list > a",
                "body > .container-fluid > .row-fluid > .span2 > .well.sidebar-nav > a",
                "#social > a",
                "body > .container-fluid > .row-fluid > .span10 > .hero-unit > div > a:nth-of-type(1)"
            ],
            "impact": "critical",
            "help": "Links must have discernible text"
        },
        {
            "url": "http://validationhell.com/",
            "nodes": [
                "body > .container-fluid > .row-fluid > .span2 > .well.sidebar-nav > .nav.nav-list"
            ],
            "impact": "serious",
            "help": "<ul> and <ol> must only directly contain <li>, <script> or <template> elements"
        }
    ]
}
```

Check out the value in the `outcome` attribute, when it's `ok` you'll also have the array of found `violations` to the A11Y rules.

This `outcome` could also be `error`, for example when an invalid URL was passed:

`curl http://accesslint-service-demo.herokuapp.com/check?url=nonsense`

```json
{
  "url": "nonsense",
  "errors": ["Invalid url"]
}
```

Or `crash` if there was an internal error (unfortunately, PhantomJS tends to crash from time to time).

## Heroku deployment

Add the buildpacks:

* https://github.com/HashNuke/heroku-buildpack-elixir.git
* heroku/nodejs
