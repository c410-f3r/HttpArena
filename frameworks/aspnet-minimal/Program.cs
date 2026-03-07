using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:8080");
builder.Logging.ClearProviders();
var app = builder.Build();

app.Use(async (ctx, next) =>
{
    ctx.Response.Headers["Server"] = "aspnet-minimal";
    await next();
});

// Load dataset at startup
var datasetPath = Environment.GetEnvironmentVariable("DATASET_PATH") ?? "/data/dataset.json";
List<DatasetItem>? datasetItems = null;
if (File.Exists(datasetPath))
{
    var json = File.ReadAllText(datasetPath);
    datasetItems = JsonSerializer.Deserialize<List<DatasetItem>>(json);
}

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

app.MapGet("/json", () =>
{
    if (datasetItems == null)
        return Results.Problem("Dataset not loaded");

    var responseItems = new List<ProcessedItem>(datasetItems.Count);
    foreach (var item in datasetItems)
    {
        responseItems.Add(new ProcessedItem
        {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            Price = item.Price,
            Quantity = item.Quantity,
            Active = item.Active,
            Tags = item.Tags,
            Rating = item.Rating,
            Total = Math.Round(item.Price * item.Quantity, 2)
        });
    }

    return Results.Json(new { items = responseItems, count = responseItems.Count });
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

class DatasetItem
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public double Price { get; set; }
    public int Quantity { get; set; }
    public bool Active { get; set; }
    public List<string> Tags { get; set; } = new();
    public RatingInfo Rating { get; set; } = new();
}

class ProcessedItem
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public double Price { get; set; }
    public int Quantity { get; set; }
    public bool Active { get; set; }
    public List<string> Tags { get; set; } = new();
    public RatingInfo Rating { get; set; } = new();
    public double Total { get; set; }
}

class RatingInfo
{
    public double Score { get; set; }
    public int Count { get; set; }
}
