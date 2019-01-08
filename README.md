# RecurringTask

RecurringTask is a small library that simpilfies how to define recurring tasks that you want to happen at a particular interval like polling, alerting, etc.

Example usage:

```elixir
    defmodule Poller do
      use RecurringTask.GenServer

      # do the task every 200ms
      @recur_period 200

      def task(state) do
        # do whatever it is that needs to happen
        # and return the new state
      end
    end
```

There's a few extra bits of functionality baked in, but it is a small but useful wrapper around GenServer. Check the module docs for more information


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `recurring_task` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:recurring_task, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/recurring_task](https://hexdocs.pm/recurring_task).

