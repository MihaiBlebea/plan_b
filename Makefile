run:
	iex -S mix

.PHONY: test
test:
	mix test

static:
	mix dialyzer

.PHONY: doc
doc: 
	mix docs && cd ./doc && open index.html

publish:
	mix docs && \
	mix hex.publish
