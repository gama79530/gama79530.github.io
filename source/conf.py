# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "Rein's Homepage"
copyright = '2023, Rein Wu'
author = 'Rein Wu'
release = '0.0.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx_copybutton",
    "sphinx_togglebutton",
    "myst_nb",
]

templates_path = ['_templates']
exclude_patterns = []

language = 'en'
# language = 'zh_TW'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_book_theme'
html_static_path = ['_static']
# html_logo = "_static/xxx"
html_title = "Rein's Homepage"

html_theme_options = {
    "use_download_button": True,
    "repository_provider": "github",
    "repository_url": "https://github.com/gama79530/gama79530.github.io",
    "use_source_button": True,
    "repository_branch": "main",
    "path_to_docs": "source",
    "use_edit_page_button": True,
    "use_repository_button": True,
    "use_issues_button": True,
}

myst_enable_extensions = [
    "amsmath",
    "colon_fence",
    "deflist",
    "dollarmath",
    "html_image",
]
myst_url_schemes = ("http", "https", "mailto")
myst_number_code_blocks = ['c', 'c++', 'java', 'python', 'html', 'css', 'javascript', 'bash', 'md']

number_source_lines = True
nb_number_source_lines = True

