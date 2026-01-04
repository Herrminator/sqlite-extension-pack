-- select load_extension('C:\Users\johlet\Develop\SQLite\extensions\build\bcc\sqlite3-tjutil.dll');
  select printf('0x%08X', inet_aton('192.168.1.1'));
  select printf('0x%08X', inet_aton('192.168.1.1', 0));
  select printf('0x%08X', inet_aton('192.168.1.1/24'));
  select printf('0x%08X', inet_aton('192.168.1.1/16'));
  select printf('0x%08X', inet_aton('192.168.1.1/16', 0));
--select hex(inet_aton('AF_INET6', 'fe80::10d4:1a41:fb98:2334')); -- not with BCC
  select getenv('HELLO');
  select writefile('test-tjutil.dat', 'foobar');
  select readfile('test-tjutil.dat');
