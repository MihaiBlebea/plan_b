defmodule EventBusTest do
    use ExUnit.Case

    alias PlanB.EventBus
    alias PlanB.Mock.ServerA
    alias PlanB.Mock.ServerB
    alias PlanB.Mock.ServerC

    setup do
        ServerA.start_link %{}
        ServerB.start_link %{}
        ServerC.start_link %{}
        EventBus.start_link [%{}]

        EventBus.register "server_a", ServerA
        EventBus.register "server_b", ServerB
    end

    test "get server_a and pid when calling lookup for 'server_a'" do
        {name, [{module, pid} | _tail ]} = EventBus.lookup("server_a")

        assert name == "server_a"
        assert pid |> is_pid == true
        assert module |> is_atom == true
    end

    test "can try to register same module in the channel but will not add duplicates" do
        EventBus.register "server_a", ServerA
        {_name, modules} = EventBus.lookup("server_a")

        assert length(modules) == 1
    end

    test "get server_b and pid when calling lookup for 'server_b'" do
        {name, [{module, pid} | _tail ]} = EventBus.lookup "server_b"

        assert name == "server_b"
        assert pid |> is_pid == true
        assert module |> is_atom == true
    end

    test "get incremented count when using the EventBus to call server_a" do
        EventBus.publish "server_a", :count
        :timer.sleep 500

        assert ServerA.current == 1
    end

    test "get next letter in line when using the EventBus to call server_b" do
        EventBus.publish "server_b", :count
        :timer.sleep 500

        assert ServerB.current == "b"
    end

    test "get incremeted results for both servers when both are registered on the same channel" do
        EventBus.register "fake_channel", ServerA
        EventBus.register "fake_channel", ServerB

        EventBus.publish "fake_channel", :count
        :timer.sleep 500

        assert ServerA.current == 1
        assert ServerB.current == "b"
    end
end
