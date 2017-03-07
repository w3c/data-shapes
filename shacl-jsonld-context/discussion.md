To discuss:
- `sh:focusNode` has no `rdfs:range` defined in shacl.ttl, but I have treated it as an "object property" in the JSON-LD @context, since I don't think literals can be targets.
- `sh:sourceConstraint` has no `rdfs:range` defined in shacl.ttl, but I have treated it as an "object property" in the JSON-LD @context.

To consider:

Do we want to use language maps where appropriate, e.g. for `sh:message` (or `sh:name`). 
```
{
  "@context": {
    "@vocab": "http://www.w3.org/ns/shacl#",
    "sh" : "http://www.w3.org/ns/shacl#",
    "message" : {
      "@container" : "@language"
    }
  }
}
```

This leads to (ttl) 
```
 ...
  sh:message "Too many characters"@en ;
  sh:message "Zu viele Zeichen"@de 
 ...
```

being represented as (JSON-LD)
```
 ...
  "message" : {
    "en" : "Too many characters",
    "de" : "Zu viele Zeichen"
  }
 ...
```
 
The only problem is, that when there is no language specified, the key gets split off from the map.
Like so:
```
 ...
  sh:name "postal code" ;
  sh:name "zip code"@en-US ;
 ...
```

becomes:
```
 ...
  "sh:name" : "postal code",
  "name" : {
    "en-us" : "zip code"
  }
 ...
```



`sh:path` is can point to a resource or a list for property paths. One could distinguish this in JSON-LD by mapping @list property paths to a designated key in JSON-LD, e.g. pathList.
```
{
  "@context": {
    "@vocab": "http://www.w3.org/ns/shacl#",
    "path" : {
      "@type" : "@id"
    },
    "pathList" :  {
      "@id" : "path",
      "@type" : "@id",
      "@container" : "@list"
    }
  }
}
```

which would lead to (ttl)
```
...
[
  sh:path ex:single
],
[
  sh:path (ex:knows ex:email) ;
]
...
```

being represented as (JSON-LD)
```
...
{
  "path" : "ex:single",
},
{
  "pathList" : [ "ex:knows", "ex:email" ]
},
...
```

vs.

```
...
{
  "path" :  "ex:single"
},
{
  "path" : {
    "@list" : [ "ex:knows", "ex:email" ]
  }
}
...
```

However, this might confuse users, since pathList is not defined in SHACL and is not mentioned in the spec.
