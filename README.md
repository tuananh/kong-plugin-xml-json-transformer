# kong-plugin-xml-json-transformer

An experimental XML to JSON transformer plugin for Kong.

## Develop

Build a test Docker container with

```sh
$ docker build -t kong:local .
```

Start Kong instance along with the plugin.

```sh
$ ./hack/start-kong.sh
```

What this script does is:

- Start a nginx instance with single `test.xml` file, mounted to `/usr/share/nginx/html/test.xml`. We will use this as test upstream for Kong. 
- Start a Kong instance in dbless mode. The configuration is loaded from `test-conf/kong.yml`.
- The declarative configuration setup a single service for testing.

Test the route to see if the plugin is working properly. We are expecting response in JSON format.

```sh
curl http://localhost:8000/test.xml | jq
```

Expected output

```json
{
  "slideshow": [
    {
      "_attr": {
        "title": "Sample Slide Show",
        "author": "Yours Truly",
        "date": "Date of publication"
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
    },
    {
      "_attr": {
        "title": "Sample Slide Show",
        "author": "Yours Truly",
        "date": "Date of publication"
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
  ]
}
```

## License

[MIT](./LICENSE)
