defmodule PlanB.EventBus do
    use GenServer

    @moduledoc """
    ## Module EventBus

    This module is created as a GenServer. To use it just call start_link/1, then create a channel and register subscribers to it.
    """

    # Server side
    @spec init(any) :: {:ok, any}
    def init(state) do
        {:ok, state}
    end

    def handle_call({:lookup, name}, _from, state) when is_binary(name) do
        state
        |> Map.fetch(name)
        |> case do
            :error -> {:reply, :fail, state}
            {:ok, modules} ->
                results =
                    modules
                    |> Enum.map(fn (module) -> {module, Process.whereis(module) } end)

                {:reply, {name, results}, state}
        end
    end

    def handle_call({:register, {name, module}}, _from, state) do
        state
        |> Map.fetch(name)
        |> case do
            :error ->
                new_state = state |> Map.put(name, [ module ])
                {:reply, :ok, new_state}
            {:ok, modules} ->
                modules
                |> Enum.member?(module)
                |> case do
                    true -> {:reply, :ok, state}
                    false ->
                        new_state = state |> Map.put(name, modules ++ [module])
                        {:reply, :ok, new_state}
                end
        end
    end

    def handle_cast({:publish, name, payload}, state) do
        state
        |> Map.fetch(name)
        |> case do
            :error -> {:noreply, state}
            {:ok, modules} ->
                modules
                |> Enum.each(fn (module) -> GenServer.cast(module, payload) end)
                {:noreply, state}
        end
    end

    # Client side
    @doc """
    ### start_link/1

    #### Examples

    Example starting the EventBus with no registered modules
        iex>PlanB.EventBus.start_link([%{}])
        {:ok, #PID<0.210.0>}

    Example stating the EventBus with one channel and two registered modules
        iex>init_state = %{"channel_a" => [YourApplication.ServerA, YourApplication.ServerB]}
        %{"channel_a" => [YourApplication.ServerA, YourApplication.ServerB]}
        iex>PlanB.EventBus.start_link([init_state])
        {:ok, #PID<0.210.0>}

    Example stating the EventBus with two channel each with one registerd module
        iex>init_state = %{"channel_a" => [YourApplication.ServerA], "channel_b" => [YourApplication.ServerB]}
        %{
            "channel_a" => [YourApplication.ServerA],
            "channel_b" => [YourApplication.ServerB]
        }
        iex>PlanB.EventBus.start_link([init_state])
        {:ok, #PID<0.210.0>}

    """
    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link([state] = args) when is_list(args) and is_map(state) do
        GenServer.start_link __MODULE__, state, name: __MODULE__
    end

    @doc """
    ### stop_server/0
    Example stopping the EventBus gen server after staring it
        iex>PlanB.EventBus.stop_server
        :ok
    """
    @spec stop_server :: :ok
    def stop_server, do: GenServer.stop __MODULE__

    @doc """
    ### health_check/0
    Example for checking if the gen server is currently running
        iex>PlanB.EventBus.health_check
        :ok
        iex>PlanB.EventBus.health_check
        :fail
    """
    @spec health_check :: :fail | :ok
    def health_check do
        case GenServer.whereis(__MODULE__) do
            pid when is_pid(pid) -> :ok
            _ -> :fail
        end
    end

    @doc """
    ### register/2
    Example registering a gen server in the event bus.
    There are two params that needs passing in:
    - *name*: The name of the channel. If the channel is already created, than add the module to that channel, otherwise create a new channel.
    - *module*: Pass in the module. Make sure the gen server of the module was started and registered under the module name.

    Example:
        iex>fake_server = GenServer.start_link(MyApp.MyModule, %{}, name: MyApp.MyModule)
        {:ok, #PID<0.210.0>}
        iex>PlanB.EventBus.register("channel_name", MyApp.MyModule)
        :ok
    """
    @spec register(binary, Module) :: any
    def register(name, module), do: GenServer.call __MODULE__, {:register, {name, module}}

    @doc """
    ### lookup/1
    Example calling lookup function to retrieve the registered channel.
        iex>PlanB.EventBus.lookup("my_example_channel")
        {"my_example_channel", [{YourApplication.ServerA, #PID<0.210.0>}]}
    Example calling lookup if the GenServer process that is registered in the channel is not alive.
        iex>PlanB.EventBus.lookup("my_example_channel")
        {"my_example_channel", [{YourApplication.ServerA, nil}]}
    """
    @spec lookup(binary) :: any
    def lookup(name) when is_binary(name), do: GenServer.call __MODULE__, {:lookup, name}

    @doc """
    ### publish/2
    Example publishing an event over the channel. The message is published async over the channel, so do not expect any return message.
        iex>PlanB.EventBus.publish("my_example_channel", {:count, 100})
        :ok
    """
    @spec publish(binary, any) :: any
    def publish(name, payload) when is_binary(name), do: GenServer.cast __MODULE__, {:publish, name, payload}
end
