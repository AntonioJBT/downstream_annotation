.. include:: substitution_vars.rst

.. GitHub doe not render rst substitutions

.. copy across your travis "build..." logo so that it appears in your Github page

.. .. image:: https://travis-ci.org/EpiCompBio/downstream_annotation.svg?branch=master
    :target: https://travis-ci.org/EpiCompBio/downstream_annotation

.. do the same for ReadtheDocs image:

.. note that if your project is called project_Super readthedocs will convert
.. it to project-super

.. .. image:: https://readthedocs.org/projects/EpiCompBio/badge/?version=latest
    :target: http://downstream_annotation.readthedocs.io/en/latest/?badge=latest
    :alt: Documentation Status

 .. Edit manually:

.. .. Zenodo gives a number instead, this needs to be put in manually here:
   .. image:: https://zenodo.org/badge/#######.svg
      :target: https://zenodo.org/badge/latestdoi/#####

**IN PROGRESS**


################################################
downstream_annotation
################################################


.. The following is a modified template from RTD
    http://www.writethedocs.org/guide/writing/beginners-guide-to-docs/#id1

.. For a discussion/approach see 
    http://tom.preston-werner.com/2010/08/23/readme-driven-development.html



Wrapper scripts and tools for annotation of SNPs and results from GWAS and QTL studies


Requirements
------------

See requirements files and Dockerfile for full information. At the least you'll need:

* CGATCore
* R >= 3.2
* Python >= 3.5
* r-docopt
* r-data.table
* r-ggplot2

Installation
------------

.. code-block:: bash
   
    pip install git+git://github.com/EpiCompBio/downstream_annotation.git


To use
------

.. code-block:: bash

    # Create a folder or a whole data science project, e.g. project_quickstart -n annotate_qtl
    cd annotate_qtl/results
    xxxx



Contribute
----------

- `Issue Tracker`_
  
.. _`Issue Tracker`: github.com/EpiCompBio/|project_name|/issues


- Pull requests welcome!


Support
-------

If you have any issues, pull requests, etc. please report them in the issue tracker. 


