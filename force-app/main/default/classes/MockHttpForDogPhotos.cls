@isTest
global class MockHttpForDogPhotos implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();  
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"https://image.com/url","status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}