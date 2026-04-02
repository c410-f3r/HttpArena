using genhttp;

using GenHTTP.Engine.Internal;
using GenHTTP.Modules.Compression;

var app = Project.Create();

var host = Host.Create()
               .Handler(app)
               .Compression();

await host.RunAsync();