Add-Type -TypeDefinition @"
using System;
using System.Net;
using System.IO;
using System.Threading;

public class TinyServer {
    static string root = @"C:\Users\kriti\.gemini\antigravity\scratch\onpoint-tripinprogress";
    public static void Main() {
        var listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:8080/");
        listener.Start();
        Console.WriteLine("Listening on http://localhost:8080/");
        while (true) {
            var ctx = listener.GetContext();
            ThreadPool.QueueUserWorkItem(_ => {
                var req = ctx.Request;
                var res = ctx.Response;
                string urlPath = req.Url.LocalPath.TrimStart('/');
                if (urlPath == "" || urlPath == "/") urlPath = "index.html";
                string filePath = Path.Combine(root, urlPath);
                try {
                    if (File.Exists(filePath)) {
                        byte[] data = File.ReadAllBytes(filePath);
                        res.ContentType = "text/html; charset=utf-8";
                        res.ContentLength64 = data.Length;
                        res.OutputStream.Write(data, 0, data.Length);
                    } else {
                        res.StatusCode = 404;
                    }
                } catch {}
                finally { try { res.OutputStream.Close(); } catch {} }
            }, null);
        }
    }
}
"@
[TinyServer]::Main()
