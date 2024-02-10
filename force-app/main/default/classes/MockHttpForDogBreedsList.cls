@isTest
global class MockHttpForDogBreedsList implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":{"affenpinscher":[],"african":[],"airedale":[],"akita":[],"appenzeller":[],"australian":["shepherd"]},"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}