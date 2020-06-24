function json_validator(req) {
    try {
        if ( req.variables.request_body.length > 0 ) {
            JSON.parse(req.variables.request_body);
        }
        return req.variables.upstream;
    } catch (e) {
        req.log('JSON.parse exception');
        return '127.0.0.1:10415'; // Address for error response
    }
}