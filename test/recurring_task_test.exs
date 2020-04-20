defmodule RecurringTask.GenServerTest do
  use ExUnit.Case
  doctest RecurringTask.GenServer

  defmodule RecurringTaskTest.ModuleAttributeExample do
    use RecurringTask.GenServer

    # make it high enough so that we can tell the difference
    # between the first call and the next call
    @recur_period 200

    def task(state) do
      %{calls: state.calls + 1}
    end

    def get_state(task) do
      GenServer.call(task, :get_state)
    end

    def handle_call(:get_state, _from, state) do
      {:reply, state, state}
    end
  end

  defmodule RecurringTaskTest.FunctionExample do
    use RecurringTask.GenServer

    # make it high enough so that we can tell the difference
    # between the first call and the next call
    def recur_period(_state) do
      300
    end

    def task(state) do
      %{calls: state.calls + 1}
    end

    def get_state(task) do
      GenServer.call(task, :get_state)
    end

    def handle_call(:get_state, _from, state) do
      {:reply, state, state}
    end
  end

  setup do
    module_task = start_supervised!({RecurringTaskTest.ModuleAttributeExample, %{calls: 0}})
    function_task = start_supervised!({RecurringTaskTest.FunctionExample, %{calls: 0}})
    %{module_task: module_task, function_task: function_task}
  end

  describe "recur_period as a module attribute" do
    test "ensure the gen server is started", %{module_task: module_task} do
      assert Process.alive?(module_task)
    end

    test "ensure the module_task gets called initially after being started (50ms)", %{
      module_task: module_task
    } do
      :timer.sleep(60)
      assert %{calls: 1} = RecurringTaskTest.ModuleAttributeExample.get_state(module_task)
    end

    test "ensure the module_task gets scheduled after the initial call (see recur_period value)",
         %{module_task: module_task} do
      :timer.sleep(260)
      assert %{calls: 2} = RecurringTaskTest.ModuleAttributeExample.get_state(module_task)
    end
  end

  describe "recur_period as a function" do
    test "ensure the module_task gets called initially after being started (50ms)", %{
      function_task: function_task
    } do
      :timer.sleep(60)
      assert %{calls: 1} = RecurringTaskTest.FunctionExample.get_state(function_task)
    end

    test "ensure the module_task gets scheduled after the initial call (see recur_period value)",
         %{function_task: function_task} do
      :timer.sleep(400)
      assert %{calls: 2} = RecurringTaskTest.FunctionExample.get_state(function_task)
    end
  end

  test "missing recur_period throws an error" do
    definition =
      quote do
        use RecurringTask.GenServer

        def task(state) do
          "should not pass"
        end
      end

    assert_raise CompileError, fn ->
      Module.create(MissingRecurPeriod, definition, file: "test.ex")
    end
  end
end
