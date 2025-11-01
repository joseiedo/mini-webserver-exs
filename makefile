test-watch:
	fswatch lib test | mix test --stale --listen-on-stdin
