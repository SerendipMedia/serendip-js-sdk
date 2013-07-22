# Serendip JavaScript SDK


The Serendip SDK for JavaScript provides a rich set of client-side functionality for accessing authentication aspects of the Serendip service, a convenient framework to access the server-side API and some UI utilities. 

## Initialization
Serendip JavaScript SDK is available at the following URL:

<a href="http://developers.serendip.me/lib/sdk.js">http://developers.serendip.me/lib/sdk.js</a>

Clients are encouraged to load the sdk asynchronously, either using JavaScript (see a similar example here <a href="https://developers.facebook.com/docs/reference/javascript/">https://developers.facebook.com/docs/reference/javascript/</a>, or using an async library such as <a href="http://requirejs.org/">requirejs</a>).

Once the SDK is ready for use,  it will call the global function **window.onSrndpReady** and will make the global variable SRNDP available.

The first call to the SDK must always be **SRNDP.init** passing the configuration parameters. 

The following snippet is a full example of how to load and init the SRNDP JS SDK - 

<pre><code>((function(d, s, id){
        var js, sjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {return;}
        js = d.createElement(s); js.id = id;
        js.src = "http://developers.serendip.me/lib/sdk.js";
        sjs.parentNode.insertBefore(js, sjs);
    })(document, 'script', 'srndp-jssdk'));</code></pre>

## Demo App


There’s a very simple demo app in <a href="http://developers.serendip.me/demo/index.html">demo/index.html</a>, which provides an annotated script to use the JS SDK.

## General


Once the onSrndpReady function is triggered, the client can access the globally-accessible SRNDP object which is the entry-point for all SDK calls.

All SDK calls are asynchronous and adhere to the <a href="http://api.jquery.com/category/deferred-object/">Deferred</a> interface . Generally speaking, a call may either be resolved, or rejected.

Resolved calls will pass a response object as the first parameter to the done callback, whereas rejected calls will pass an error object as the first parameter to the fail callback.

A typical SDK call may take the following form:

> SRNDP.<method_name>(params*).done( function (responseObject obj) {  <resolve code) }.fail( function (errorObject error) { <error handling code> }

For example:

> SRDNP.api(“/dj/info.json”, { “id” : “fb_591377544”}).done(function (djObj) { alert(“Hello “ + djObj.userName); }.fail(function (err) { alert(“Opps. Error: “ + err.msg); }

For the sake of clarity, within this document, API signatures will denote their response object as the return value of the call. However, in practice, clients should expect to receive these objects within the done() callback.

## Core Methods


##### ResponseObject SRNDP.Init(InitObject initializationObject)

Initialize the SDK with params. Any access to any of the SRNDP calls without first successfully initializing the object will return an **ERR_NOT_INITIALIZED** error.

##### Object SRNDP.api(URL endpoint, Object params, Boolean auth = false, String method = ‘GET’)


A utility function to make calls against the Serendip Server API. 
endpoint should hold the API endpoint as defined in the Active Docs. 
Endpoint-specific params should be passed with the params object.
(Please note that the cliend_it and optional auth_token params will be added automatically to the call).

The response will be returned as a generic object which in practice will hold the return data as defined in the <a href="https://serendip.3scale.net/docs">Active Docs</a>.

In general, all Serendip API endpoints are defined as ‘GET’ methods, and hence the method parameter should not be overwritten. However, the support for other HTTP methods is provided here for future proof.

If an authenticated request is required, clients should pass true as the auth param.

Trying to access an endpoint that requires authentication, without passing this param will result in  **ERR_AUTHENTICATION_REQUIRED** error to be returned. 

Trying to access an endpoint that requires authentication, without being logged in (or if token has expired), will result in **ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN** error to be returned. 

Trying to access an endpoint that can optionally use authentication, without a valid token, will result in returning a response as if the auth flag was set to false. (return the non-personalized version of the response).

The complete API specification, along with the definition of the response objects is defined in the <a href="https://serendip.3scale.net/docs">API Specification Docs</a> 

## Authentication Calls

##### LoginStatus SRNDP.getLoginStatus()

Returns a loginStatus object indicating whether the user is logged in to Serendip and conveying additional information.

Use getLoginStatus() wherever accessing a screen that requires authentication. 

Generally speaking, the function may return one of the following statuses : ‘logged_in’ , ‘signing_up’ and ‘logged_out’ . 

The ‘srndp_authorized” field indicates that a user is currently logged-in to Serendip website. If this field is returned as true, clients may attempt to do an implicit login, passing the implicit flag to SRNDP.login. We recommend to use that pattern, so that users will not be required to login twice (once to the website and another time to the client-app). 

The ‘facebook_authorized” field indicates that a user is currently logged-in with Facebook and have previously authorized to use Serendip with his Facebook account. If this field is returned as true, clients may attempt to do an implicit login, passing the implicit flag to SRNDP.login. 

For more details of how to use implicit login, see the <a href="http://developers.serendip.me/demo/index.html">demo app</a>. 

##### LoginStatus SRNDP.login(String network, boolean implicit = false, boolean rememberMe = false, String state, boolean newWindow = true)

Call to this function will trigger a Facebook/Twitter authentication process.

Explicit logins require to trigger a popup to the 3-rd party service, and hence should always require a user action (or otherwise will be blocked by ad-blockers).

If facebook_authorized or srndp_authorized are returned as true in the LoginStatus, an implicit login is supported. In such case, the authentication flow is Ajax based and there are no popups.

Following a successful workflow, a LoginStatus object will be returned.

If the rememberMe flag is set to true, the login process will result in a long-term session (a month). 

State is an optional parameters that if passed will be echoed back to the callback function

**In-Place Authentication**

If newWindow is set to true, the dialog will be invoked as a popup; otherwise it will be invoked in-place. 

Unlike a popup login, we cannot use the Deferred done and fail callbacks for in-place authentication, since the Deferred object cannot be preserved across multiple pages.

Instead done and fail callbacks must be attached to the global window object under the names onReturnFromLogin and onError, respectively.

See the twitter login in the demo app. 

##### ResponseObject SRNDP.logout(boolean facebook = false)

This calls invalidates/deletes any locally stored state and transitions the client to a ‘logged_out’ state.

If facebook is true, will also log out from FB. This is provided to enable users to seamlessly login with another FB user.

##### boolean SRNDP.isRegistered()

(synchronous) if true, the user is active in the system, Otherwise, the user is still in a registration process.
A non-registered user can only use the register authenticated API endpoint. All other calls will result in a ERR_AUTHENTICATION_REQUIRED error.

##### ResponseObject SRNDP.register(String username, String name, boolean rememberMe, String email, String location, boolean shouldActivate)

Registers a new user and transition the LoginState from ‘signing_up’ to ‘logged_in’

##### ResponseObject SRDNP.activate()

This call will transition an inactive user into an active one. 

Clients which provide a single screen registration flow , shouldn’t use this call and instead pass the shouldActivate flag as true to the register call.

Clients supporting a multi-screen registration process, should pass false to the shouldActivate flag on registration call, and at the end of the full registration process should call this function for activation. 


**Not yet implemented**

##### ResponseObject SRNDP.connect(String network, String state, boolean newWindow = true)

This call is similar to the SRNDP.login call, but unlike it, it results in the addition of a second account (facebook|twitter) to an already logged in user. 

In case the attempted network is already attached to another user, an **ERR_NETWORK_ALREADY_CONNECTED** will be returned.

State is an optional parameters that if passed will be echoed back to the callback function

If newWindow is set to true, the popup will be invoked as a popup; otherwise it will be invoked in-place.

**Not yet implemented**

##### ResponseObject SRNDP.disconnect(String network)

Disconnects the network passed as param.

If the user is connected with a single network, an attempt to disconnect it will result in ERR_CANNOT_DISCONNECT_ONLY_NETWORK error.


Refer to <a href="https://serendip.3scale.net/docs">API Specification Docs</a> for more details

## Events

##### ResponseObject SRNDP.subscribe(String eventName, Function callback)

Subscribes to an event. Whenever the event is fired, the callback will be called passing in an Object.

See <a href="#events-1">Events</a> section for list of supported events

##### ResponseObject SRNDP.unsubscribe(String eventName,Function callback)

Removes the event handler from this specific event.

## Chrome Extenstions Support

Chrome Extenstions entail restrictions in terms of access to external resoruces. 

The following guidelines should be implemented by developers of chrome extensions who wish to access the SRNDP JavaScript SDK.

#### Loading of JS SDK over https

Replace the call to the JS SDK in your script file, with the following URL

```
js.src = "https://developers-srndp.s3.amazonaws.com/lib/sdk"
```

#### Changes to Manifest.json

The following fields should be added to (or merged with your own data) the Manifest.json file of the extension -

```
{
	"permissions" : "*://serendip.me/",
	"content_scripts": [
        {
            "matches": ["*://serendip.me/*"],
            "js": ["scripts/readAuth.js"]
        }
    ],
    "content_security_policy": "script-src 'self' 'unsafe-eval' https://developers-srndp.s3.amazonaws.com https://developers-srndp-dev.s3.amazonaws.com https://connect.facebook.net; object-src 'self'"
}
```

#### Content Script

The script **readAuth.js** should be added as a content script to the extension.
In the example above, we assume it resides within the scripts directory beneath our base directory.
In case your extension use a different directory structure, make sure to place it in the right one.

The file can be downloaded from <a href="http://developers.serendip.me/resources/scripts/readAuth.js">http://developers.serendip.me/resources/scripts/readAuth.js</a>


## UI

**Not yet implemented**

##### Object SRNDP.ui(String dialog, Object params)

Invokes  UI popup corresponding to the name provided in the dialog param and passing in the list of params.

The call will be resolved or rejected following the user interaction with the UI dialog, passing back a generic object which is defined as per-dialog basis.

A full reference of the UI dialogs will be available soon (Not yet implemented)

## Objects

##### ResponseObject

Generic acknowledgment of call. 

status: String - only value is ‘ok’ which represents a successful operation acknowledgment.
 
##### ErrorObject

Details about the error that occurred. ErrorObject is typically returned with a call reject, and should be caught an handled with the fail callback.

code: String - code describing the error (see <a href="#error-codes">Error Codes</a>)
msg : String - a human readable message describing the error

##### InitObject

Initialization parameters to the JS SDK. Currently, client_id is the only parameter required.

Clients who wish to use the Serendip API, may request a client id using the API portal.

client_id : String - the API client id as defined in the 3scale system

##### LoginStatus

Represents the current authentication status of the user using the app.

status : String - can take the values ‘logged_in’ , signing_up and ‘logged_out’
A new user will be set to the ‘signing_up’ state, until a registration flow has completed. 

facebook_authorized : boolean -  if set to true, the user is currently logged in with a FB user who has previously authorized the Serendip application. Clients may attempt an implicit login in such case.

srndp_authorized : boolean - if set to true, the user is currently logged to the Serendip web app. Clients may attempt an implicit login in such case.

username  : String - in the case of a logged_in user, this key holds the unique username of the user in the Serendip service.

newuser : boolean - if true, the LoginStatus will include a newUserObj object with suggested values for the sign process (if newuser = true, the auth_token is always short term, regardless of the rememberMe flag)

newuserObj : NewuserObj

state:String - if state was passed to the call, it will be echoed back to calling function 

##### NewUserObj

Holds suggested value for a new user signing up to the service.
We recommend that clients should populate signup forms with these suggested values for a frictionless registration flow.

username : String - suggested username to use based on twitter/facebook account (the username is guaranteed to be unique in the system).

email : String- suggested email to use if available via Facebook

name : String - suggested display name based on Facebook/Twitter account.

## Events

##### srndp.statusChange

Fired whenever the login status of the user changes. Passes in a LoginObject object

## Error Codes

**ERR_NOT_INITIALIZED** - attempt to access to the SDK without first initializing it using the SRNDP.init call
**ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN** - attempt to access an authenticated API endpoint without a valid access token (user might be logged out or token expired)
**ERR_INVALID_API_CALL** - API server returned an error. The msg param will include more details.
**ERR_AUTHENTICATION_REQUIRED** - attempt to call an authenticated endpoint without setting the auth flag to true
**ERR_NETWORK_ALREADY_CONNECTED** - trying to add a second network which is already attached to another user
**ERR_CANNOT_DISCONNECT_ONLY_NETWORK** - trying to disconnect only network connected
**ERR_INSECURED_CALL** - this is typically thrown due to cross-origin security 

### Change Log

#### 0.1 July 08, 2013

Deployable first version<br/>
Authentication flow<br/>
API utility call <br/>
Events

#### 0.2 July 09, 2013

In-place Authentication login

#### 0.3 July 22, 2013

Chrome Extensions Support

### License

Copyright 2013 Serendip Media, Inc.

Licensed under the MIT License

