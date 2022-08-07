# Http
A Switch Package to simplify asynchronous http calls & for easier implementation of web api bearer token logic

<img src="icon.jpg">

## Installation
This is a Swift Package & can be easily installed within Xcode.
1. Open you iOS project in Xcode
2. Navigate to the *package manager* through the top tab by clicking *File* then *Add Packages...*
3. Input the url to this GitHub repository in the search field. 
4. Click on download

## Outline
An map of the most important classes enums & stuff from this Swift Package 

### class Http
Used for making post & get calls to given url.
##### Main Methods:
```swift
func get(_ urlAddon: String) async -> HttpResult
func get<T>(_ urlAddon: String) async -> HttpObjectResult<T>
func post(_ urlAddon: String) async -> HttpResult
func post<T>(_ urlAddon: String) async -> HttpObjectResult<T>
```

### class HttpCatchable: *Http*
Recommended over *Http*. Used for making post & get calls to given url. Same functionality as Http but throws a detailed failure when an api request fails.

##### Main Methods:

```swift
func get(_ urlAddon: String) async throws
func get<T>(_ urlAddon: String) async throws -> T
func post(_ urlAddon: String) async throws
func post<T>(_ urlAddon: String) async throws -> T
```

### class HttpCatchableGeneric\<S: HttpEndpoint>: HttpCatchable
Recommended over *HttpCatchable* when building large scale apps. 
##### Main Methods:

```swift
func get(_ urlAddon: S) async throws 
func get<T>(_ urlAddon: S) async throws -> T
func post(_ urlAddon: S) async throws
func post<T>(_ urlAddon: S) async throws -> T
```

## Examples

### Simple Post
Make a simple post call to https://fakeUrl.com/sign-in
> bypassInvalidCertificate: true will stop iOS from complaining when the website of the baseUrl has an invalid certificate

```swift
/// 1. Importing this package
import Http

/// 2. Creating the HttpObject 
var http = Http(baseUrl: "https://fakeUrl.com/", bypassInvalidCertificate: true)

// 3. Making the post request
var result = await http.post("sign-in", body:
[
    "email" : "fakeEmail@icloud.com",
    "password" : "fakePassword"
])

// 4. Reading what we got from the request 
if result.succeeded {
    print("Succeeded")
} else {
    print("Failed with message" + result.message)
}

```

### Post to method returning something
This is an example of how to make make a post call to an api method which returns something. Lets say that https://fakeUrl.com/sign-in returns the json below. 

``` json
{
    "firstName": "fake",
    "lastName": "json"
}
```

#### 1. We first create a decodable class for the result

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

#### 2. Call the api method with desired result
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



## OAuth Authentication (bearer/access token)
This Swift Package does not only simplify post & get calls but does also simplify the implementation of OAuth Authentication. 

### Implementation
The process of implementing OAuth through the Http Swift Package consists of two parts:
1. Subclass either Http, HttpCatchable or HttpCatchableGeneric
2. Override & implement the method *accessToken() -> String?* 

The value returned from the accessToken() method will if not nil be added to the header of all get and post requests.

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

### Example Logic 
The example below shows how the accessToken() method could be implemented with support for updating the accessToken through a refreshToken when the accessToken no longer is valid.

The implementation below consists of:
1. Check if a accessToken exists
    - True: Return the accessToken
    - False: Try to get a new accessToken by checking for a refreshToken

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
        if let refreshToken = _tokenService.getRefreshToken() {
            let http = Http(baseUrl: Constants.apiUrl.appending(path: "account"))
            let result: HttpObjectResult<AccountTokensResponse> = await http.post("tokens-refresh", body: ["refreshToken" : refreshToken])
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

### Custom bearer 
Custom keyword for the authentication access token header can be spesified if your api does not user the standard bearer.

```swift
import Http

var http = Http(baseUrl: "https://fakeUrl.com/", bypassInvalidCertificate: true, accessTokenBearerName: "custom")

/// the access token header would now instead be:
/// "custom 13kdas021cam02mas2123masd21la0qw12"
```


