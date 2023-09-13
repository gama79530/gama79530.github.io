# Building Skeleton of Homepage

## Customize your left sidebar
You can learn how to customize your left sidebar from the [official turtioral](https://sphinx-book-theme.readthedocs.io/en/latest/tutorials/get-started.html#customize-your-left-sidebar)

## Add some margin content to a page
You can learn how to add some margin content to a page from the [official turtioral](https://sphinx-book-theme.readthedocs.io/en/latest/tutorials/get-started.html#add-some-margin-content-to-a-page)

## Build hierarchy of pages by toctree
The basic syntax of toctree is as follow:
````md
```{toctree}  
properties...  

children pages...  
```
````
![page hierarchy](../_static/page_hierarchy.png)

This page is the homepage of the website. The corresponding file is "source/index.md". This homepage is also the root of all blocks. Each block is the root of a toctree. The section 4 describes that my website contains a block and the block contains a 2 levels toctree. The toctree consists of a caption (section 1), a level 1 page (section 2) and three level 2 pages (section 3). 

![folder hierarchy](../_static/folder_hierarchy.png)
![homepage](../_static/homepage_code.png)

To build the toctree structure, I add the following code into the "source/index.md".
1. **":caption: Project"** make a block with caption **"Project"**
1. **:maxdepth: 2** represents that this block contains a 2 levels toctree. 
1. **homepage/index** indicate where the child page is. (This child is level 1 pages.)

```{note}
- A website can be composed of several blocks.
- A block can be composed of several level 1 pages.
- A level i page can consist several level i+1 pages.
```
```{tip}
:class: dropdown
If you don't want to show the toctree structure in main page (block 5), you can add a properity ":hidden:".
```

![folder hierarchy](../_static/folder_hierarchy.png)
![level 1 page](../_static/level1_page_code.png)

According to the previous setting, we know the level 1 page is "source/homepage/index.md" The title "How To Build Personal Website with GitHub Pages" is the heading 1 of this file. To configure the other three level 2 pages, you have to add a toctree description in this file.  

Configuration of level 2 pages is similar to configure level page 1. Hence I ommit the explanation of this part. 
```{tip}
:class: dropdown
A toctree can be more than 2 levels. The logic of configuration is the smae.
```

## Reference
- [Using toctree to include other documents as children](https://myst-parser.readthedocs.io/en/latest/syntax/organising_content.html#using-toctree-to-include-other-documents-as-children)