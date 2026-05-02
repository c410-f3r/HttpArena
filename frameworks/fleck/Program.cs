using Fleck;

namespace riderdog;

internal static class Program
{
    private static async Task Main()
    {
        var server = new WebSocketServer("ws://0.0.0.0:8080");
        server.Start(socket =>
        {
            socket.OnMessage = message => socket.Send(message);
        });

        Console.ReadLine();
    }
}
