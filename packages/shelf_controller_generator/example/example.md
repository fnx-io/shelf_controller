# Example

Add the generator to `dev_dependencies` together with `build_runner` and
`json_serializable`, then configure the spec in `build.yaml`:

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          field_rename: snake
      shelf_controller_generator:
        options:
          info:
            title: Projects API
            version: 1.0.0
          servers:
            - url: https://api.example.com
          securitySchemes:
            bearer: { type: http, scheme: bearer }
          security: [ { bearer: [] } ]
```

Run the build:

```sh
dart run build_runner build
```

For every `@Controller` class it generates a router into the library's
`.g.dart` part, and it writes `openapi.yaml` describing all operations.

See the
[example application](https://github.com/fnx-io/shelf_controller/tree/master/example)
and its generated
[openapi.yaml](https://github.com/fnx-io/shelf_controller/blob/master/example/openapi.yaml).
