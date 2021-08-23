defmodule ServerCTest do
    use ExUnit.Case

    alias PlanB.Mock.ServerA
    alias PlanB.Mock.ServerB
    alias PlanB.Mock.ServerC

    setup do
        ServerA.start_link %{}
        ServerB.start_link %{}
        ServerC.start_link %{}

        :ok
    end

    test "get the correct string when calling ServerC", _ do
        assert ServerC.say_it == "The current count is 1a"
        assert ServerC.say_it == "The current count is 2b"
        assert ServerC.say_it == "The current count is 3c"
        assert ServerC.say_it == "The current count is 4d"
        assert ServerC.say_it == "The current count is 5e"
    end
end
