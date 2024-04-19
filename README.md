# Async-Image-Loading
Asynchronously Loading Images into Collection View

Store and fetch images asynchronously to make your app more responsive.
 
Overview

Caching images can help you make collection view in app instantiate fast and respond quickly to scrolling. This app is to demonstrate fetching images with URLs. The images are not part the assets catalog and instead are a part of the app bundle to simulate loading each asynchronously by URL. This ensures the user interface remains responsive.

Handle Image Loading and Caching

In this project, the class ImageCache.swift demonstrates a basic mechanism for image loading from a URL with URLSession and caching the downloaded images using NSCache. NetworkMonitor.swift demonstrates network connectivity status. DataTaskManager.swift helps to make API call from URL using asynchronous function.

As the user scrolls in a view, the app requests the same image repeatedly. This app holds onto the relevant completion blocks until the image loads, then passes the image to all of the requesting blocks so the API only has to make one call to fetch an image for a given URL.

This app supports both light and dark modes, here are few references below:

![Simulator Screenshot - iPhone 15 Pro - 2024-04-19 at 16 11 14](https://github.com/akshaykumarios/Async-Image-Loading/assets/44103095/48b3040a-f444-4311-9d60-6aabd821d4f8)
![Simulator Screenshot - iPhone 15 Pro - 2024-04-19 at 16 11 42](https://github.com/akshaykumarios/Async-Image-Loading/assets/44103095/a06d1fc0-f605-4ea7-be23-dc6ed9ce77e1)
