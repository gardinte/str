import Config

config :str, wait_base: 4

import_config "#{Mix.env()}.exs"
