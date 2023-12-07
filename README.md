# kong-plugin-xml-json-transformer

An experimental XML to JSON (and vice-versa) transformer plugin for Kong.

This repo include 2 plugins:

- `xml-json-transformer` at `./kong/plugins/xml-json-transformer`
- `json-xml-transformer` at `./kong/plugins/json-xml-transformer`

## Testing

Start Kong instance along with the plugin.

```sh
$ docker compose up
```

This will launch:

- A nginx instance with `./nginx-www` mounted to `/usr/share/nginx/html`. We will use this as test upstream for Kong.
- A Kong instance in dbless mode. The configuration is loaded from `kong/kong.yml`.
- The declarative configuration setup a single service for testing.

Test the route to see if the plugin is working properly. For example, let's try XML to JSON trasnformer

```sh
$ curl --silent http://localhost:8000/xml/medium.xml | jq
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

Or XML to JSON transformer:

```sh
$ curl --silent http://localhost:8000/json/medium.json
```

Expected output in XML

```xml
<slideshow date="Date of publication" title="Sample Slide Show" author="Yours Truly">
  <slide>
    <slide type="all">
      <title>Wake up to WonderWidgets!</title>
    </slide>
    <slide type="all">
        <item>
          <item>
            <2>are great</2>
            <1>Why</1>
            <em>WonderWidgets</em>
          </item>
          <item>

          </item>
          <item>
            <2>WonderWidgets</2>
            <1>Who</1>
            <em>buys</em>
          </item>
        </item>
        <title>Overview</title>
    </slide>
  </slide>
</slideshow>
```

## License

[MIT](./LICENSE)
