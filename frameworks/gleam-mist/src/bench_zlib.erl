-module(bench_zlib).
-export([gzip_level1/1]).

gzip_level1(Data) ->
    Z = zlib:open(),
    ok = zlib:deflateInit(Z, 1, deflated, 31, 8, default),
    Compressed = zlib:deflate(Z, Data, finish),
    ok = zlib:deflateEnd(Z),
    zlib:close(Z),
    iolist_to_binary(Compressed).
