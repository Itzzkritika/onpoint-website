$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Server running at http://localhost:8080/"
$root = "C:\Users\kriti\.gemini\antigravity\scratch\onpoint-tripinprogress"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $urlPath = $req.Url.LocalPath.TrimStart('/')
    if ($urlPath -eq '' -or $urlPath -eq '/') { $urlPath = 'index.html' }
    $filePath = Join-Path $root $urlPath
    if (Test-Path $filePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.css'  { 'text/css' }
            '.js'   { 'application/javascript' }
            '.png'  { 'image/png' }
            '.jpg'  { 'image/jpeg' }
            default { 'application/octet-stream' }
        }
        $res.ContentType = $mime
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.OutputStream.Close()
}
