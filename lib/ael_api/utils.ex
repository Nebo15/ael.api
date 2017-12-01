defmodule Ael.Utils do
  @moduledoc false

  def get_from_registry(key) do
    [{_pid, val}] = Registry.lookup(Ael.Registry, key)
    val
  end
end
