//
// Created by luowei on 2019/11/4.
//

#import "LWWebLoader.h"
#import <ContactsUI/ContactsUI.h>

static NSString *const defaultUA = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36";

@implementation WLEvaluateBody
@end
@implementation WLMessageBody
- (id)initWithDictionary:(NSDictionary *_Nonnull)dict {
    self = [super init];
    if (self) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        mDict[@"requestId"] = mDict[@"requestId"] ?: @"";
        mDict[@"type"] = mDict[@"type"] ?: @"";
        mDict[@"value"] = mDict[@"value"] ?: @"";
        mDict[@"done"] = mDict[@"done"] ?: @NO;
        mDict[@"total"] = mDict[@"total"] ?: @0;
        mDict[@"received"] = mDict[@"received"] ?: @0;
        mDict[@"chrunkOrder"] = mDict[@"chrunkOrder"] ?: @0;
        [self setValuesForKeysWithDictionary:mDict];
    }

    return self;
}
@end


@interface WLWebView () <WKNavigationDelegate>
@property(nonatomic, strong) WKWebViewConfiguration *webConfiguration;
@property(nonatomic, strong) WLEvaluateBody *evaluateBody;
@property(nonatomic, copy) void (^evaluateJSCompletionHandler)(id, NSError *);
@end

@implementation NSDictionary (LWWLSONString)

-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0) error:&error];
    if (! jsonData) {
        WLLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface LWWebLoader ()
@property(nonatomic, strong) WLWebView *webview;
@end

@implementation LWWebLoader {

}

+ (LWWebLoader *)webloader {
    return [[LWWebLoader alloc] init];;
}

+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData {

    NSURL *url = [NSURL URLWithString:urlString ?: @"http://app.wodedata.com"];
    NSString *requestId = NSUUID.UUID.UUIDString;

    NSMutableDictionary *defaultHeaders = @{
            @"user-agent": defaultUA,
//            @"content-type": @"application/json",
    }.mutableCopy;

    defaultHeaders[@"user-agent"] = userAgent ?: defaultHeaders[@"user-agent"];
    if(contentType){
        defaultHeaders[@"content-type"] = contentType;
    }


    NSString *evalueteJSMethod = @"getData";
    NSDictionary *requestHeader = @{
            @"method": @"GET",
            @"headers": defaultHeaders,
            @"cache": @"no-cache",
            @"referrer": [NSString stringWithFormat:@"%@://%@", url.scheme, url.host]
    };
    switch (method){
        case PostData:{
            evalueteJSMethod = @"postData";
            NSString *bodyText = postData ? [postData lwwl_jsonStringWithPrettyPrint:NO] : @"";
            requestHeader = @{
                    @"method": @"POST",
                    @"body": bodyText,
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
            };
            break;
        }
        case UploadData:{
            evalueteJSMethod = @"uploadData";
            NSString *bodyText = postData ? [postData lwwl_jsonStringWithPrettyPrint:NO] : @"";
            requestHeader = @{
                    @"method": @"POST",
                    @"body": bodyText,
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
            };
            break;
        }
        case DownloadFile:{
            evalueteJSMethod = @"downloadFile";
            defaultHeaders[@"requestId"] = requestId;
            requestHeader = @{
                    @"method": @"GET",
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": [NSString stringWithFormat:@"%@://%@", url.scheme, url.host]
            };
            break;
        }
        case DownloadStream:{
            evalueteJSMethod = @"downloadStream";
            defaultHeaders[@"requestId"] = requestId;
            requestHeader = @{
                    @"method": @"GET",
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": [NSString stringWithFormat:@"%@://%@", url.scheme, url.host]
            };
            break;
        }
        case NativeLog:{
            evalueteJSMethod = @"log";
            break;
        }
        case GetData:
        default:{
            break;
        }
    }


    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];
    WLLog(@"==========requestId:%@", requestId);

    NSString *jsCode = [NSString stringWithFormat:@"%@('%@','%@',%@)",evalueteJSMethod,requestId,url.absoluteString,requestHeaderJson];
    if(method==UploadData){
        NSString *uploadDataB64String = uploadData ? [uploadData base64Encoding] : nil;
        jsCode = [NSString stringWithFormat:@"%@('%@','%@',%@,%@)",evalueteJSMethod,requestId,url.absoluteString,requestHeaderJson,uploadDataB64String];
    }


    WLEvaluateBody *evaluateBody = [WLEvaluateBody new];
    evaluateBody.evalueteJSMethod = evalueteJSMethod;
    evaluateBody.url = url;
    evaluateBody.requestId = requestId;
    evaluateBody.jsCode = jsCode;


    return evaluateBody;
}



- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView jsExcuteCompletionHandler:(void (^)(id, NSError *error))jsExcuteCompletionHandler {
    if(!self.webview || self.webview.isLoading){
        __weak typeof(self) weakSelf = self;
        self.webview = [WLWebView buildWebViewWithEvaluateBody:evaluateBody parentView:parentView dataLoadCompletionHandler:nil jsCompletionHandler:^(id result,NSError *error){
            if(jsExcuteCompletionHandler){
                jsExcuteCompletionHandler(result,error);
            }
            [weakSelf.webview removeFromSuperview];
        }];

        [self loadPageWithBaseURL:evaluateBody.url];

    }else{
        [self.webview evaluateJavaScript:evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
            if (jsExcuteCompletionHandler) {
                jsExcuteCompletionHandler(o, error);
            }
        }];
    }


}


- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView dataLoadCompletionHandler:(void (^)(BOOL,id,NSError *))dataLoadCompletionHandler {
    if(!self.webview || self.webview.isLoading){
        __weak typeof(self) weakSelf = self;
        self.webview = [WLWebView buildWebViewWithEvaluateBody:evaluateBody parentView:parentView dataLoadCompletionHandler:^(BOOL finish,id result,NSError *error){
            if(dataLoadCompletionHandler){
                dataLoadCompletionHandler(finish,result,error);
            }
//            [weakSelf.webview removeFromSuperview];
        } jsCompletionHandler:^(id o, NSError *error) {
            if (error) {
                WLLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            }else{
                WLLog(@"======evaluate js %@ ok \n", evaluateBody.evalueteJSMethod);
            }
        }];

        [self loadPageWithBaseURL:evaluateBody.url];

    }else{
        [self.webview evaluateJavaScript:evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
            if (self.webview.evaluateJSCompletionHandler) {
                self.webview.evaluateJSCompletionHandler(o, error);
            }
        }];
    }



}


- (void)loadPageWithBaseURL:(NSURL *_Nonnull)baseURL {

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"loader" withExtension:@"html"];

    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if(!data){
        return;
    }
    NSString *faildText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!faildText){
        return;
    }

    [self.webview loadHTMLString:faildText baseURL:baseURL];

//    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mytest.com/loader.html"]]];

/*
    NSString *defaultHTML = @"<!DOCTYPE html>\n"
                            "<html lang=zh>\n"
                            "<head>\n"
                            "<meta charset=UTF-8>\n"
                            "<title></title>\n"
                            "<script type=text/javascript>!function(e){function t(n){if(r[n])return r[n].exports;var o=r[n]={i:n,l:!1,exports:{}};return e[n].call(o.exports,o,o.exports,t),o.l=!0,o.exports}var r={};t.m=e,t.c=r,t.i=function(e){return e},t.d=function(e,r,n){t.o(e,r)||Object.defineProperty(e,r,{configurable:!1,enumerable:!0,get:n})},t.n=function(e){var r=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(r,\"a\",r),r},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p=\"\",t(t.s=5)}({1:function(e,t,r){\"use strict\";var n=\"function\"==typeof Symbol&&\"symbol\"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&\"function\"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?\"symbol\":typeof e};e.exports={type:function(e){return Object.prototype.toString.call(e).slice(8,-1).toLowerCase()},isObject:function(e,t){return t?\"object\"===this.type(e):e&&\"object\"===(void 0===e?\"undefined\":n(e))},isFormData:function(e){return\"undefined\"!=typeof FormData&&e instanceof FormData},trim:function(e){return e.replace(/(^\\s*)|(\\s*$)/g,\"\")},encode:function(e){return encodeURIComponent(e).replace(/%40/gi,\"@\").replace(/%3A/gi,\":\").replace(/%24/g,\"$\").replace(/%2C/gi,\",\").replace(/%20/g,\"+\").replace(/%5B/gi,\"[\").replace(/%5D/gi,\"]\")},formatParams:function(e){var t=\"\",r=!0,n=this;return this.isObject(e)?(function e(o,i){var a=n.encode,s=n.type(o);if(\"array\"==s)o.forEach(function(t,r){n.isObject(t)||(r=\"\"),e(t,i+\"%5B\"+r+\"%5D\")});else if(\"object\"==s)for(var c in o)e(o[c],i?i+\"%5B\"+a(c)+\"%5D\":a(c));else r||(t+=\"&\"),r=!1,t+=i+\"=\"+a(o)}(e,\"\"),t):e},merge:function(e,t){for(var r in t)e.hasOwnProperty(r)?this.isObject(t[r],1)&&this.isObject(e[r],1)&&this.merge(e[r],t[r]):e[r]=t[r];return e}}},5:function(e,t,r){var n=function(){function e(e,t){for(var r=0;r<t.length;r++){var n=t[r];n.enumerable=n.enumerable||!1,n.configurable=!0,\"value\"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,r,n){return r&&e(t.prototype,r),n&&e(t,n),t}}(),o=r(1),i=\"undefined\"!=typeof document,a=function(){function e(t){function r(e){function t(){e.p=r=n=null}var r=void 0,n=void 0;o.merge(e,{lock:function(){r||(e.p=new Promise(function(e,t){r=e,n=t}))},unlock:function(){r&&(r(),t())},clear:function(){n&&(n(\"cancel\"),t())}})}(function(e,t){if(!(e instanceof t))throw new TypeError(\"Cannot call a class as a function\")})(this,e),this.engine=t||XMLHttpRequest,this.default=this;var n=this.interceptors={response:{use:function(e,t){this.handler=e,this.onerror=t}},request:{use:function(e){this.handler=e}}},i=n.request;r(n.response),r(i),this.config={method:\"GET\",baseURL:\"\",headers:{},timeout:0,params:{},parseJson:!0,withCredentials:!1}}return n(e,[{key:\"request\",value:function(e,t,r){var n=this,a=new this.engine,s=\"Content-Type\",c=s.toLowerCase(),l=this.interceptors,u=l.request,f=l.response,p=u.handler,d=new Promise(function(l,d){function y(e){return e&&e.then&&e.catch}function h(e,t){e?e.then(function(){t()}):t()}function m(r){function n(e,t,n){h(f.p,function(){if(e){n&&(t.request=r);var o=e.call(f,t,Promise);t=void 0===o?t:o}y(t)||(t=Promise[0===n?\"resolve\":\"reject\"](t)),t.then(function(e){l(e)}).catch(function(e){d(e)})})}function u(e){e.engine=a,n(f.onerror,e,-1)}function p(e,t){this.message=e,this.status=t}t=r.body,e=o.trim(r.url);var m=o.trim(r.baseURL||\"\");if(e||!i||m||(e=location.href),0!==e.indexOf(\"http\")){var g=\"/\"===e[0];if(!m&&i){var b=location.pathname.split(\"/\");b.pop(),m=location.protocol+\"//\"+location.host+(g?\"\":b.join(\"/\"))}if(\"/\"!==m[m.length-1]&&(m+=\"/\"),e=m+(g?e.substr(1):e),i){var v=document.createElement(\"a\");v.href=e,e=v.href}}var w=o.trim(r.responseType||\"\"),O=-1!==[\"GET\",\"HEAD\",\"DELETE\",\"OPTION\"].indexOf(r.method),j=o.type(t),x=r.params||{};O&&\"object\"===j&&(x=o.merge(t,x));var N=[];(x=o.formatParams(x))&&N.push(x),O&&t&&\"string\"===j&&N.push(t),N.length>0&&(e+=(-1===e.indexOf(\"?\")?\"?\":\"&\")+N.join(\"&\")),a.open(r.method,e);try{a.withCredentials=!!r.withCredentials,a.timeout=r.timeout||0,\"stream\"!==w&&(a.responseType=w)}catch(e){}var S=r.headers[s]||r.headers[c],P=\"application/x-www-form-urlencoded\";for(var D in o.trim((S||\"\").toLowerCase())===P?t=o.formatParams(t):o.isFormData(t)||-1===[\"object\",\"array\"].indexOf(o.type(t))||(P=\"application/json;charset=utf-8\",t=JSON.stringify(t)),S||O||(r.headers[s]=P),r.headers)if(D===s&&o.isFormData(t))delete r.headers[D];else try{a.setRequestHeader(D,r.headers[D])}catch(e){}a.onload=function(){try{var e=a.response||a.responseText;e&&r.parseJson&&-1!==(a.getResponseHeader(s)||\"\").indexOf(\"json\")&&!o.isObject(e)&&(e=JSON.parse(e));var t=a.responseHeaders;if(!t){t={};var i=(a.getAllResponseHeaders()||\"\").split(\"\\r\\n\");i.pop(),i.forEach(function(e){if(e){var r=e.split(\":\")[0];t[r]=a.getResponseHeader(r)}})}var c=a.status,l=a.statusText,d={data:e,headers:t,status:c,statusText:l};if(o.merge(d,a._response),c>=200&&c<300||304===c)d.engine=a,d.request=r,n(f.handler,d,0);else{var y=new p(l,c);y.response=d,u(y)}}catch(y){u(new p(y.msg,a.status))}},a.onerror=function(e){u(new p(e.msg||\"Network Error\",0))},a.ontimeout=function(){u(new p(\"timeout [ \"+a.timeout+\"ms ]\",1))},a._options=r,setTimeout(function(){a.send(O?null:t)},0)}o.isObject(e)&&(e=(r=e).url),(r=r||{}).headers=r.headers||{},h(u.p,function(){o.merge(r,JSON.parse(JSON.stringify(n.config)));var i=r.headers;i[s]=i[s]||i[c]||\"\",delete i[c],r.body=t||r.body,e=o.trim(e||\"\"),r.method=r.method.toUpperCase(),r.url=e;var a=r;p&&(a=p.call(u,r,Promise)||r),y(a)||(a=Promise.resolve(a)),a.then(function(e){e===r?m(e):l(e)},function(e){d(e)})})});return d.engine=a,d}},{key:\"all\",value:function(e){return Promise.all(e)}},{key:\"spread\",value:function(e){return function(t){return e.apply(null,t)}}}]),e}();a.default=a,[\"get\",\"post\",\"put\",\"patch\",\"head\",\"delete\"].forEach(function(e){a.prototype[e]=function(t,r,n){return this.request(t,r,o.merge({method:e},n))}}),[\"lock\",\"unlock\",\"clear\"].forEach(function(e){a.prototype[e]=function(){this.interceptors.request[e]()}}),window.fly=new a,window.Fly=a,e.exports=a}}),function(e){\"object\"==typeof exports&&\"undefined\"!=typeof module?module.exports=e():\"function\"==typeof define&&define.amd?define([],e):(\"undefined\"!=typeof window?window:\"undefined\"!=typeof global?global:\"undefined\"!=typeof self?self:this).Qs=e()}(function(){return function e(t,r,n){function o(a,s){if(!r[a]){if(!t[a]){var c=\"function\"==typeof require&&require;if(!s&&c)return c(a,!0);if(i)return i(a,!0);var l=new Error(\"Cannot find module '\"+a+\"'\");throw l.code=\"MODULE_NOT_FOUND\",l}var u=r[a]={exports:{}};t[a][0].call(u.exports,function(e){return o(t[a][1][e]||e)},u,u.exports,e,t,r,n)}return r[a].exports}for(var i=\"function\"==typeof require&&require,a=0;a<n.length;a++)o(n[a]);return o}({1:[function(e,t,r){\"use strict\";var n=String.prototype.replace,o=/%20/g,i=e(\"./utils\"),a={RFC1738:\"RFC1738\",RFC3986:\"RFC3986\"};t.exports=i.assign({default:a.RFC3986,formatters:{RFC1738:function(e){return n.call(e,o,\"+\")},RFC3986:function(e){return String(e)}}},a)},{\"./utils\":5}],2:[function(e,t,r){\"use strict\";var n=e(\"./stringify\"),o=e(\"./parse\"),i=e(\"./formats\");t.exports={formats:i,parse:o,stringify:n}},{\"./formats\":1,\"./parse\":3,\"./stringify\":4}],3:[function(e,t,r){\"use strict\";function n(e,t,r){if(e){var n=r.allowDots?e.replace(/\\.([^.[]+)/g,\"[$1]\"):e,o=/(\\[[^[\\]]*])/g,a=0<r.depth&&/(\\[[^[\\]]*])/.exec(n),s=a?n.slice(0,a.index):n,c=[];if(s){if(!r.plainObjects&&i.call(Object.prototype,s)&&!r.allowPrototypes)return;c.push(s)}for(var l=0;0<r.depth&&null!==(a=o.exec(n))&&l<r.depth;){if(l+=1,!r.plainObjects&&i.call(Object.prototype,a[1].slice(1,-1))&&!r.allowPrototypes)return;c.push(a[1])}return a&&c.push(\"[\"+n.slice(a.index)+\"]\"),function(e,t,r){for(var n=t,o=e.length-1;0<=o;--o){var i,a=e[o];if(\"[]\"===a&&r.parseArrays)i=[].concat(n);else{i=r.plainObjects?Object.create(null):{};var s=\"[\"===a.charAt(0)&&\"]\"===a.charAt(a.length-1)?a.slice(1,-1):a,c=parseInt(s,10);r.parseArrays||\"\"!==s?!isNaN(c)&&a!==s&&String(c)===s&&0<=c&&r.parseArrays&&c<=r.arrayLimit?(i=[])[c]=n:i[s]=n:i={0:n}}n=i}return n}(c,t,r)}}var o=e(\"./utils\"),i=Object.prototype.hasOwnProperty,a={allowDots:!1,allowPrototypes:!1,arrayLimit:20,charset:\"utf-8\",charsetSentinel:!1,comma:!1,decoder:o.decode,delimiter:\"&\",depth:5,ignoreQueryPrefix:!1,interpretNumericEntities:!1,parameterLimit:1e3,parseArrays:!0,plainObjects:!1,strictNullHandling:!1};t.exports=function(e,t){var r=function(e){if(!e)return a;if(null!==e.decoder&&void 0!==e.decoder&&\"function\"!=typeof e.decoder)throw new TypeError(\"Decoder has to be a function.\");if(void 0!==e.charset&&\"utf-8\"!==e.charset&&\"iso-8859-1\"!==e.charset)throw new Error(\"The charset option must be either utf-8, iso-8859-1, or undefined\");var t=void 0===e.charset?a.charset:e.charset;return{allowDots:void 0===e.allowDots?a.allowDots:!!e.allowDots,allowPrototypes:\"boolean\"==typeof e.allowPrototypes?e.allowPrototypes:a.allowPrototypes,arrayLimit:\"number\"==typeof e.arrayLimit?e.arrayLimit:a.arrayLimit,charset:t,charsetSentinel:\"boolean\"==typeof e.charsetSentinel?e.charsetSentinel:a.charsetSentinel,comma:\"boolean\"==typeof e.comma?e.comma:a.comma,decoder:\"function\"==typeof e.decoder?e.decoder:a.decoder,delimiter:\"string\"==typeof e.delimiter||o.isRegExp(e.delimiter)?e.delimiter:a.delimiter,depth:\"number\"==typeof e.depth||!1===e.depth?+e.depth:a.depth,ignoreQueryPrefix:!0===e.ignoreQueryPrefix,interpretNumericEntities:\"boolean\"==typeof e.interpretNumericEntities?e.interpretNumericEntities:a.interpretNumericEntities,parameterLimit:\"number\"==typeof e.parameterLimit?e.parameterLimit:a.parameterLimit,parseArrays:!1!==e.parseArrays,plainObjects:\"boolean\"==typeof e.plainObjects?e.plainObjects:a.plainObjects,strictNullHandling:\"boolean\"==typeof e.strictNullHandling?e.strictNullHandling:a.strictNullHandling}}(t);if(\"\"===e||null==e)return r.plainObjects?Object.create(null):{};for(var s=\"string\"==typeof e?function(e,t){var r,n={},s=t.ignoreQueryPrefix?e.replace(/^\\?/,\"\"):e,c=t.parameterLimit===1/0?void 0:t.parameterLimit,l=s.split(t.delimiter,c),u=-1,f=t.charset;if(t.charsetSentinel)for(r=0;r<l.length;++r)0===l[r].indexOf(\"utf8=\")&&(\"utf8=%E2%9C%93\"===l[r]?f=\"utf-8\":\"utf8=%26%2310003%3B\"===l[r]&&(f=\"iso-8859-1\"),u=r,r=l.length);for(r=0;r<l.length;++r)if(r!==u){var p,d,y=l[r],h=y.indexOf(\"]=\"),m=-1===h?y.indexOf(\"=\"):h+1;(d=-1===m?(p=t.decoder(y,a.decoder,f,\"key\"),t.strictNullHandling?null:\"\"):(p=t.decoder(y.slice(0,m),a.decoder,f,\"key\"),t.decoder(y.slice(m+1),a.decoder,f,\"value\")))&&t.interpretNumericEntities&&\"iso-8859-1\"===f&&(d=d.replace(/&#(\\d+);/g,function(e,t){return String.fromCharCode(parseInt(t,10))})),d&&t.comma&&-1<d.indexOf(\",\")&&(d=d.split(\",\")),i.call(n,p)?n[p]=o.combine(n[p],d):n[p]=d}return n}(e,r):e,c=r.plainObjects?Object.create(null):{},l=Object.keys(s),u=0;u<l.length;++u){var f=l[u],p=n(f,s[f],r);c=o.merge(c,p,r)}return o.compact(c)}},{\"./utils\":5}],4:[function(e,t,r){\"use strict\";function n(e,t){u.apply(e,l(t)?t:[t])}function o(e,t,r,a,s,c,u,f,p,y,h,m,g){var b=e;if(\"function\"==typeof u?b=u(t,b):b instanceof Date?b=y(b):\"comma\"===r&&l(b)&&(b=b.join(\",\")),null===b){if(a)return c&&!m?c(t,d.encoder,g,\"key\"):t;b=\"\"}if(\"string\"==typeof b||\"number\"==typeof b||\"boolean\"==typeof b||\"symbol\"==typeof b||\"bigint\"==typeof b||i.isBuffer(b))return c?[h(m?t:c(t,d.encoder,g,\"key\"))+\"=\"+h(c(b,d.encoder,g,\"value\"))]:[h(t)+\"=\"+h(String(b))];var v,w=[];if(void 0===b)return w;if(l(u))v=u;else{var O=Object.keys(b);v=f?O.sort(f):O}for(var j=0;j<v.length;++j){var x=v[j];s&&null===b[x]||(l(b)?n(w,o(b[x],\"function\"==typeof r?r(t,x):t,r,a,s,c,u,f,p,y,h,m,g)):n(w,o(b[x],t+(p?\".\"+x:\"[\"+x+\"]\"),r,a,s,c,u,f,p,y,h,m,g)))}return w}var i=e(\"./utils\"),a=e(\"./formats\"),s=Object.prototype.hasOwnProperty,c={brackets:function(e){return e+\"[]\"},comma:\"comma\",indices:function(e,t){return e+\"[\"+t+\"]\"},repeat:function(e){return e}},l=Array.isArray,u=Array.prototype.push,f=Date.prototype.toISOString,p=a.default,d={addQueryPrefix:!1,allowDots:!1,charset:\"utf-8\",charsetSentinel:!1,delimiter:\"&\",encode:!0,encoder:i.encode,encodeValuesOnly:!1,format:p,formatter:a.formatters[p],indices:!1,serializeDate:function(e){return f.call(e)},skipNulls:!1,strictNullHandling:!1};t.exports=function(e,t){var r,i=e,u=function(e){if(!e)return d;if(null!==e.encoder&&void 0!==e.encoder&&\"function\"!=typeof e.encoder)throw new TypeError(\"Encoder has to be a function.\");var t=e.charset||d.charset;if(void 0!==e.charset&&\"utf-8\"!==e.charset&&\"iso-8859-1\"!==e.charset)throw new TypeError(\"The charset option must be either utf-8, iso-8859-1, or undefined\");var r=a.default;if(void 0!==e.format){if(!s.call(a.formatters,e.format))throw new TypeError(\"Unknown format option provided.\");r=e.format}var n=a.formatters[r],o=d.filter;return\"function\"!=typeof e.filter&&!l(e.filter)||(o=e.filter),{addQueryPrefix:\"boolean\"==typeof e.addQueryPrefix?e.addQueryPrefix:d.addQueryPrefix,allowDots:void 0===e.allowDots?d.allowDots:!!e.allowDots,charset:t,charsetSentinel:\"boolean\"==typeof e.charsetSentinel?e.charsetSentinel:d.charsetSentinel,delimiter:void 0===e.delimiter?d.delimiter:e.delimiter,encode:\"boolean\"==typeof e.encode?e.encode:d.encode,encoder:\"function\"==typeof e.encoder?e.encoder:d.encoder,encodeValuesOnly:\"boolean\"==typeof e.encodeValuesOnly?e.encodeValuesOnly:d.encodeValuesOnly,filter:o,formatter:n,serializeDate:\"function\"==typeof e.serializeDate?e.serializeDate:d.serializeDate,skipNulls:\"boolean\"==typeof e.skipNulls?e.skipNulls:d.skipNulls,sort:\"function\"==typeof e.sort?e.sort:null,strictNullHandling:\"boolean\"==typeof e.strictNullHandling?e.strictNullHandling:d.strictNullHandling}}(t);\"function\"==typeof u.filter?i=(0,u.filter)(\"\",i):l(u.filter)&&(r=u.filter);var f,p=[];if(\"object\"!=typeof i||null===i)return\"\";f=t&&t.arrayFormat in c?t.arrayFormat:t&&\"indices\"in t?t.indices?\"indices\":\"repeat\":\"indices\";var y=c[f];r=r||Object.keys(i),u.sort&&r.sort(u.sort);for(var h=0;h<r.length;++h){var m=r[h];u.skipNulls&&null===i[m]||n(p,o(i[m],m,y,u.strictNullHandling,u.skipNulls,u.encode?u.encoder:null,u.filter,u.sort,u.allowDots,u.serializeDate,u.formatter,u.encodeValuesOnly,u.charset))}var g=p.join(u.delimiter),b=!0===u.addQueryPrefix?\"?\":\"\";return u.charsetSentinel&&(\"iso-8859-1\"===u.charset?b+=\"utf8=%26%2310003%3B&\":b+=\"utf8=%E2%9C%93&\"),0<g.length?b+g:\"\"}},{\"./formats\":1,\"./utils\":5}],5:[function(e,t,r){\"use strict\";function n(e,t){for(var r=t&&t.plainObjects?Object.create(null):{},n=0;n<e.length;++n)void 0!==e[n]&&(r[n]=e[n]);return r}var o=Object.prototype.hasOwnProperty,i=Array.isArray,a=function(){for(var e=[],t=0;t<256;++t)e.push(\"%\"+((t<16?\"0\":\"\")+t.toString(16)).toUpperCase());return e}();t.exports={arrayToObject:n,assign:function(e,t){return Object.keys(t).reduce(function(e,r){return e[r]=t[r],e},e)},combine:function(e,t){return[].concat(e,t)},compact:function(e){for(var t=[{obj:{o:e},prop:\"o\"}],r=[],n=0;n<t.length;++n)for(var o=t[n],a=o.obj[o.prop],s=Object.keys(a),c=0;c<s.length;++c){var l=s[c],u=a[l];\"object\"==typeof u&&null!==u&&-1===r.indexOf(u)&&(t.push({obj:a,prop:l}),r.push(u))}return function(e){for(;1<e.length;){var t=e.pop(),r=t.obj[t.prop];if(i(r)){for(var n=[],o=0;o<r.length;++o)void 0!==r[o]&&n.push(r[o]);t.obj[t.prop]=n}}}(t),e},decode:function(e,t,r){var n=e.replace(/\\+/g,\" \");if(\"iso-8859-1\"===r)return n.replace(/%[0-9a-f]{2}/gi,unescape);try{return decodeURIComponent(n)}catch(e){return n}},encode:function(e,t,r){if(0===e.length)return e;var n=e;if(\"symbol\"==typeof e?n=Symbol.prototype.toString.call(e):\"string\"!=typeof e&&(n=String(e)),\"iso-8859-1\"===r)return escape(n).replace(/%u[0-9a-f]{4}/gi,function(e){return\"%26%23\"+parseInt(e.slice(2),16)+\"%3B\"});for(var o=\"\",i=0;i<n.length;++i){var s=n.charCodeAt(i);45===s||46===s||95===s||126===s||48<=s&&s<=57||65<=s&&s<=90||97<=s&&s<=122?o+=n.charAt(i):s<128?o+=a[s]:s<2048?o+=a[192|s>>6]+a[128|63&s]:s<55296||57344<=s?o+=a[224|s>>12]+a[128|s>>6&63]+a[128|63&s]:(i+=1,s=65536+((1023&s)<<10|1023&n.charCodeAt(i)),o+=a[240|s>>18]+a[128|s>>12&63]+a[128|s>>6&63]+a[128|63&s])}return o},isBuffer:function(e){return!(!e||\"object\"!=typeof e||!(e.constructor&&e.constructor.isBuffer&&e.constructor.isBuffer(e)))},isRegExp:function(e){return\"[object RegExp]\"===Object.prototype.toString.call(e)},merge:function e(t,r,a){if(!r)return t;if(\"object\"!=typeof r){if(i(t))t.push(r);else{if(!t||\"object\"!=typeof t)return[t,r];(a&&(a.plainObjects||a.allowPrototypes)||!o.call(Object.prototype,r))&&(t[r]=!0)}return t}if(!t||\"object\"!=typeof t)return[t].concat(r);var s=t;return i(t)&&!i(r)&&(s=n(t,a)),i(t)&&i(r)?(r.forEach(function(r,n){if(o.call(t,n)){var i=t[n];i&&\"object\"==typeof i&&r&&\"object\"==typeof r?t[n]=e(i,r,a):t.push(r)}else t[n]=r}),t):Object.keys(r).reduce(function(t,n){var i=r[n];return o.call(t,n)?t[n]=e(t[n],i,a):t[n]=i,t},s)}}},{}]},{},[2])(2)});var qs=require(\"qs\"),fly=new Fly;async function getRequest(e,t){let r=await fly.get(t).then(function(e){return console.log(e),e}).catch(function(e){return console.log(e),e});return r.requestId=e,window.webkit.messageHandlers.lwwebloader.postMessage(JSON.parse(JSON.stringify(r))),null}async function postReuest(e,t){let r=await fly.post(t,qs.stringify({bar:123})).then(function(e){return console.log(e),e}).catch(function(e){return console.log(e),e});return r.requestId=e,window.webkit.messageHandlers.lwwebloader.postMessage(JSON.parse(JSON.stringify(r))),null}</script>\n"
                            "</head>\n"
                            "<body>\n"
                            "<h1> Hello</h1>\n"
                            "</body>\n"
                            "</html>";

    [self.webview loadHTMLString:defaultHTML baseURL:[NSURL URLWithString:@"http://mytest.com"]];
*/}



@end







#pragma mark - ScriptMessageHandler

@interface LWWLWKScriptMessageHandler : NSObject <WKScriptMessageHandler>
//@property(nonatomic, strong) NSMutableData *dataToDownload;
@property(nonatomic, strong) NSOutputStream *dataStream;
@property(nonatomic, copy) void (^dataLoadCompletionHandler)(BOOL,id, NSError *);

@property(nonatomic, copy) NSString *streamFilePath;

@property(nonatomic, strong) NSError *streamError;

+ (LWWLWKScriptMessageHandler *)messageHandleWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody dataLoadCompletionHandler:(void (^)(BOOL,id, NSError *))dataLoadCompletionHandler;

- (void)streamFilePathWithFileName:(NSString *)fileName;
@end
@implementation LWWLWKScriptMessageHandler

- (void)dealloc {
    if(self.dataStream){
        [self.dataStream close];
        self.dataStream = nil;
    }
    WLLog(@"===========dealloc LWWLWKScriptMessageHandler ");
}

+ (LWWLWKScriptMessageHandler *)messageHandleWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody dataLoadCompletionHandler:(void (^)(BOOL,id, NSError *))dataLoadCompletionHandler {
    LWWLWKScriptMessageHandler *messageHandler = [LWWLWKScriptMessageHandler new];
    messageHandler.dataLoadCompletionHandler = dataLoadCompletionHandler;
    [messageHandler streamFilePathWithFileName:evaluateBody.requestId];
    return messageHandler;
}

- (void)streamFilePathWithFileName:(NSString *)fileName {
    _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

-(NSString *)streamFilePath {
    if(!_streamFilePath){
        _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    }
    return _streamFilePath;
}

-(NSOutputStream *)dataStream {
    if(!_dataStream){
        _dataStream = [[NSOutputStream alloc] initToFileAtPath:self.streamFilePath append:YES];
    }
    return _dataStream;
}

/*
-(NSMutableData *)dataToDownload{
    if(!_dataToDownload){
        _dataToDownload = [[NSMutableData alloc] init];
    }
    return _dataToDownload;
}
*/

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:@"bridge"]){

        if(!message.body){
            self.dataLoadCompletionHandler(YES,nil, [NSError errorWithDomain:@"数据为空" code:0 userInfo:nil]);
            return;

        }else if(![message.body isKindOfClass:[NSDictionary class]]){
            if(self.dataLoadCompletionHandler){
                self.dataLoadCompletionHandler(YES,nil,[NSError errorWithDomain:@"数据格式错误" code:0 userInfo:nil]);
            }
            return;
        }


        WLMessageBody *body = [[WLMessageBody alloc] initWithDictionary:message.body];
        if([body.type isEqualToString:@"json"]) {
            if(self.dataLoadCompletionHandler){
                self.dataLoadCompletionHandler(YES,body.value,nil);
            }

        }else if([body.type isEqualToString:@"plaintext"]) {
            if(self.dataLoadCompletionHandler){
                self.dataLoadCompletionHandler(YES,body.value,nil);
            }

        }else if([body.type isEqualToString:@"b64text"]) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            if(self.dataLoadCompletionHandler){
                self.dataLoadCompletionHandler(YES,data,nil);
            }

        }else if([body.type isEqualToString:@"b64streamstart"]) {
            WLLog(@"=====b64 streaming start !");
//        self.dataToDownload = [[NSMutableData alloc] init];
            [self.dataStream open];

        }else if([body.type isEqualToString:@"b64streaming"]) {
            double progress = body.received.doubleValue/body.total.doubleValue;
            WLLog(@"=====b64 streaming %.2f...", progress);
//        [self.dataToDownload appendData:data];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            NSUInteger dataLength = [data length];
            NSInteger writeLen = [self.dataStream write:[data bytes] maxLength:dataLength];
            if(dataLength > writeLen){
                self.streamFilePath = nil;
                self.streamError = [self.dataStream streamError];
                [self.dataStream close];
                self.dataStream = nil;
            }

        }else if([body.type isEqualToString:@"b64streamend"]) {
            WLLog(@"=====b64 streaming finish !");
            if(self.dataStream && self.dataStream.streamStatus != NSStreamStatusClosed){
                [self.dataStream close];
                self.dataStream = nil;
            }
            if(self.dataLoadCompletionHandler){
                self.dataLoadCompletionHandler(YES,self.streamFilePath,self.streamError);
            }

        }

    }else if([message.name isEqualToString:@"nativelog"]){
        WLLog(@"=====nativelog:%@",message.body);
    }

}


@end







#pragma mark - WLWebView

@implementation WLWebView

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request {
    WLLog(@"===========loadRequest");
    NSMutableDictionary<NSString *, NSString *> *headerFields = [request.allHTTPHeaderFields mutableCopy];
    headerFields[@"referrer"] = @"http://app.wodedata.com";

    NSMutableURLRequest *mRequest = [NSMutableURLRequest new];
    [mRequest setAllHTTPHeaderFields:headerFields];

    return [super loadRequest:request];
}


+ (instancetype)buildWebViewWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody
                                  parentView:(UIView *_Nonnull)parentView
                   dataLoadCompletionHandler:(void (^)(BOOL, id, NSError *))dataLoadCompletionHandler
                         jsCompletionHandler:(void (^)(id, NSError *))jsCompletionHandler {

    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webConfiguration.userContentController = [WKUserContentController new];
    webConfiguration.processPool = [[WKProcessPool alloc] init];
    webConfiguration.applicationNameForUserAgent = [NSString stringWithFormat:@""];

    NSString *injectionJS = @"function log(msg) {window.webkit.messageHandlers.nativelog.postMessage(msg);}";
    WKUserScript *compileFiltersUserScript = [[WKUserScript alloc] initWithSource:injectionJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webConfiguration.userContentController addUserScript:compileFiltersUserScript];

    LWWLWKScriptMessageHandler *messageHandler = [LWWLWKScriptMessageHandler messageHandleWithEvaluateBody:evaluateBody dataLoadCompletionHandler:dataLoadCompletionHandler];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"bridge"];
//    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"plaintext"];
//    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"b64text"];
//    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"b64streamstart"];
//    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"b64streaming"];
//    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"b64streamend"];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"nativelog"];

    WLWebView *webView = [[WLWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:webConfiguration];
    [parentView addSubview:webView];
    webView.navigationDelegate = webView;
    webView.evaluateBody = evaluateBody;
    webView.evaluateJSCompletionHandler = jsCompletionHandler;
    return webView;
}

- (void)dealloc {
    WLLog(@"===========dealloc WLWebView ");
    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"bridge"];
//    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"plaintext"];
//    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"b64text"];
//    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"b64streamstart"];
//    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"b64streaming"];
//    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"b64streamend"];
    [self.webConfiguration.userContentController removeScriptMessageHandlerForName:@"nativelog"];
}


/*
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//参考：iOS WKWebView基本使用总结:https://lishibo-ios.github.io/2018/06/11/WKWebView/
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    WLLog(@"===========webView didStartProvisionalNavigation");
}
// 当内容开始返回时调用 内容开始到达主帧时被调用（即将完成）
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    WLLog(@"===========webview didCommitNavigation");
}
*/

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    WLLog(@"===========webview didFinishNavigation");

    [self evaluateJavaScript:self.evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
        if (self.evaluateJSCompletionHandler) {
            self.evaluateJSCompletionHandler(o, error);
        }
    }];

    [self showWebCachePath];

}

- (void)showWebCachePath {
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/
    NSString *bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    /* * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    WLLog(@"==========webkit folder: %@",webKitFolderInCachesfs);
}

@end



