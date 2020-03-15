# How to contribute
This content is work in progress, please check back often as it will likely change.

If you want to help, we need these roles:

# Request or suggest an update or change

English content is here: https://github.com/flattenthecurve/guide/tree/master/_content/en

There is a folder for each topic and a file for each section. Instructions on how to edit content and request the change can be found here: https://help.github.com/en/github/managing-files-in-a-repository/editing-files-in-another-users-repository.

Before submitting a change request, please check here to make sure that the same request has not yet been done: https://github.com/flattenthecurve/guide/pulls

When changing the content significantly, please include a comment with a link to a trusted source or a justification for the change request.

The reviewers team will do their best to take a look, confirm that the updated content is ok and push it to the live site.

# Scientific reviewers
All languages are needed here, but english will be needed for coordination. Domain expertise is key: public health, MD, virology, immunology, epidemiology, etc.

Your job here is to review updates and changes made by the community and confirm they are accurate and appropriate.

# English content contributors and editors
We need to keep the information updated with recent developments and recommendations. In this role you can edit any portion of content and create a pull request to have a reviewer confirm and approve your editing.

# Translators
We need to translate and adapt this content to as many languages as possible as soon as we can.

Please register here and we’ll start reaching out to onboard folks while we finalize self-serve instructions:

https://forms.gle/HrrTiAt32RhfKU2NA

## Update English text to lokalise
On every commit on the `master` branch, we upload the English texts automatically to lokalise.

## Update translations from lokalise
To import all the translations from lokalise, run the following command in the root directory of this repository.

```console
$ ./import-translations.sh <LOKALISE_TOKEN>
```

You can get the `LOKALISE_TOKEN` from https://app.lokalise.com/profile, API tokens.

This command will generate the `_translations/<LANG>.json` files and the `_content/<LANG>`. Then you will need to commit the desired changes.

**NOTE:** All the changes to translations files should be done in lokalise and then imported by the described method.
