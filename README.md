# Introduction

CodePolicy is a general code quality checker that can also make changes to the code.
You can use it to check your code against the OTOBO code style guide.

# How it can be used

## on the command line

Call _/path/to/CodePolicy/bin/otobo.CodePolicy.pl_ from the toplevel of your repository. Available options are:

- Checks changed files when no argumant is given
- **--all**: Checks all files
- **--directory**: Checks a directory
- **--file**: Checks a file

## pre commit hook 

Call _/path/to/CodePolicy/scripts/install-git-hooks.pl_ in every local repository that you want to have the pre commit hook.
It will automatically be run by "git commit" and reject your commit if a problem was found.
Skip with "git commit --no-verify".

## unit test

Install package into OTOBO, then run _bin/otobo.Console.pl Dev::UnitTest::Run_.

