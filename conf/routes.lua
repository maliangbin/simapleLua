local route = {
    {"GET", '/produce/pcontent/:client_type/:customer_id/:device_token', 'app.controllers.produce',
    'pcontent'},
}

return route
