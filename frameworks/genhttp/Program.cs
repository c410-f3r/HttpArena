using System.Net;
using System.Security.Cryptography.X509Certificates;

using genhttp;

using GenHTTP.Engine.Kestrel;

var certPath = Environment.GetEnvironmentVariable("TLS_CERT") ?? "/certs/server.crt";
var keyPath = Environment.GetEnvironmentVariable("TLS_KEY") ?? "/certs/server.key";
var hasCert = File.Exists(certPath) && File.Exists(keyPath);

var app = Project.Create();

var host = Host.Create().Handler(app);

host.Bind(IPAddress.Any, 8080);

if (hasCert)
{
    var cert = X509Certificate2.CreateFromPemFile(certPath, keyPath);
    host.Bind(IPAddress.Any, 8443, cert, enableQuic: true);
}

await host.RunAsync();