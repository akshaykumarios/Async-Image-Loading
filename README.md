# Async-Image-Loading
Asynchronously Loading Images into Collection View

Store and fetch images asynchronously to make your app more responsive.
 
Overview

Caching images can help you make collection view in app instantiate fast and respond quickly to scrolling. This app is to demonstrate fetching images with URLs. The images are not part the assets catalog and instead are a part of the app bundle to simulate loading each asynchronously by URL. This ensures the user interface remains responsive.

Handle Image Loading and Caching

In this project, the class ImageCache.swift demonstrates a basic mechanism for image loading from a URL with URLSession and caching the downloaded images using NSCache. NetworkMonitor.swift demonstrates network connectivity status. DataTaskManager.swift helps to make API call from URL using asynchronous function.

As the user scrolls in a view, the app requests the same image repeatedly. This app holds onto the relevant completion blocks until the image loads, then passes the image to all of the requesting blocks so the API only has to make one call to fetch an image for a given URL.
