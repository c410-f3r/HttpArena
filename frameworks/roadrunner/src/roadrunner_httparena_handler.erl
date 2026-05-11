-module(roadrunner_httparena_handler).
-behaviour(roadrunner_handler).

-export([routes/0]).
-export([handle/1]).

-spec routes() -> [roadrunner_router:route()].
routes() ->
    [
        {~"/baseline11", ?MODULE, undefined},
        {~"/pipeline", ?MODULE, undefined}
    ].

-spec handle(roadrunner_req:request()) -> roadrunner_handler:result().
handle(Req) ->
    handle_route(roadrunner_req:path(Req), Req).

handle_route(~"/baseline11", Req) ->
    baseline11(Req);
handle_route(~"/pipeline", Req) ->
    {roadrunner_resp:text(200, ~"ok"), Req};
handle_route(_, Req) ->
    {roadrunner_resp:not_found(), Req}.

baseline11(Req) ->
    A = qs_int(~"a", Req, 0),
    B = qs_int(~"b", Req, 0),
    {BodyN, Req2} =
        case roadrunner_req:method(Req) of
            ~"POST" ->
                {ok, Body, ReqR} = roadrunner_req:read_body(Req),
                {body_int(Body), ReqR};
            _ ->
                {0, Req}
        end,
    {roadrunner_resp:text(200, integer_to_binary(A + B + BodyN)), Req2}.

qs_int(Key, Req, Default) ->
    case lists:keyfind(Key, 1, roadrunner_req:parse_qs(Req)) of
        {Key, V} when is_binary(V) -> bin_int(V, Default);
        _ -> Default
    end.

bin_int(<<>>, Default) ->
    Default;
bin_int(Bin, Default) ->
    case string:to_integer(Bin) of
        {N, _} when is_integer(N) -> N;
        _ -> Default
    end.

body_int(<<>>) -> 0;
body_int(Bin) -> bin_int(Bin, 0).
