# RoadRunner

### How to compile the code

Open terminal and navigate to directory containing `main.swift` (also make sure you have `Swift` toolchain installed: https://swift.org/download/). 
Then run following commands:

```console
chmod +x compile.sh
./compile.sh
./main
```

If everything is okay, you should receive the following output:

```console
⚠️  Missing `base_file` argument!

Usage: ./main base_file=path/to/base/file.html reference_file=path/to/reference/file.html [OPTIONS]
OPTIONS:
-tag_id=id  Search for a tag with a given `id`. If not found, calculate wrapper on the whole tree
-tree=path/to/file.html  By setting this flag, you don't have to provide `base_file` and `reference_file` arguments. This will inturn dump tree structure of provided file
-output_file=file  Save result into the file
```

### Usage

To generate a wrapper for two `html` files, simply call `./main` with required arguments:

```console
./main base_file=path/to/base/file.html reference_file=path/to/reference/file.html
```

If no error occured during parsing process, you should see the result printed inside the terminal. If instead you want to save the output in a specific file, provide `output_file` argument:

```console
./main base_file=path/to/base/file.html reference_file=path/to/reference/file.html output_file=outputfile.txt
```

Since most of the time we are not interested in parsing the whole HTML document, but instead want to analyze only a specific sub-tree (for tag with a specific id), we can also provide a `tag_id` argument. If a tag with such id exists in both documents, the algorithm will compare only it's subtrees. 

```console
./main base_file=path/to/base/file.html reference_file=path/to/reference/file.html tag_id=content
```

RoadRunner program also enable's us to parse and output a tree-like representation of the HTML document. We achieve this by providing a `tree=file.html` argument (and optionally `output_file` argument as well).

```console
./main tree=path/to/base/file.html [output_file=output.txt]
```

will produce tree which will look something like:

```
 [0:0, 0:0]:
  !DOCTYPE [1:1, 32:9]:
  - a: html: 
    head [2:1, 16:8]:
      style [3:6, 11:14]:
      - v: position:relative;
		background-color:#ffffff;
		height:68px;
		padding-top:20px;
		line-height:50px;
		overflow:hidden;
		z-index:2;
	
    body [17:1, 32:8]:
      div [18:6, 30:12]:
      - a: id: neki
        div [19:11, 19:25]:
        - v: Efg
        div [24:11, 24:22]:
        div [25:11, 25:22]:
        div [26:11, 29:17]:
        - a: class: joze
          h1 [27:16, 27:32]:
          - v: Title 2
          p [28:16, 29:17]:
          - v: Test
		
      br [31:6, 31:11]:
```

----

Lexer and other useful tools based on: 
https://gitlab.com/seckmaster/atheris-sml
