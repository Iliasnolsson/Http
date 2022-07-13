# Http

Swift Package which simplifies async http calls to web api. 

#### Post
Make a simple post call to https://fakeUrl.com/sign-in
- bypassInvalidCertificate: true will stop iOS from complaining when the website of the baseUrl has an invalid certificate
```swift
import Http

var http = Http(baseUrl: "https://fakeUrl.com/", bypassInvalidCertificate: true)
var result = await http.post("sign-in", body:
[
    "email" : "fakeEmail@icloud.com",
    "password" : "fakePassword"
])

if result.succeeded {
    print("Succeeded")
} else {
    print("Failed with message" + result.message)
}

```

#### Post to Method Returning Something
Make a post call to an api method which returns somthing. Lets say that https://fakeUrl.com/sign-in returns the json below. 
``` json
{
    "firstName": "fake",
    "lastName": "json"
}
```

##### 1. We first create a decodable class for the result :

```swift
class SignInResponse: Decodable {
    
    var firstName: String
    var lastName: String
    
    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
    }
    
}
```

##### 2. Call the api method with desired result
The http.post method will now decode the result from "https://fakeUrl.com/sign-in" into the specified class 

```swift
import Http

var http = Http(baseUrl: "https://fakeUrl.com/", bypassInvalidCertificate: true)
/// Set the type of variable result to an HttpObjectResult<T> where T is the class
/// which you want the http.post method to decode the result into
var result: HttpObjectResult<SignInResponse> = await http.post("sign-in", body:
[
    "email" : "fakeEmail@icloud.com",
    "password" : "fakePassword"
])
if result.succeeded {
    print("Succeeded")
    print("Your first name is: " + result.object.firstName )
} else {
    print("Failed with message" + result.message)
}
```



#### Add Authentication (bearer/access token)
Begin by conform to the Http class and override the accessToken(). The value returned from the accessToken() method will if not nil be added to the header of all get and post requests. accessToken() is called before all post & get calls. 
```swift

import Http

class CustomHttp: Http {
    init() {
        super.init(baseUrl: "https://fakeUrl.com/")
    }
    override func accessToken() async -> String? {
        // ... logic for receiving the token
        return storedAccessToken
    }
}
```

##### Custom bearer 
Custom keyword for the authentication access token header can be spesified if your api does not user the standard bearer.

```swift
import Http

var http = Http(baseUrl: "https://fakeUrl.com/", bypassInvalidCertificate: true, accessTokenBearerName: "custom")

/// the access token header would now instead be:
/// "custom 13kdas021cam02mas2123masd21la0qw12"
```

##### Example implementation accessToken() 
The example below shows how the accessToken() method could be implemented with support for updating the accessToken through a refreshToken when the accessToken no longer is valid.

```swift
import Http

class CustomHttp: Http {
    

    init() {
        super.init(baseUrl: "https://fakeUrl.com/")
    }
    
    override func accessToken() async -> String? {
        if let accessToken = _tokenService.getAccessToken() {
            return accessToken
        }
        if let refreshToken = _tokenService.getRefreshToken(),
           let email = _storageService.string(forKey: .accountEmail) {
            let http = Http(baseUrl: Constants.apiUrl.appending(path: "account"))
            let result: HttpObjectResult<AccountTokensResponse> = await http.post("tokens-refresh", body:
            [
                "email" : email,
                "refreshToken" : refreshToken
            ])
            if (result.succeeded) {
                _tokenService.setAccessToken(result.object.accessToken, expires: result.object.accessTokenExpires)
                _tokenService.setRefreshToken(result.object.refreshToken)
                return result.object.accessToken
            }
        }
        return nil
    }
    
}

```

