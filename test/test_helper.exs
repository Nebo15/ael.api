ExUnit.start()
{:ok, _} = Plug.Adapters.Cowboy.http Ael.MockServer, [], port: Confex.fetch_env!(:ael_api, :mock)[:port]
