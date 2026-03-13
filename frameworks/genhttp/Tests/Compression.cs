using System.Text.Json;
using GenHTTP.Api.Content;
using GenHTTP.Api.Protocol;
using GenHTTP.Modules.Reflection;
using GenHTTP.Modules.Webservices;

namespace genhttp.Tests;

public class Compression
{
    private static FlexibleContentType _jsonType = FlexibleContentType.Get(ContentType.ApplicationJson);
    
    private static byte[]? _largeJsonBytes = LoadJson();

    private static byte[]? LoadJson()
    {
        var jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };
        
        var largePath = "/data/dataset-large.json";
        
        if (File.Exists(largePath))
        {
            var largeItems = JsonSerializer.Deserialize<List<DatasetItem>>(File.ReadAllText(largePath), jsonOptions);
            
            if (largeItems != null)
            {
                var processed = largeItems.Select(d => new ProcessedItem
                {
                    Id = d.Id, Name = d.Name, Category = d.Category,
                    Price = d.Price, Quantity = d.Quantity, Active = d.Active,
                    Tags = d.Tags, Rating = d.Rating,
                    Total = Math.Round(d.Price * d.Quantity, 2)
                }).ToList();
                
                return JsonSerializer.SerializeToUtf8Bytes(new { items = processed, count = processed.Count }, jsonOptions);
            }
        }

        return null;
    }

    [ResourceMethod]
    public Result<byte[]> Compress()
    {
        if (_largeJsonBytes == null)
        {
            throw new ProviderException(ResponseStatus.InternalServerError, "No dataset");
        }

        return new Result<byte[]>(_largeJsonBytes).Type(_jsonType);
    }
    
}