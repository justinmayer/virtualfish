# Contributing to virtualfish

Whether you're reporting a bug or contributing code, you're helping to make virtualfish better, and for that, thank you!

## Code of Conduct

The [Contributor Covenant 1.2](https://www.contributor-covenant.org/version/1/2/0/code-of-conduct/) applies to all spaces associated with this project (e.g. GitHub, the IRC channel). If you need to make a report, contact [Justin Mayer](https://justinmayer.com/ciao-justin/).

## Filing Helpful Issues

Here's a few tips on how to file a useful issue.

- **Try installing the VirtualFish development version**, by running `pip install git+https://github.com/justinmayer/virtualfish`, to see if your issue has already been fixed.
- **Check the documentation** and **search past issues** before you file your issue.
    - That said, if something is hard to find or understand, you can still file a bug suggesting an improvement to the docs or to virtualfish's usability.
- **Be polite**, and remember that the people that work on virtualfish do so in our spare time for free.
- **Explain your problem**. As well as being more polite than just dumping a massive stack trace on us without any context, a written explanation of what is going wrong can help us fix issues faster.

## Making Awesome Contributions

Thanks for giving your time to work on Virtualfish's code! To have your patch merged as quickly as possible, please make sure you follow these rules.

- If features **are going to be used by the majority of users**, add them to `virtual.fish`. Otherwise, create a plugin if you can.
- If you're adding a feature, think about whether it belongs in `virtual.fish` or as a plugin (separate `.fish` file in this repository). If in doubt, make it a plugin.
- Make sure you **update the documentation** if you make user-facing changes, e.g. adding/changing/removing commands or config variables.
- All text content (variable/function names, code comments, documentation, Git commit messages) **must be in English**. (The preference is for Australian English, but any English will do.)
- Git commits in this repository must follow the **[AngularJS Git Commit Guidelines](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit)**, with the exception that the body and footer are optional.
