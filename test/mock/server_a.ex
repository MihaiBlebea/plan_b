defmodule PlanB.Mock.ServerA do
    use GenServer

    # Server side
    @spec init(map) :: {:ok, any}
    def init(%{counter: _count} = state) do
        {:ok, state}
    end

    def handle_call(:current, _from, %{counter: count} = state) do
        {:reply, count, state}
    end

    def handle_call(:count, _from, %{counter: count}) do
        new_state = %{counter: count + 1}
        {:reply, new_state.counter, new_state}
    end

    def handle_call(:restart, _from, _state) do
        {:reply, :ok, %{counter: 0}}
    end

    def handle_cast(:count, %{counter: count}) do
        new_state = %{counter: count + 1}
        {:noreply, new_state}
    end

    # Client side
    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(_) do
        GenServer.start_link(__MODULE__, %{counter: 0}, name: __MODULE__)
    end

    @spec stop_server :: :ok
    def stop_server, do: GenServer.stop(__MODULE__)

    @spec health_check :: :fail | :ok
    def health_check do
        case GenServer.whereis(__MODULE__) do
            pid when is_pid(pid) -> :ok
            _ -> :fail
        end
    end

    @spec count :: integer()
    def count, do: GenServer.call __MODULE__, :count

    @spec restart :: any
    def restart, do: GenServer.call __MODULE__, :restart

    @spec current :: integer
    def current, do: GenServer.call __MODULE__, :current
end
