defmodule RecurringTask.GenServer do
  @moduledoc """
  RecurringTask is a small library that simpilfies
  how to define recurring tasks that you want to
  happen at a particular interval like polling,
  alerting, etc.

  Example usage:

      defmodule Poller do
        use RecurringTask.GenServer

        # do the task every 200ms
        @recur_period 200

        def task(state) do
          # do whatever it is that needs to happen
          # and return the new state
          SomeApi.poll(state.user_id)
        end
      end

  There's a few extra bits of functionality baked in, but that's it! `task` will be called every 200ms.

  In order to start the Recurring task, you can rig it up via a supervisor using a worker (it's a normal Genserver). It can
  be started with an initial state as well

  """

  @doc """
  an optional callback which you can use to
  define a function to return the period to
  wait before the next invocation of the task.

  You should most of the time use an @recur_period Module attribute,
  but should you need a dynamic recurring period based on the
  state of your GenServer, you can use this to change the period
  """
  @callback recur_period(any()) :: number()

  @doc """
  The actual task that will recur
  """
  @callback task(any()) :: any()

  @optional_callbacks recur_period: 1
  defmacro __using__(opts) do
    task_module = __CALLER__.module

    quote do
      use GenServer
      @behaviour RecurringTask

      @before_compile RecurringTask

      def start_link(state) do
        GenServer.start_link(__MODULE__, state)
      end

      def init(state) do
        Process.send_after(self(), :do_recurring_task, 50)
        {:ok, state}
      end

      def handle_info(:do_recurring_task, state) do
        schedule_task(state)
        {:noreply, task(state)}
      end

      defp schedule_task(state) do
        period = get_period(state)
        Process.send_after(self(), :do_recurring_task, period)
      end
    end
  end

  @doc """
  We perform some compile time checks to make sure
  that we have a recur_period defined either via a
  function or via a module attribute.
  """
  defmacro __before_compile__(env) do
    # Check for an @recur_period attribute
    recur_period_attr = Module.get_attribute(env.module, :recur_period)

    # check for an recur_period function definition
    has_period_function = Module.defines?(env.module, {:recur_period, 1})

    has_period_attribute = recur_period_attr != nil

    unless has_period_attribute or has_period_function do
      raise CompileError,
        description:
          "Recurring Task Server must define an @recur_period attribute, or implement the  callback recur_period(any())"
    end

    cond do
      has_period_attribute ->
        quote do
          def get_period(_state), do: unquote(recur_period_attr)
        end

      has_period_function ->
        quote do
          def get_period(state), do: recur_period(state)
        end
    end
  end
end
