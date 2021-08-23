defmodule PlanB.MixProject do
    use Mix.Project

    def project do
        [
            app: :planb,
            version: "0.1.3",
            elixir: "~> 1.11",
            start_permanent: Mix.env() == :prod,
            build_embedded: Mix.env == :prod,
            elixirc_paths: elixirc_paths(Mix.env()),
            deps: deps(),
            description: description(),
            package: package()
        ]
    end

    defp elixirc_paths(:test), do: ["lib", "test/mock"]
    defp elixirc_paths(_), do: ["lib"]

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger]
        ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:ex_doc, "~> 0.11", only: :dev, runtime: false},
            {:earmark, "~> 0.1", only: :dev, runtime: false},
            {:dialyxir, "~> 0.3", only: [:dev], runtime: false}
        ]
    end


    defp description do
        """
        Library that helps to broadcast messages to different GenServers, improving decoupling of your app.
        """
    end

    defp package do
        [
            files: ["lib", "mix.exs", "README.md"],
            maintainers: ["Mihai Blebea"],
            licenses: ["Apache 2.0"],
            links: %{
                "GitHub" => "https://github.com/MihaiBlebea/plan_b",
                "Docs" => "https://hexdocs.pm/planb/api-reference.html"
            }
        ]
    end
end
