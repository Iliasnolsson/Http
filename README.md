# Http

Swift Package which simplifies async http calls to web api for JSON. 
Overridable methods for configuring request after subclassing the http class (for adding token etc.)
-  postRequest(forUrl url: URL) -> URLRequest
-  getRequest(forUrl url: URL) -> URLRequest
