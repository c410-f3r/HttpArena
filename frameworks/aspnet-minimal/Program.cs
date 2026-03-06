var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:8080");
builder.Logging.ClearProviders();
var app = builder.Build();

app.Use(async (ctx, next) =>
{
    ctx.Response.Headers["Server"] = "aspnet-minimal";
    await next();
});

app.MapGet("/pipeline", () => Results.Text("ok"));

app.MapGet("/bench", (HttpRequest req) =>
{
    int sum = SumQuery(req);
    return Results.Text(sum.ToString());
});

app.MapPost("/bench", async (HttpRequest req) =>
{
    int sum = SumQuery(req);
    
    using var reader = new StreamReader(req.Body);
    
    var body = await reader.ReadToEndAsync();
    
    if (int.TryParse(body, out int b)) 
        sum += b;
    
    return Results.Text(sum.ToString());
});

app.Run();

static int SumQuery(HttpRequest req)
{
    int sum = 0;
    foreach (var (_, values) in req.Query)
        foreach (var v in values)
            if (int.TryParse(v, out int n)) sum += n;
    return sum;
}
