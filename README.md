![version](https://img.shields.io/badge/version-19%2B-5682DF)

# 4d-tips-write-pro-paste-reference
How to calibrate the pasteboard so that references are pasted with style and value

## The probem

When you copy or cut a piece of styled text in 4D, both the RTF and HTML renderings are added to the pasteboard.

When the source text is an expression or reference, the HTML version does not contain any visible text, either as values or as references.

The references are stored as attributes. For example, `public.html` may look like this:

```html
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
</head>
<body>
<p style="white-space:pre-wrap;border-width:2pt;font-size:12pt;margin:0pt;padding:0pt;font-family:'Times New Roman'">
<span> </span><!--notice the empty span-->
</p>
</body>
</html>
```

There is also a `com.4d.private.text.span` and  `com.4d.private.text.spanext`, where the references are stored as styles:

```html
<span style="-d4-ref:'[Table_1:1]Field_2:2'"> </span>
```

The RTF, by contrast, contains the text as WYSIWIG.

<img width="470" alt="" src="https://user-images.githubusercontent.com/1725068/194074664-693a6fe6-169f-4509-94a5-60db7f819e7a.png">

However, most external apps will prefer HTML over RTF, which mwans the pasted text would be empty.

## The Solution

Before pasting to an external app, the use would likely move 4D to the background. So there is a chance to perform some tricks in the *On System Event* database method.

The goal is to remove `public.html` from the list of pasteboard data types. 

You can't clear a specific data type, you can only wipe the whole pasteboard.

When you start from a blank slate, it is important that you don't add data that removes existing data. 

You should generally move from pain to rich to hyper text and add private data at the end.
