# kong-plugin-xml-json-transformer

An experimental XML to JSON transformer plugin for Kong.

## Develop

Start Kong instance along with the plugin.

```sh
$ docker compose up
```

This will launch:

- A nginx instance with `./nginx-www` mounted to `/usr/share/nginx/html`. We will use this as test upstream for Kong.
- A Kong instance in dbless mode. The configuration is loaded from `kong/kong.yml`.
- The declarative configuration setup a single service for testing.

Test the route to see if the plugin is working properly. We are expecting response in JSON format.

```sh
$ curl --silent http://localhost:8000/medium.xml | jq
```

Expected output

```json
{
  "slideshow": {
    "_attr": {
      "date": "Date of publication",
      "author": "Yours Truly",
      "title": "Sample Slide Show"
    },
    "slide": [
      {
        "_attr": {
          "type": "all"
        },
        "title": "Wake up to WonderWidgets!"
      },
      {
        "_attr": {
          "type": "all"
        },
        "item": [
          {
            "1": "Why",
            "2": "are great",
            "em": "WonderWidgets"
          },
          {},
          {
            "1": "Who",
            "2": "WonderWidgets",
            "em": "buys"
          }
        ],
        "title": "Overview"
      }
    ]
  }
}
```

## License

[MIT](./LICENSE)
