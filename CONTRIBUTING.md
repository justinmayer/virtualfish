# Contributing to VirtualFish

Whether you are reporting a bug or contributing code, you are helping to make VirtualFish better, and for that, thank you!

## Code of Conduct

The [Contributor Covenant 1.2](https://www.contributor-covenant.org/version/1/2/0/code-of-conduct/) applies to all spaces associated with this project (e.g. GitHub, the IRC channel). If you need to make a report, contact [Justin Mayer](https://justinmayer.com/ciao-justin/).

## Filing Helpful Issues

Here are a few tips on how to submit a useful issue.

- **Try installing the VirtualFish development version**, by running `pip install git+https://github.com/justinmayer/virtualfish`, to see if your issue has already been fixed.
- **Check the documentation** and **search past issues** before you file your issue.
    - That said, if something is hard to find or understand, you can still submit an issue suggesting an improvement to the docs or to VirtualFish's usability.
- **Be polite**, and remember that the people that work on VirtualFish do so in our spare time for free.
- **Explain your problem**. As well as being more polite than just dumping a massive stack trace on us without any context, a written explanation of what is going wrong can help us fix issues faster.

## Making Awesome Contributions

Thank you for giving your time to work on VirtualFish! To have your contribution merged as quickly as possible, please make sure you follow these guidelines.

- If features **are going to be used by the majority of users**, add them to `virtual.fish`. Otherwise, create a plugin if you can.
- If you’re adding a feature, think about whether it belongs in `virtual.fish` or as a plugin (separate `.fish` file in this repository). If in doubt, make it a plugin.
- Make sure you **update the documentation** if you make user-facing changes, e.g. adding/changing/removing commands or configuration variables.
- All text content (variable/function names, code comments, documentation, Git commit messages) **must be in English**.
- Git commits in this repository should ideally follow the **[AngularJS Git Commit Guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#commits)**, with the exception that the body and footer are optional.
