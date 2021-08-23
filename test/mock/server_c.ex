defmodule PlanB.Mock.ServerC do
    use GenServer

    alias PlanB.Mock.ServerA
    alias PlanB.Mock.ServerB

    # Server side
    @spec init(map()) :: {:ok, any}
    def init(state) do
        {:ok, state}
    end

    def handle_call(:request, _from, state) do
        count = case ServerA.health_check do
            :fail -> 0
            :ok -> ServerA.count
        end

        letter = case ServerB.health_check do
            :fail -> ""
            :ok -> ServerB.count
        end

        {:reply, "The current count is " <> Integer.to_string(count) <> letter, state}
    end

    def handle_cast(_request, state) do
        {:noreply, state}
    end

    # Client side
    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(_) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    @spec say_it :: binary()
    def say_it, do: GenServer.call(__MODULE__, :request)
end
