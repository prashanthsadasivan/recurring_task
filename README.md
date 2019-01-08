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

There's a few extra bits of functionality baked in, but that's it! `task` will be called every 200ms.

In order to start the Recurring task, you can rig it up via a supervisor using a worker (it's a normal Genserver). It can
be started with an initial state as well

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

