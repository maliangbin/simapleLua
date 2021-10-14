local databases = {}

databases.redis = {
    ['connections'] = {
        ['default'] = {
            ['host'] = '127.0.0.1',
            ['port'] = '6379',
            ['password'] = 'maliangbin0713',
            ['timeout'] = '10000'
        }
    }
}

databases.mongodb = {
    ['connections'] = {
        ['default'] = {
            ['host'] = '127.0.0.1',
            ['port'] = '27017',
            ['username'] = 'root',
            ['password'] = '123456',
            ['database'] = 'mcache',
            ['timeout'] = 10000
        }
    }
}

return databases