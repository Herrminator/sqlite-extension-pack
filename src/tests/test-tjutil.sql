.print '* Testing tjutil'

.load 'sqlite3-tjutil'

.testcase 'inet_aton-01'
  select printf('0x%08X', inet_aton('192.168.1.1'));
  select printf('0x%08X', inet_aton('192.168.1.1', 0));
  select printf('0x%08X', inet_aton('192.168.1.1/24'));
  select printf('0x%08X', inet_aton('192.168.1.1/16'));
  select printf('0x%08X', inet_aton('192.168.1.1/16', 0));
  select hex(inet_aton('AF_INET6', 'fe80::10d4:1a41:fb98:2334'));
.check '0xC0A80101 0x0101A8C0 0xC0A80100 0xC0A80000 0x0000A8C0 FE8000000000000010D41A41FB982334'

.testcase 'getenv-01'
  select getenv('HELLO');
.check 'Hello World!'

.testcase 'fileio-01'
  select writefile('test-tjutil.dat', 'foobar');
  select readfile('test-tjutil.dat');
.check '6 foobar'
