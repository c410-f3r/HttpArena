using Benchmark;
using Grpc.Core;

namespace AspnetGrpc.Services;

public class BenchmarkServiceImpl : BenchmarkService.BenchmarkServiceBase
{
    public override Task<SumReply> GetSum(SumRequest request, ServerCallContext context)
    {
        return Task.FromResult(new SumReply { Result = request.A + request.B });
    }
}
