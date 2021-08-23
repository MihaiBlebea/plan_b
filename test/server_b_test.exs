defmodule ServerBTest do
    use ExUnit.Case

    alias PlanB.Mock.ServerB

    setup do
        ServerB.start_link %{}

        :ok
    end

    test "get the correct letter when calling the ServerB count method", _ do
        assert ServerB.count == "a"
        assert ServerB.count == "b"
        assert ServerB.count == "c"
        assert ServerB.count == "d"
        assert ServerB.count == "e"
    end
end
