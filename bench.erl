-module(bench).

-mode(compile).

main([]) ->
  Data100B = crypto:strong_rand_bytes(100),
  Data1MB = crypto:strong_rand_bytes(1024 * 1024),
  io:format("== Testing with 100 B ==~n"),
  test_encode(Data100B, 1_000_000),
  test_decode(Data100B, 1_000_000),
  io:format("~n== Testing with 1 MB ==~n"),
  test_encode(Data1MB, 1000),
  test_decode(Data1MB, 1000).

test_encode(Data, Iterations) ->
  Encoded = base64:encode(Data),
  [test(Fun, Data, Encoded, Iterations)
   || Fun <- [fun base64:encode/1, fun b64fast:encode64/1, fun b64_nif:encode/1]].

test_decode(Data, Iterations) ->
  Encoded = base64:encode(Data),
  [test(Fun, Encoded, Data, Iterations)
   || Fun <- [fun base64:decode/1, fun b64fast:decode64/1, fun b64_nif:decode/1]].

test(Fun, Input, Expected, Iterations) ->
  %% Check that the fun works
  Expected = Fun(Input),
  {Time, ok} = timer:tc(fun() -> run_test(Fun, Input, Iterations) end),
  Millis = Time div 1000,
  io:format("~p: ~B iterations in ~B ms: ~B it/sec~n", [Fun, Iterations, Millis, Iterations * 1000 div Millis]).

run_test(_Fun, _Input, 0) ->
  ok;
run_test(Fun, Input, Iterations) ->
  Fun(Input),
  run_test(Fun, Input, Iterations - 1).
