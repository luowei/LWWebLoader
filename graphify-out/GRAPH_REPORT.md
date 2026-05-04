# Graph Report - /Users/luowei/projects/libs/LWWebLoader  (2026-05-04)

## Corpus Check
- Corpus is ~30,818 words - fits in a single context window. You may not need a graph.

## Summary
- 286 nodes · 617 edges · 24 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]

## God Nodes (most connected - your core abstractions)
1. `e()` - 41 edges
2. `ve()` - 25 edges
3. `WLViewController` - 23 edges
4. `LWWebLoader` - 22 edges
5. `WLWebView` - 16 edges
6. `LWWLWKScriptMessageHandler` - 16 edges
7. `o()` - 14 edges
8. `m()` - 13 edges
9. `H()` - 13 edges
10. `re()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `-showWebCachePath` --calls--> `WLLog()`  [EXTRACTED]
  LWWebLoader/Classes/LWWebLoader.m → LWWebLoader_swift/Classes/LWWebLoader.swift

## Communities (30 total, 4 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.13
Nodes (11): LWWebLoaderViewModel, WebLoaderExampleView, WebLoaderExampleView_Previews, WebLoaderView, WebLoaderViewRepresentable, WebLoadRequest, WebLoadResponse, ObservableObject (+3 more)

### Community 1 - "Community 1"
Cohesion: 0.08
Nodes (23): WLViewController, -btn0Action, -connectWSAction, -downloadFileBtnAction, -downloadStreamBtnAction, -getBtnAction, -getClipboardTextBtnAction, -handleWithBody (+15 more)

### Community 2 - "Community 2"
Cohesion: 0.14
Nodes (10): Common code for GET and HEAD commands.         This sends the response code and, Helper to produce a directory listing (absent index.html).         Return value, Translate a /-separated PATH to the local filename syntax.         Components th, Copy all data between two file objects.         The SOURCE argument is a file ob, Guess the type of a file.         Argument is a PATH (a filename).         Retur, Simple HTTP request handler with GET/HEAD/POST commands.     This serves files f, Serve a HEAD request., Serve a POST request. (+2 more)

### Community 3 - "Community 3"
Cohesion: 0.2
Nodes (17): Ae(), ar(), br(), Ce(), ee(), er(), hr(), ke() (+9 more)

### Community 4 - "Community 4"
Cohesion: 0.24
Nodes (18): a(), be(), dr(), e(), f(), Fe(), fr(), ge() (+10 more)

### Community 5 - "Community 5"
Cohesion: 0.12
Nodes (17): LWWebLoadMethod, downloadFile, downloadStream, getClipboardText, getData, nativeLog, postData, uploadData (+9 more)

### Community 6 - "Community 6"
Cohesion: 0.12
Nodes (16): LWWebLoader, -bodyWithURLStringmethodmethodArgumentsuserAgentcontentTypepostDatauploadData, -dealloc, -evaluateWithBodyparentViewdataLoadCompletionHandler, -evaluateWithBodyparentViewjsExcuteCompletionHandler, -loadPageWithBaseURL, -removeWSWebView, -startWSWebViewWithParentViewreceiveWSDataHandler (+8 more)

### Community 7 - "Community 7"
Cohesion: 0.16
Nodes (11): WLLog(), WLWebView, -buildWebViewWithEvaluateBodyparentViewdataLoadCompletionHandlerjsCompletionHandler, -dealloc, -loadRequest, -showWebCachePath, -webViewdidCommitNavigation, -webViewdidFinishNavigation (+3 more)

### Community 8 - "Community 8"
Cohesion: 0.28
Nodes (14): cr(), ir(), Le(), lr(), nr(), pe(), qe(), qr() (+6 more)

### Community 9 - "Community 9"
Cohesion: 0.21
Nodes (9): Dictionary, NSDictionary, -lwwl_jsonStringWithPrettyPrint, WLEvaluateBody, -url, WLHanderBody, -bodyWithIdbodyTypehandlerResult, WLMessageBody (+1 more)

### Community 10 - "Community 10"
Cohesion: 0.27
Nodes (13): _(), De(), G(), he(), i(), je(), l(), n() (+5 more)

### Community 11 - "Community 11"
Cohesion: 0.25
Nodes (7): LWWLWKScriptMessageHandler, -dataStream, -dealloc, -messageHandleWithEvaluateBodydataLoadCompletionHandler, -streamFilePath, -streamFilePathWithFileName, -userContentControllerdidReceiveScriptMessage

### Community 12 - "Community 12"
Cohesion: 0.33
Nodes (10): B(), c(), d(), H(), j(), K(), m(), r() (+2 more)

### Community 13 - "Community 13"
Cohesion: 0.25
Nodes (8): WSWKScriptMessageHandler, -buildMessageHandleWithReceiveWSDataHandler, -dataStream, -dealloc, -streamFilePath, -userContentControllerdidReceiveScriptMessage, NSObject, WKScriptMessageHandler

### Community 14 - "Community 14"
Cohesion: 0.25
Nodes (7): WLAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 15 - "Community 15"
Cohesion: 0.25
Nodes (3): CORSHTTPRequestHandler, Common code for GET and HEAD commands.         This sends the response code and, SimpleHTTPRequestHandler

### Community 16 - "Community 16"
Cohesion: 0.62
Nodes (5): createWriteStream(), loadTransporter(), makeIframe(), makePopup(), test()

### Community 18 - "Community 18"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

### Community 19 - "Community 19"
Cohesion: 0.6
Nodes (5): ie(), oe(), re(), Se(), W()

### Community 21 - "Community 21"
Cohesion: 0.5
Nodes (4): WSWebView, -buildWebViewWithParentViewreceiveWSDataHandler, -dealloc, -webViewdidFinishNavigation

## Knowledge Gaps
- **93 isolated node(s):** `-url`, `-initWithDictionary`, `-bodyWithIdbodyTypehandlerResult`, `-lwwl_jsonStringWithPrettyPrint`, `-webloader` (+88 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWWebLoader` connect `Community 6` to `Community 9`, `Community 17`, `Community 7`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Why does `LWWLWKScriptMessageHandler` connect `Community 11` to `Community 9`, `Community 13`, `Community 7`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `WLWebView` connect `Community 7` to `Community 9`, `Community 17`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **What connects `-url`, `-initWithDictionary`, `-bodyWithIdbodyTypehandlerResult` to the rest of the system?**
  _93 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._