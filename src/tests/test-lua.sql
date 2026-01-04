.print '* Testing Lua'

.load 'sqlite3-lua'

.testcase 'createlua-01'
    select createlua('lua_version',
      'return _VERSION');

    select createlua('hello',
      'return "Hello "..arg[1].."!"');
.check 'ok ok'

.testcase 'call-01'
    select hello('World');
.check 'Hello World!'

.testcase 'call-02'
    select hello(lua_version());
.check 'Hello Lua 5.5!'
