defmodule ServerATest do
    use ExUnit.Case

    alias PlanB.Mock.ServerA

    setup do
        ServerA.start_link %{}

        :ok
    end

    test "get a counter when calling the server count method", _ do
        assert ServerA.count == 1
        assert ServerA.count == 2
        assert ServerA.count == 3
        assert ServerA.count == 4
        assert ServerA.count == 5
    end
end
