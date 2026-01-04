.load 'sqlite3-tjutil'

select printf('%08x', inet_aton('AF_INET',  '127.0.0.1'));
select printf('%08x', inet_aton('AF_INET',  '127.0.0.2', 0));
select printf('%08x', inet_aton(            '127.0.0.3'));
select printf('%08x', inet_aton(            '127.0.0.4', 0));
select hex(           inet_aton('AF_INET6', '::1'));
select hex(           inet_aton('AF_INET6', 'fe80::9522:59e5:22f7:d72f'));
select printf('%08x', inet_aton(2,          '127.0.0.5'));
select printf('%08x', inet_aton('AF_INET',  '256.0.0.6')); -- Invalid
select printf('%08x', inet_aton('AF_INET',  '')); -- Invalid
select printf('%08x', inet_aton('AF_INET',  NULL)); -- Error
select printf('%08x', inet_aton('AF_FOO',   '127.0.0.7')); -- Error
select printf('%08x', inet_aton('FOO_BAR',  '127.0.0.7')); -- Error

.mode line
select
   printf('%08x', inet_aton('AF_INET',  '127.0.0.1'))
 , printf('%08x', inet_aton('AF_INET',  '127.0.0.1', 0))
 , hex(           inet_aton('AF_INET6', '::1'))
-- printf('%08x', inet_aton(2,          '127.0.0.1')),
 , printf('%08x', inet_aton('AF_INET',  '256.0.0.1')) -- Invalid
 , printf('%08x', inet_aton('AF_INET',  '')) -- Invalid
-- , printf('%08x', inet_aton('AF_INET',  NULL)) -- Invalid
-- , printf('%08x', inet_aton('AF_FOO',  '127.0.0.1'))
;