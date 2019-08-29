# Configuration Providers

If you do not wish to add your credentials on every single API call, you should use a configuration provider.

Configuration providers are modules that expose only one function: `load/0`.
This function must return either an instance of the struct `Kitsune.Aws.Config` or `nil`.

To initialize the configuration, you must call the `Kitsune.Aws.Config.load/1` function,
which will load the configuration from every provider passed as parameter.

For example, if you wish to load configuration only from environment variables,
there is a provider, `Kitsune.Aws.ConfigProvider.Environment`, that will load the credentials from that store.
This provider must then be passed as the only provider to the `Kitsune.Aws.Config.load/1` function:

    iex> config = Kitsune.Aws.Config.load([Kitsune.Aws.ConfigProvider.Environment])
    %Kitsune.Aws.Config{}

## Multiple providers

If you inform several providers, the last one will take precedence over the others:

    iex> env_config = Kitsune.Aws.Config.load([Kitsune.Aws.ConfigProvider.Environment])
    %Kitsune.Aws.Config{secret_key: "a"}

    iex> app_config = Kitsune.Aws.Config.load([Kitsune.Aws.ConfigProvider.ApplicationConfig])
    %Kitsune.Aws.Config{secret_key: "b"}

    # Passing no parameters we use the default providers,
    # having environment taking precedence over application config
    iex> config = Kitsune.Aws.Config.load()
    %Kitsune.Aws.Config{secret_key: "a"}

## Default configuration providers

The default configuration providers are, in order of precedence:

1. `Kitsune.Aws.ConfigProvider.Environment` - Provides configuration from environment variables
2. `Kitsune.Aws.ConfigProvider.ApplicationConfig` - Provides configuration from `Config` values

The default providers list can be retrieved by calling the
`Kitsune.Aws.Config.get_default_providers/0` function
