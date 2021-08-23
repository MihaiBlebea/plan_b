defmodule PlanB.Mock.ServerB do
    use GenServer

    @letters "abcdefghijklmnopqrstuvwxyz"

    # Server side
    @spec init(map) :: {:ok, any}
    def init(%{counter: _count} = state) do
        {:ok, state}
    end

    def handle_call(:current, _from, %{counter: count} = state) do
        {:reply, get_letter(count), state}
    end

    def handle_call(:count, _from, %{counter: count}) do
        letter = get_letter(count)
        new_state = %{counter: count + 1}
        {:reply, letter, new_state}
    end

    def handle_call(:restart, _from, _state) do
        {:reply, :ok, %{counter: 0}}
    end

    def handle_cast(:count, %{counter: count}) do
        new_state = %{counter: count + 1}
        {:noreply, new_state}
    end

    defp get_letter(index) when is_integer(index) do
        (index > String.length(@letters))
        |> case do
            true -> get_letter(index - String.length(@letters))
            _ -> @letters |> String.split("", trim: true) |> Enum.at(index, nil)
        end
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

    @spec count :: binary
    def count, do: GenServer.call __MODULE__, :count

    @spec restart :: any
    def restart, do: GenServer.call __MODULE__, :restart

    @spec current :: binary
    def current, do: GenServer.call __MODULE__, :current
end
