# Building Foundation of Homepage 

## Environment
1. Ubuntu 22.04 LTS
1. Python 3.10.12
1. sphinx-book-theme
1. MyST-NB (MyST is included)

## Installation
Install python modules by the following commands

``` bash
pip install sphinx-book-theme
pip install sphinx-copybutton
pip install sphinx-togglebutton
pip install myst-nb
pip install jupyter
pip install matplotlib
pip install pandas
```
```{note}
You can create an isolated virtual environment and install the enviornment in this virtual environment.
``` bash
python3 -m venv venv
source venv/bin/activate
```
```{tip}
:class: dropdown
You can also install these package by the "requirement.txt" in this repository  
``` bash
    pip install -r requirement.txt
```

## Configuration
### build sphinx architecture
Executing the following command to initialize a Sphinx project
```bash
sphinx-quickstart
rm -rf source/index.rst
```
```{caution}
There are 5 configuration options in the building process  
1. Separate source and build directories (y/n) [n]:
1. Project name:
1. Author name(s):
1. Project release []:
1. Project language [en]:

You can make your own configuration by except the 1st option. You should set the 1st option **y**.
The other 4 options can be change by changing the setting option in the **conf.py** file.
```

### set **conf.py**
- configure your existing Sphinx configuration
``` python
    extensions = [
        "sphinx_copybutton",
        "sphinx_togglebutton",
        "myst_nb",
        "sphinx.ext.graphviz", 
    ]
```

- configure html options
``` python
   html_theme = 'sphinx_book_theme'
   
   html_logo = "_static/{your logo}"
   html_title = "{your title}"

   html_theme_options = {
        "use_download_button": True,
        "repository_provider": "{your-provider}",
        "repository_url": "https://{your-provider}/{org}/{repo}",
        "use_source_button": True,
        "use_edit_page_button": True,
        "use_repository_button": True,
        "use_issues_button": True,
   }
```
```{note}
1. html_logo and html_title is used to customize your left sidebar. see also [Customize your left sidebar](https://sphinx-book-theme.readthedocs.io/en/stable/tutorials/get-started.html#customize-your-left-sidebar)
1. use_download_button allows you to download source of webpage. see also [Add a download page button](https://sphinx-book-theme.readthedocs.io/en/stable/components/download.html)
1. The other options are related to the settings of remote repository. see also [Buttons that link to source files](https://sphinx-book-theme.readthedocs.io/en/stable/components/source-files.html#)
```
```{tip}
:class: dropdown
configuration of my homepage is:  
- skip html_logo
- html_title = "Rein's Homepage"
- "repository_provider": "github",
- "repository_url": "https://github.com/gama79530/gama79530.github.io",
```

- configure myst options
```python
myst_enable_extensions = [
    "amsmath",
    "colon_fence",
    "deflist",
    "dollarmath",
    "html_image",
]

myst_url_schemes = ("http", "https", "mailto")
myst_number_code_blocks = ['c', 'c++', 'java', 'python', 'html', 'css', 'javascript', 'bash']
myst_heading_anchors = 4
```
```{note}
1. You can see the function of myst_url_schemes from [Set URL scheme defaults ‼️](https://myst-parser.readthedocs.io/en/latest/develop/_changelog.html#set-url-scheme-defaults)
1. You can see the functions of other settings from [Global configuration](https://myst-parser.readthedocs.io/en/latest/configuration.html)
```

- configure myst-nb options
```python
number_source_lines = True
nb_number_source_lines = True
```
```{note}
1. You can see the functions of these 2 settings from [Configuration](https://myst-nb.readthedocs.io/en/latest/configuration.html#rendering)
```

- configure graphviz options
```python
graphviz_output_format = "svg"
```
```{note}
1. You can see the functions of graphviz_output_format from [sphinx.ext.graphviz](https://www.sphinx-doc.org/en/master/usage/extensions/graphviz.html#confval-graphviz_output_format)
```

## Publish
### configure the repository on github
![Publish Homepage](../../_static/publish_website.png)

### cleaning all derivative files
you can clear all derivative files by the following command.
```bash
make clean
```

### previewing while editing
you can preview the homepage by opening build/html/index.html on a web browser after executing the following command.
```bash
make preview
```

### publish the result to the github pages
executing the following command and push the files in docs directory to the github repository.
```bash
make publish
```