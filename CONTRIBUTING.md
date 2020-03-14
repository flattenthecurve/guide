# How to contribute
This content is work in progress, please check back often as it will likely change. If you want to help, we currently need these roles - each with instructions describing how to make contributions such that updates can flow as efficiently as possible:

* [English Content Contributors](#english-content-contributors)
* [Scientific Reviewers](#scientific-reviewers)
* [Translators](#translators)

-----

## English Content Contributors

We need to keep the information updated with recent developments and recommendations. In this role you can edit any portion of content and create a pull request to have a reviewer confirm and approve your editing. All of the English content is located [here](https://github.com/flattenthecurve/guide/tree/master/_content/en). There is a folder for each topic, under which there are files for each section.

### How to suggest an update or change

1. Identify a section that needs to be added or modified
2. Edit the content trying as best you can to match style and tone of the language used in that section - see instructions on how to edit content [here](https://help.github.com/en/github/managing-files-in-a-repository/editing-files-in-another-users-repository).
3. Before submitting a change request, please [check the open pull requests](https://github.com/flattenthecurve/guide/pulls) to make sure that the same request has not yet been completed by someone else
4. Include a comment with a link to a trusted source or a justification for the change request
5. Thanks for the contribution - give yourself a celebratory pat on the back!


![](https://media.giphy.com/media/3o7btW9s53TyntUsP6/giphy.gif)

### Review of the contribution
Each request will be reviewed by someone on the scientific reviewers team. The reviewers team will assess the contribution for scientific validity and, if appropriate, the change will be pushed to the live site!

-----

## Scientific Reviewers
All languages are needed here, but english will be needed for coordination. Domain expertise is key: public health, MD, virology, immunology, epidemiology, etc. 

Your job here is to review updates and changes made by the community and confirm they are accurate and appropriate. 

More information to come.

-----

## Translators
We need to translate and adapt this content to as many languages as possible as soon as we can. Please [register here](https://forms.gle/HrrTiAt32RhfKU2NA) and we’ll start reaching out to onboard folks while we finalize self-serve instructions.

### Update English text to lokalise

On every commit on the `master` branch, we upload the English texts automatically to lokalise.

### Update translations from lokalise

To import all the translations from lokalise, run the following command in the root directory of this repository.

```console
$ ./import-translation.sh <LOKALISE_TOKEN>
```

You can get the `LOKALISE_TOKEN` from https://app.lokalise.com/profile, API tokens.

This command will generate the `_translations/<LANG>.json` files and the `_content/<LANG>`. Then you will need to commit the desired changes.

**NOTE:** All the changes to translations files should be done in lokalise and then imported by the described method.
