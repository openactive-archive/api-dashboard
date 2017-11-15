# Contributing to the OpenActive API Dashboard

The OpenActive API Dashboard is open source, and contributions are gratefully accepted! 

Details on how to contribute to **this repository** are below.

By participating in this project, you agree to abide by our [Code of Conduct](https://github.com/openactive/api-dashboard/blob/master/.github/CODE_OF_CONDUCT.md).

Follow the [readme instructions](https://github.com/openactive/api-dashboard/blob/master/README.md) to get your development environment running locally.

If this is your first time contributing to this codebase you will need to [create a fork of this repository](https://help.github.com/articles/fork-a-repo/).

Ensure that the tests pass before working on your contribution.

## Code Review Process 

All contributions to the codebase - whether fork or pull request - will be reviewed per the below criteria.

To increase your chances of your push being accepted please be aware of the following
- Write [well formed commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- Follow our style guide recommendations
- Write tests for all changes (additions or refactors of existing code). 
- Of the github integrations we use two will be utilised to check appraise your contribution. In order of priority these are
    - Travis ensures that all tests (existing and additions) pass
    - Travis/Coveralls ensures that overall test coverage for lines of code meets a certain threshold. If this metric dips below what it previously was for the repository you’re pushing to then your PR will be rejected
- Once your PR is published and passes the above checks a repository administrator will review your contribution. Where appropriate comments may be provided and amendments suggested before your PR is merged into Master.
- Once your PR is accepted you will be granted push access to the repository you have contributed to! Congratulations on joining our community, you’ll no longer need to work from forks.

## Code Style Guide

We follow the same code style conventions as detailed in Github’s [Ruby Style Guide](https://github.com/github/rubocop-github/blob/master/STYLEGUIDE.md)